#import "GestureRecognitionController.h"

@implementation GestureRecognitionController

@synthesize recognitionModel, appController, recognitionWindow, recognitionView;

#pragma mark -
#pragma mark Initialization
- (void)awakeFromNib {
	if (!awakedFromNib) {
		awakedFromNib = YES;
        
		recognitionView.recognitionController = self;
        
		[self hideRecognitionWindow];
        
		recognitionModel = [[GestureRecognitionModel alloc] init];
        
		recentRightClickDate = [NSDate date];
		recentFourFingerTouches = [NSMutableArray array];
	}
}

- (void)applicationDidFinishLaunching {
	eventHandler = CGEventTapCreate(kCGHIDEventTap, kCGHeadInsertEventTap, kCGEventTapOptionDefault, kCGEventMaskForAllEvents, handleEvent, self);
	CFRunLoopSourceRef runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventHandler, 0);
	CFRunLoopAddSource(CFRunLoopGetMain(), runLoopSource, kCFRunLoopCommonModes);
	CGEventTapEnable(eventHandler, YES);
    
	[[MultitouchManager sharedMultitouchManager] addMultitouchListenerWithTarget:self callback:@selector(handleMultitouchEvent:) andThread:nil];
    
	[self layoutRecognitionWindow];
    
	[self hideRecognitionWindow];
}

#pragma mark -

#pragma mark -
#pragma mark Recognition Utilities
- (void)checkPartialGestureWithStrokes:(NSMutableArray *)strokes {
	GestureResult *result = [recognitionModel.gestureDetector recognizeGestureWithStrokes:strokes];
	int rating;
	if (result && (rating = result.score) >= appController.gestureSetupController.setupModel.minimumRecognitionScore) {
		Launchable *launchableToShow = [appController.gestureSetupController.setupModel findLaunchableWithId:result.gestureIdentity];
		if (launchableToShow != nil) {
			partialDescriptionAlert.stringValue = [NSString stringWithFormat:@"%@ - %i%%", launchableToShow.displayName, rating];
			partialIconAlert.image = launchableToShow.icon;
		}
		else {
			[recognitionModel deleteGestureWithName:result.gestureIdentity];
		}
	}
	else {
		partialDescriptionAlert.stringValue = @"";
		partialIconAlert.image = nil;
	}
}

- (void)recognizeGestureWithStrokes:(NSMutableArray *)strokes {
	GestureResult *result = [recognitionModel.gestureDetector recognizeGestureWithStrokes:strokes];
	int rating;
	if (result && (rating = result.score) >= appController.gestureSetupController.setupModel.minimumRecognitionScore) {
		Launchable *launchableToLaunch = [appController.gestureSetupController.setupModel findLaunchableWithId:result.gestureIdentity];
		if (launchableToLaunch != nil) {
			partialDescriptionAlert.stringValue = @"";
			partialIconAlert.image = nil;
            
			appDescriptionAlert.stringValue = launchableToLaunch.displayName;
			appIconAlert.image = launchableToLaunch.icon;
            
			[launchableToLaunch launchWithNewThread:YES];
		}
		else {
			[recognitionModel deleteGestureWithName:result.gestureIdentity];
		}
        
		[self toggleOutRecognitionWindow:YES];
	}
	else {
		[self toggleOutRecognitionWindow:NO];
	}
}

- (void)shouldStartDetectingGesture {
	if (recognitionWindow.alphaValue <= 0) {
		appDescriptionAlert.stringValue = @"";
		appIconAlert.image = nil;
        
		partialDescriptionAlert.stringValue = @"";
		partialIconAlert.image = nil;
        
		[self toggleInRecognitionWindow];
        
		[recognitionView startDetectingGesture];
	}
}

#pragma mark -

#pragma mark -
#pragma mark Activation Event Handling
- (void)handleMultitouchEvent:(MultitouchEvent *)event {
	if (recognitionWindow.alphaValue <= 0) {
		if (event && event.touches.count == 4 && ((MultitouchTouch *)[event.touches objectAtIndex:0]).state == MultitouchTouchStateActive && ((MultitouchTouch *)[event.touches objectAtIndex:1]).state == MultitouchTouchStateActive && ((MultitouchTouch *)[event.touches objectAtIndex:2]).state == MultitouchTouchStateActive && ((MultitouchTouch *)[event.touches objectAtIndex:3]).state == MultitouchTouchStateActive) {
			[recentFourFingerTouches addObject:event];
		}
		else if (recentFourFingerTouches.count > 0) {
			int totalCount = 0;
			float totalVelocity = 0.0f;
			for (MultitouchEvent *fourFingerEvent in recentFourFingerTouches) {
				for (MultitouchTouch *touch in fourFingerEvent.touches) {
					totalCount++;
					totalVelocity += (fabs(touch.velX) + fabs(touch.velY));
				}
			}
            
			[recentFourFingerTouches removeAllObjects];
            
			if (totalCount / 4 <= 30 && (totalVelocity / totalCount) <= 0.5) {
				[self shouldStartDetectingGesture];
			}
		}
	}
}

- (CGEventRef)handleEvent:(CGEventRef)event withType:(int)type {
	if (appController.gestureSetupController.setupModel.multitouchOption) {
		if (recognitionView.detectingInput) {
			if (type == kCGEventKeyUp || type == kCGEventKeyDown) {
				[recognitionView finishDetectingGesture:YES];
				return event;
			}
			else {
				return NULL;
			}
		}
		else if (appController.gestureSetupController.setupView.detectingInput) {
			if (type == kCGEventKeyUp || type == kCGEventKeyDown) {
				[appController.gestureSetupController.setupView finishDetectingGesture:YES];
				return event;
			}
			else {
				return NULL;
			}
		}
	}
	else if (type == kCGEventRightMouseDown && recognitionWindow.alphaValue <= 0) {
		if ([[NSDate date] timeIntervalSinceDate:recentRightClickDate] * 1000 < 420) {
			[self shouldStartDetectingGesture];
            
			recentRightClickDate = [NSDate date];
		}
		else {
			recentRightClickDate = [NSDate date];
		}
	}
    
	return event;
}

CFMachPortRef eventHandler;
CGEventRef handleEvent(CGEventTapProxy proxy, CGEventType type, CGEventRef eventRef, void *refcon) {
	if (type == kCGEventTapDisabledByTimeout || type == kCGEventTapDisabledByUserInput) {
		CGEventTapEnable(eventHandler, true);
		return eventRef;
	}
    
	return [(GestureRecognitionController *)refcon handleEvent : eventRef withType : (int)type];
}

#pragma mark -

#pragma mark -
#pragma mark Window Methods
- (void)fadeOutRecognitionWindow {
	[NSAnimationContext beginGrouping];
	[[NSAnimationContext currentContext] setDuration:0.18];
	[[NSAnimationContext currentContext] setCompletionHandler: ^{
	    [self toggleOutRecognitionWindow:NO];
	}];
	[recognitionWindow.animator setAlphaValue:0.0];
	[NSAnimationContext endGrouping];
}

- (void)toggleOutRecognitionWindow:(BOOL)fadeOut {
	if (fadeOut) {
		[self performSelector:@selector(fadeOutRecognitionWindow) withObject:nil afterDelay:0.4];
	}
	else {
		[self hideRecognitionWindow];
	}
}

- (void)toggleInRecognitionWindow {
	[self layoutRecognitionWindow];
    
	recognitionWindow.alphaValue = 1.0;
	[recognitionWindow orderFrontRegardless];
	[recognitionWindow makeKeyWindow];
}

- (void)hideRecognitionWindow {
	recognitionWindow.alphaValue = 0.0;
	[recognitionWindow orderOut:self];
	[recognitionWindow setFrameOrigin:NSMakePoint(-10000, -10000)];
	[NSApp hide:self];
}

- (void)windowDidResignKey:(NSNotification *)notification {
	if (recognitionWindow.alphaValue > 0) {
		if (recognitionView.detectingInput) {
			[recognitionView finishDetectingGesture:YES];
		}
	}
}

- (void)layoutRecognitionWindow {
	NSPoint mouseLoc = [NSEvent mouseLocation];
	NSEnumerator *screenEnum = [[NSScreen screens] objectEnumerator];
	NSScreen *screen;
	while ((screen = [screenEnum nextObject]) && !NSMouseInRect(mouseLoc, [screen frame], NO)) {
	}
	NSRect screenRect = [screen frame];
    
	NSRect windowRect = NSMakeRect(screenRect.origin.x, screenRect.origin.y, screenRect.size.width, screenRect.size.height);
    
	if (appController.gestureSetupController.setupModel.fullscreenOption) {
		recognitionBackground.alphaValue = 0.91;
		recognitionBackground.roundRadius = 0;
	}
	else {
		float recognitionOffsetX = windowRect.size.width / 1.8;
		float recognitionOffsetY = windowRect.size.height / 1.8;
		windowRect.origin.x += recognitionOffsetX / 2;
		windowRect.origin.y += recognitionOffsetY / 2;
		windowRect.size.width -= recognitionOffsetX;
		windowRect.size.height -= recognitionOffsetY;
        
		recognitionBackground.alphaValue = 0.93;
		recognitionBackground.roundRadius = windowRect.size.height / 46;
	}
    
	[recognitionWindow setFrame:windowRect display:NO];
    
	NSRect recognitionRect = NSMakeRect(0, 0, windowRect.size.width, windowRect.size.height);
	[recognitionView setFrame:recognitionRect];
	[recognitionBackground setFrame:recognitionRect];
    
	NSRect alertIconRect = NSMakeRect((recognitionRect.size.width - (recognitionRect.size.height / 2)) / 2,
	                                  recognitionRect.size.height / 3.4,
	                                  recognitionRect.size.height / 2,
	                                  recognitionRect.size.height / 2);
	[appIconAlert setFrame:alertIconRect];
    
	NSRect alertDescriptionRect = NSMakeRect(0,
	                                         recognitionRect.size.height / 5.5,
	                                         recognitionRect.size.width,
	                                         recognitionRect.size.height / 12);
	[appDescriptionAlert setFont:[NSFont fontWithName:@"Lucida Grande" size:recognitionRect.size.width / 26]];
	[appDescriptionAlert setFrame:alertDescriptionRect];
    
	NSRect partialIconRect = NSMakeRect(recognitionRect.size.width / 40,
	                                    recognitionRect.size.width / 50,
	                                    recognitionRect.size.width / 6.4,
	                                    recognitionRect.size.width / 6.4);
	[partialIconAlert setFrame:partialIconRect];
    
	NSRect partialDescriptionRect = NSMakeRect(recognitionRect.size.width / 5,
	                                           recognitionRect.size.width / 40,
	                                           recognitionRect.size.width,
	                                           recognitionRect.size.width / 28);
	[partialDescriptionAlert setFont:[NSFont fontWithName:@"Lucida Grande" size:recognitionRect.size.width / 40]];
	[partialDescriptionAlert setFrame:partialDescriptionRect];
}

#pragma mark -

@end
