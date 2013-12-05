#import "GestureRecognitionController.h"

@interface GestureRecognitionController ()

@property BOOL awakedFromNib;

@property IBOutlet RepeatedImageView *recognitionBackground;

@property IBOutlet NSImageView *appIconAlert;
@property IBOutlet NSTextField *appDescriptionAlert;

@property IBOutlet NSImageView *partialIconAlert;
@property IBOutlet NSTextField *partialDescriptionAlert;

@property NSDate *recentRightClickDate;
@property NSArray *beforeFourFingerTouches;
@property NSMutableArray *recentFourFingerTouches;

@end

@implementation GestureRecognitionController

#pragma mark -
#pragma mark Initialization
- (void)awakeFromNib {
	if (!self.awakedFromNib) {
		self.awakedFromNib = YES;
        
		self.recognitionView.recognitionController = self;
        
		[self hideRecognitionWindow];
        
		self.recognitionModel = [[GestureRecognitionModel alloc] init];
        [self.recognitionModel setup];
        
		self.recentRightClickDate = [NSDate date];
        self.beforeFourFingerTouches = [NSArray arrayWithObjects:@0, @0, @0, nil];
		self.recentFourFingerTouches = [NSMutableArray array];
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
	GestureResult *result = [self.recognitionModel.gestureDetector recognizeGestureWithStrokes:strokes];
	int rating;
	if (result && (rating = result.score) >= self.appController.gestureSetupController.setupModel.minimumRecognitionScore) {
		Launchable *launchableToShow = [self.appController.gestureSetupController.setupModel findLaunchableWithId:result.gestureIdentity];
		if (launchableToShow != nil) {
			self.partialDescriptionAlert.stringValue = [NSString stringWithFormat:@"%@ - %i%%", launchableToShow.displayName, rating];
			self.partialIconAlert.image = launchableToShow.icon;
		}
		else {
			[self.recognitionModel deleteGestureWithName:result.gestureIdentity];
		}
	}
	else {
		self.partialDescriptionAlert.stringValue = @"";
		self.partialIconAlert.image = nil;
	}
}

- (void)recognizeGestureWithStrokes:(NSMutableArray *)strokes {
	GestureResult *result = [self.recognitionModel.gestureDetector recognizeGestureWithStrokes:strokes];
	int rating;
	if (result && (rating = result.score) >= self.appController.gestureSetupController.setupModel.minimumRecognitionScore) {
		Launchable *launchableToLaunch = [self.appController.gestureSetupController.setupModel findLaunchableWithId:result.gestureIdentity];
		if (launchableToLaunch != nil) {
			self.partialDescriptionAlert.stringValue = @"";
			self.partialIconAlert.image = nil;
            
			self.appDescriptionAlert.stringValue = launchableToLaunch.displayName;
			self.appIconAlert.image = launchableToLaunch.icon;
            
			[launchableToLaunch launchWithNewThread:YES];
		}
		else {
			[self.recognitionModel deleteGestureWithName:result.gestureIdentity];
		}
        
		[self toggleOutRecognitionWindow:YES];
	}
	else {
		[self toggleOutRecognitionWindow:NO];
	}
}

- (void)shouldStartDetectingGesture {
	if (self.recognitionWindow.alphaValue <= 0) {
		self.appDescriptionAlert.stringValue = @"";
		self.appIconAlert.image = nil;
        
		self.partialDescriptionAlert.stringValue = @"";
		self.partialIconAlert.image = nil;
        
		[self toggleInRecognitionWindow];
        
		[self.recognitionView startDetectingGesture];
	}
}

#pragma mark -

#pragma mark -
#pragma mark Activation Event Handling
- (void)handleMultitouchEvent:(MultitouchEvent *)event {
	if (self.recognitionWindow.alphaValue <= 0) {
		int activeTouches = 0;
        for (MultitouchTouch *touch in event.touches) {
            if (touch.state == MultitouchTouchStateActive) {
                activeTouches++;
            }
        }
        
        if (activeTouches == 4) {
			[self.recentFourFingerTouches addObject:event];
		}
		else {
            if (self.recentFourFingerTouches.count >= 4 && self.recentFourFingerTouches.count <= 30) {
                int totalCount = 0;
                float totalVelocity = 0.0f;
                for (MultitouchEvent *fourFingerEvent in self.recentFourFingerTouches) {
                    for (MultitouchTouch *touch in fourFingerEvent.touches) {
                        totalCount++;
                        totalVelocity += (fabs(touch.velX) + fabs(touch.velY));
                    }
                }
                
                NSCountedSet *countedBeforeFourFingerTouches = [[NSCountedSet alloc] initWithArray:self.beforeFourFingerTouches];
                if ((totalVelocity / totalCount) <= 0.46 && [countedBeforeFourFingerTouches countForObject:@3] < 3 && [countedBeforeFourFingerTouches countForObject:@5] < 3) {
                    [self shouldStartDetectingGesture];
                }
            }
            
            self.beforeFourFingerTouches = [NSArray arrayWithObjects:[self.beforeFourFingerTouches objectAtIndex:1], [self.beforeFourFingerTouches objectAtIndex:2], [NSNumber numberWithInt:activeTouches], nil];
            
            [self.recentFourFingerTouches removeAllObjects];
		}
	}
}

- (CGEventRef)handleEvent:(CGEventRef)event withType:(int)type {
	if (self.appController.gestureSetupController.setupModel.multitouchOption) {
		if (self.recognitionView.detectingInput) {
			if (type == kCGEventKeyUp || type == kCGEventKeyDown) {
				[self.recognitionView finishDetectingGesture:YES];
				return event;
			}
			else {
				return NULL;
			}
		}
		else if (self.appController.gestureSetupController.setupView.detectingInput) {
			if (type == kCGEventKeyUp || type == kCGEventKeyDown) {
				[self.appController.gestureSetupController.setupView finishDetectingGesture:YES];
				return event;
			}
			else {
				return NULL;
			}
		}
	}
	else if (type == kCGEventRightMouseDown && self.recognitionWindow.alphaValue <= 0) {
		if ([[NSDate date] timeIntervalSinceDate:self.recentRightClickDate] * 1000 < 420) {
			[self shouldStartDetectingGesture];
            
			self.recentRightClickDate = [NSDate date];
		}
		else {
			self.recentRightClickDate = [NSDate date];
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
	[[NSAnimationContext currentContext] setDuration:0.16];
	[[NSAnimationContext currentContext] setCompletionHandler: ^{
	    [self toggleOutRecognitionWindow:NO];
	}];
	[self.recognitionWindow.animator setAlphaValue:0.0];
	[NSAnimationContext endGrouping];
}

- (void)toggleOutRecognitionWindow:(BOOL)fadeOut {
	if (fadeOut) {
        [self performSelector:@selector(fadeOutRecognitionWindow) withObject:nil afterDelay:0.38];
	}
	else {
		[self hideRecognitionWindow];
	}
}

- (void)toggleInRecognitionWindow {
	[self layoutRecognitionWindow];
    
	self.recognitionWindow.alphaValue = 1.0;
	[self.recognitionWindow orderFrontRegardless];
	[self.recognitionWindow makeKeyWindow];
}

- (void)hideRecognitionWindow {
	self.recognitionWindow.alphaValue = 0.0;
	[self.recognitionWindow orderOut:self];
	[self.recognitionWindow setFrameOrigin:NSMakePoint(-10000, -10000)];
	[NSApp hide:self];
}

- (void)windowDidResignKey:(NSNotification *)notification {
	if (self.recognitionWindow.alphaValue > 0) {
		if (self.recognitionView.detectingInput) {
			[self.recognitionView finishDetectingGesture:YES];
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
    
	if (self.appController.gestureSetupController.setupModel.fullscreenOption) {
		self.recognitionBackground.alphaValue = 0.91;
		self.recognitionBackground.roundRadius = 0;
	}
	else {
        windowRect.size.height /= 2.3;
        windowRect.size.width = windowRect.size.height * 3 / 2;
        windowRect.origin.x += (screenRect.size.width - windowRect.size.width) / 2;
        windowRect.origin.y += (screenRect.size.height - windowRect.size.height) / 2;
        
		self.recognitionBackground.alphaValue = 0.94;
		self.recognitionBackground.roundRadius = windowRect.size.height / 48;
	}
    
	[self.recognitionWindow setFrame:windowRect display:NO];
    
	NSRect recognitionRect = NSMakeRect(0, 0, windowRect.size.width, windowRect.size.height);
	[self.recognitionView setFrame:recognitionRect];
	[self.recognitionBackground setFrame:recognitionRect];
    
	NSRect alertIconRect = NSMakeRect((recognitionRect.size.width - (recognitionRect.size.height / 2)) / 2,
	                                  recognitionRect.size.height / 3.4,
	                                  recognitionRect.size.height / 2,
	                                  recognitionRect.size.height / 2);
	[self.appIconAlert setFrame:alertIconRect];
    
	NSRect alertDescriptionRect = NSMakeRect(0,
	                                         recognitionRect.size.height / 5.5,
	                                         recognitionRect.size.width,
	                                         recognitionRect.size.height / 12);
	[self.appDescriptionAlert setFont:[NSFont fontWithName:@"Lucida Grande" size:recognitionRect.size.width / 26]];
	[self.appDescriptionAlert setFrame:alertDescriptionRect];
    
	NSRect partialIconRect = NSMakeRect(recognitionRect.size.width / 40,
	                                    recognitionRect.size.width / 50,
	                                    recognitionRect.size.width / 6.4,
	                                    recognitionRect.size.width / 6.4);
	[self.partialIconAlert setFrame:partialIconRect];
    
	NSRect partialDescriptionRect = NSMakeRect(recognitionRect.size.width / 5,
	                                           recognitionRect.size.width / 40,
	                                           recognitionRect.size.width,
	                                           recognitionRect.size.width / 28);
	[self.partialDescriptionAlert setFont:[NSFont fontWithName:@"Lucida Grande" size:recognitionRect.size.width / 40]];
	[self.partialDescriptionAlert setFrame:partialDescriptionRect];
}

#pragma mark -

@end
