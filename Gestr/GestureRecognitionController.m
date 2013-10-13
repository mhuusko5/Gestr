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
	CFMachPortRef eventTap = CGEventTapCreate(kCGHIDEventTap, kCGHeadInsertEventTap, kCGEventTapOptionDefault, kCGEventMaskForAllEvents, handleEvent, self);
	CFRunLoopSourceRef runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0);
	CFRunLoopAddSource(CFRunLoopGetMain(), runLoopSource, kCFRunLoopCommonModes);
	CGEventTapEnable(eventTap, YES);
    
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
			partialDescriptionAlert.stringValue = [NSString stringWithFormat:@"%@ - %i%%", launchableToLaunch.displayName, rating];
			partialIconAlert.image = launchableToLaunch.icon;
            
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
		if ([self.appController.gestureSetupController.setupWindow alphaValue] > 0) {
			[self.appController.gestureSetupController toggleSetupWindow:nil];
		}
        
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
	if (recognitionWindow.alphaValue > 0) {
		return;
	}
    
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

- (CGEventRef)handleEvent:(CGEventRef)event withType:(int)type {
	if (appController.gestureSetupController.setupModel.multitouchOption && recognitionView.detectingInput) {
		if (type == kCGEventKeyUp || type == kCGEventKeyDown) {
			[recognitionView finishDetectingGesture:YES];
			return event;
		}
		else {
			return NULL;
		}
	}
    
	if (recognitionWindow.alphaValue > 0) {
		return event;
	}
    
	if (type == kCGEventRightMouseDown) {
		if ([[NSDate date] timeIntervalSinceDate:recentRightClickDate] * 1000 < 380) {
			[self shouldStartDetectingGesture];
            
			recentRightClickDate = [NSDate date];
		}
		else {
			recentRightClickDate = [NSDate date];
		}
	}
    
	return event;
}

CGEventRef handleEvent(CGEventTapProxy proxy, CGEventType type, CGEventRef eventRef, void *refcon) {
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
	[[recognitionWindow animator] setAlphaValue:0.0];
	[NSAnimationContext endGrouping];
}

- (void)toggleOutRecognitionWindow:(BOOL)fadeOut {
	if (fadeOut) {
		[self performSelector:@selector(fadeOutRecognitionWindow) withObject:nil afterDelay:0.34];
	}
	else {
		[self hideRecognitionWindow];
        
		[[NSApplication sharedApplication] hide:self];
	}
}

- (void)toggleInRecognitionWindow {
	recognitionWindow.alphaValue = 1.0;
	[self layoutRecognitionWindow];
    
	[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
	[recognitionWindow makeKeyAndOrderFront:self];
}

- (void)hideRecognitionWindow {
	recognitionWindow.alphaValue = 0.0;
	[recognitionWindow orderOut:self];
	[[recognitionWindow parentWindow] removeChildWindow:recognitionWindow];
	[recognitionWindow setFrameOrigin:NSMakePoint(-10000, -10000)];
}

- (void)layoutRecognitionWindow {
	NSPoint mouseLoc = [NSEvent mouseLocation];
	NSEnumerator *screenEnum = [[NSScreen screens] objectEnumerator];
	NSScreen *screen;
	while ((screen = [screenEnum nextObject]) && !NSMouseInRect(mouseLoc, [screen frame], NO)) {
	}
	NSRect screenRect = [screen frame];
	[recognitionWindow setFrame:screenRect display:NO];
    
	NSRect recognitionRect = NSMakeRect(0, 0, screenRect.size.width, screenRect.size.height);
	if (appController.gestureSetupController.setupModel.fullscreenOption) {
		NSRect alertDescriptionRect = NSMakeRect(recognitionRect.origin.x + (recognitionRect.size.height / 40), recognitionRect.size.height / 3, recognitionRect.size.width - 2 * (recognitionRect.size.height / 40), recognitionRect.size.height / 22);
		[appDescriptionAlert setFont:[NSFont fontWithName:@"Lucida Grande" size:recognitionRect.size.width / 52]];
		[appDescriptionAlert setFrame:alertDescriptionRect];
        
		NSSize alertIconSize = NSMakeSize(recognitionRect.size.width / 6, recognitionRect.size.width / 6);
		NSRect alertIconRect = NSMakeRect(recognitionRect.size.width / 2 - alertIconSize.width / 2, recognitionRect.size.height / 1.9 - alertIconSize.height / 2, alertIconSize.width, alertIconSize.height);
		[appIconAlert setFrame:alertIconRect];
        
		[recognitionView setFrame:recognitionRect];
		[recognitionBackground setFrame:recognitionRect];
		recognitionBackground.alphaValue = 0.88;
		((RepeatedImageView *)recognitionBackground).roundRadius = 0;
        
		NSSize partialIconSize = NSMakeSize(recognitionRect.size.width / 10, recognitionRect.size.width / 10);
		NSRect partialIconRect = NSMakeRect(recognitionRect.size.width / 80 + partialIconSize.width / 10, recognitionRect.size.width / 80, partialIconSize.width, partialIconSize.height);
		[partialIconAlert setFrame:partialIconRect];
        
		NSRect partialDescriptionRect = NSMakeRect(2 * (recognitionRect.size.width / 80) + partialIconSize.width * 1.2, recognitionRect.size.width / 100 + partialIconSize.height / 10, recognitionRect.size.width - 2 * partialIconSize.width, recognitionRect.size.height / 30);
		[partialDescriptionAlert setFont:[NSFont fontWithName:@"Lucida Grande" size:recognitionRect.size.width / 72]];
		[partialDescriptionAlert setFrame:partialDescriptionRect];
	}
	else {
		NSRect alertDescriptionRect = NSMakeRect(recognitionRect.origin.x + (recognitionRect.size.height / 40), recognitionRect.size.height / 3.1, recognitionRect.size.width - 2 * (recognitionRect.size.height / 40), recognitionRect.size.height / 22);
		[appDescriptionAlert setFont:[NSFont fontWithName:@"Lucida Grande" size:recognitionRect.size.width / 52]];
		[appDescriptionAlert setFrame:alertDescriptionRect];
        
		NSSize alertIconSize = NSMakeSize(recognitionRect.size.width / 6, recognitionRect.size.width / 6);
		NSRect alertIconRect = NSMakeRect(recognitionRect.size.width / 2 - alertIconSize.width / 2, recognitionRect.size.height / 1.9 - alertIconSize.height / 2, alertIconSize.width, alertIconSize.height);
		[appIconAlert setFrame:alertIconRect];
        
		float recognitionPortion = 0.5;
		float recognitionOffsetX = recognitionRect.size.width * recognitionPortion;
		float recognitionOffsetY = recognitionRect.size.height * recognitionPortion;
		recognitionRect.origin.x += recognitionOffsetX / 2;
		recognitionRect.origin.y += recognitionOffsetY / 2;
		recognitionRect.size.width -= recognitionOffsetX;
		recognitionRect.size.height -= recognitionOffsetY;
		[recognitionView setFrame:recognitionRect];
		[recognitionBackground setFrame:recognitionRect];
		recognitionBackground.alphaValue = 0.93;
		((RepeatedImageView *)recognitionBackground).roundRadius = recognitionRect.size.height / 46;
        
		NSSize partialIconSize = NSMakeSize(recognitionRect.size.width / 7, recognitionRect.size.width / 7);
		NSRect partialIconRect = NSMakeRect(recognitionRect.size.width / 80 + partialIconSize.width / 10, recognitionRect.size.width / 80, partialIconSize.width, partialIconSize.height);
		[partialIconAlert setFrame:partialIconRect];
        
		NSRect partialDescriptionRect = NSMakeRect(2 * (recognitionRect.size.width / 80) + partialIconSize.width * 1.2, recognitionRect.size.width / 100, recognitionRect.size.width - 2 * partialIconSize.width, recognitionRect.size.height / 16);
		[partialDescriptionAlert setFont:[NSFont fontWithName:@"Lucida Grande" size:recognitionRect.size.width / 50]];
		[partialDescriptionAlert setFrame:partialDescriptionRect];
	}
}

#pragma mark -

@end
