#import "GestureRecognitionController.h"

@interface GestureRecognitionController ()

@property BOOL awakedFromNib;

@property IBOutlet NSImageView *appIconAlert;
@property IBOutlet NSTextField *appDescriptionAlert;

@property IBOutlet NSImageView *partialIconAlert;
@property IBOutlet NSTextField *partialDescriptionAlert;

@property IBOutlet RoundedCornerView *backgroundView;

@property NSDate *recentRightClickDate;
@property NSArray *beforeFourFingerTouches;
@property NSMutableArray *recentFourFingerTouches;

@property int threeFingerTouchCount;

@property NSTimer *disableScrollBlockingTimer;
@property BOOL blockingScrollEvents;

@end

@implementation GestureRecognitionController

#pragma mark -
#pragma mark Initialization
- (void)awakeFromNib {
	if (!_awakedFromNib) {
		_awakedFromNib = YES;

		_recognitionView.recognitionController = self;

		[self hideRecognitionWindow];

		_recognitionModel = [[GestureRecognitionModel alloc] init];
		[_recognitionModel setup];

		_recentRightClickDate = [NSDate date];
		_beforeFourFingerTouches = @[@0, @0, @0];
		_recentFourFingerTouches = [NSMutableArray array];
		_threeFingerTouchCount = 0;
	}
}

- (void)applicationDidFinishLaunching {
	eventHandler = CGEventTapCreate(
        kCGHIDEventTap,
        kCGHeadInsertEventTap,
        kCGEventTapOptionDefault,
        kCGEventMaskForAllEvents,
        handleEvent,
        (__bridge void *)(self)
    );

    CFRunLoopSourceRef runLoopSource =
        CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventHandler, 0);

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
    [_partialDescriptionAlert performSelectorOnMainThread:@selector(setStringValue:) withObject:@"" waitUntilDone:YES];
    [_partialIconAlert performSelectorOnMainThread:@selector(setImage:) withObject:nil waitUntilDone:YES];

	GestureResult *result = [_recognitionModel.gestureDetector recognizeGestureWithStrokes:strokes];
	int rating;
	if (result && (rating = result.score) >= _appController.gestureSetupController.setupModel.minimumRecognitionScore) {
		Launchable *launchableToShow = [_appController.gestureSetupController.setupModel findLaunchableWithId:result.gestureIdentity];
		if (launchableToShow != nil) {
            [_partialDescriptionAlert performSelectorOnMainThread:@selector(setStringValue:) withObject:[NSString stringWithFormat:@"%@ - %i%%", launchableToShow.displayName, rating] waitUntilDone:YES];
            [_partialIconAlert performSelectorOnMainThread:@selector(setImage:) withObject:launchableToShow.icon waitUntilDone:YES];
		}
		else {
			[_recognitionModel deleteGestureWithName:result.gestureIdentity];
		}
	}
}

- (void)recognizeGestureWithStrokes:(NSMutableArray *)strokes {
	_partialDescriptionAlert.stringValue = @"";
	_partialIconAlert.image = nil;

	GestureResult *result = [_recognitionModel.gestureDetector recognizeGestureWithStrokes:strokes];
	int rating;
	if (result && (rating = result.score) >= _appController.gestureSetupController.setupModel.minimumRecognitionScore) {
		Launchable *launchableToLaunch = [_appController.gestureSetupController.setupModel findLaunchableWithId:result.gestureIdentity];
		if (launchableToLaunch != nil) {
			_appDescriptionAlert.stringValue = launchableToLaunch.displayName;
			_appIconAlert.image = launchableToLaunch.icon;

			[launchableToLaunch launchWithNewThread:YES];
		}
		else {
			[_recognitionModel deleteGestureWithName:result.gestureIdentity];
		}

		[self toggleOutRecognitionWindow:YES];
	}
	else {
		[self toggleOutRecognitionWindow:NO];
	}

	_disableScrollBlockingTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(disableScrollEventBlocking) userInfo:nil repeats:NO];
}

- (void)shouldStartDetectingGesture:(BOOL)quick {
	if (_recognitionWindow.alphaValue <= 0) {
		if (_disableScrollBlockingTimer) {
			[_disableScrollBlockingTimer invalidate];
			_disableScrollBlockingTimer = nil;
		}
		_blockingScrollEvents = YES;

		_appDescriptionAlert.stringValue = @"";
		_appIconAlert.image = nil;

		_partialDescriptionAlert.stringValue = @"";
		_partialIconAlert.image = nil;

		[self toggleInRecognitionWindow];

		[_recognitionView startDetectingGesture:quick];
	}
}

- (void)disableScrollEventBlocking {
	_blockingScrollEvents = NO;
}

#pragma mark -

#pragma mark -
#pragma mark Activation Event Handling
- (void)handleMultitouchEvent:(MultitouchEvent *)event {
	if (_recognitionWindow.alphaValue <= 0) {
		if (event.touches.count == 4) {
			[_recentFourFingerTouches addObject:event];
		}
		else {
			if (_recentFourFingerTouches.count >= 4 && _recentFourFingerTouches.count <= 30) {
				int totalCount = 0;
				float totalVelocity = 0.0f;
				for (MultitouchEvent *fourFingerEvent in _recentFourFingerTouches) {
					for (MultitouchTouch *touch in fourFingerEvent.touches) {
						totalCount++;
						totalVelocity += (fabs(touch.velX) + fabs(touch.velY));
					}
				}

				NSCountedSet *countedBeforeFourFingerTouches = [[NSCountedSet alloc] initWithArray:_beforeFourFingerTouches];
				if ((totalVelocity / totalCount) <= 0.46 && [countedBeforeFourFingerTouches countForObject:@3] < 3 && [countedBeforeFourFingerTouches countForObject:@5] < 3) {
					[self shouldStartDetectingGesture:NO];
				}
			}

			_beforeFourFingerTouches = @[_beforeFourFingerTouches[1], _beforeFourFingerTouches[2], @(event.touches.count)];

			[_recentFourFingerTouches removeAllObjects];
		}

		if (_appController.gestureSetupController.setupModel.quickdrawOption && event.touches.count == 3 && _recentFourFingerTouches.count == 0 && _appController.gestureSetupController.setupWindow.alphaValue <= 0) {
			if (++_threeFingerTouchCount >= 6 && _threeFingerTouchCount <= 50) {
				int totalCount = 0;
				float totalVelocity = 0.0f;
				NSMutableArray *velocities = [NSMutableArray array];
				for (MultitouchTouch *touch in event.touches) {
					totalCount++;
					totalVelocity += (fabs(touch.velX) + fabs(touch.velY));

					[velocities addObject:@(sqrtf(touch.velX * touch.velX + touch.velY * touch.velY))];
				}
				NSArray *orderedVelocites = [velocities sortedArrayUsingSelector:@selector(compare:)];
				float initalVelocitiesRatio = [orderedVelocites[1] floatValue] / ([orderedVelocites[0] floatValue]);

				if ((totalVelocity / totalCount) >= 0.3 && initalVelocitiesRatio <= 1.5) {
					_threeFingerTouchCount = 0;
					[self shouldStartDetectingGesture:YES];
				}
			}
		}
		else {
			_threeFingerTouchCount = 0;
		}
	}
}

- (CGEventRef)handleEvent:(CGEventRef)event withType:(int)type {
	if (_appController.gestureSetupController.setupModel.multitouchOption) {
		if (_recognitionView.detectingInput || (type == kCGEventScrollWheel && (_recognitionWindow.alphaValue > 0 || (_blockingScrollEvents && CGEventGetIntegerValueField(event, kCGScrollWheelEventScrollCount) > 0)))) {
			return NULL;
		}
	}
	else if (type == kCGEventRightMouseDown && _recognitionWindow.alphaValue <= 0) {
		if ([[NSDate date] timeIntervalSinceDate:_recentRightClickDate] * 1000 < 420) {
			[self shouldStartDetectingGesture:NO];

			_recentRightClickDate = [NSDate date];
		}
		else {
			_recentRightClickDate = [NSDate date];
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

	return [(__bridge GestureRecognitionController *)refcon handleEvent : eventRef withType : (int)type];
}

#pragma mark -

#pragma mark -
#pragma mark Window Methods
- (void)fadeOutRecognitionWindow {
	[NSAnimationContext beginGrouping];
	[[NSAnimationContext currentContext] setDuration:0.2];
	[[NSAnimationContext currentContext] setCompletionHandler: ^{
	    [self toggleOutRecognitionWindow:NO];
	}];
	[_recognitionWindow.animator setAlphaValue:0.0];
	[NSAnimationContext endGrouping];
}

- (void)toggleOutRecognitionWindow:(BOOL)fadeOut {
	if (fadeOut) {
		[self performSelector:@selector(fadeOutRecognitionWindow) withObject:nil afterDelay:0.28];
	}
	else {
		[self hideRecognitionWindow];
	}
}

- (void)toggleInRecognitionWindow {
	[self layoutRecognitionWindow];

	_recognitionWindow.alphaValue = 1.0;
	[_recognitionWindow orderFrontRegardless];
	[_recognitionWindow makeKeyWindow];
}

- (void)hideRecognitionWindow {
	_recognitionWindow.alphaValue = 0.0;
	[_recognitionWindow orderOut:self];
	[_recognitionWindow setFrameOrigin:NSMakePoint(-10000, -10000)];
	[NSApp hide:self];
}

- (void)windowDidResignKey:(NSNotification *)notification {
	if (_recognitionWindow.alphaValue > 0) {
		if (_recognitionView.detectingInput) {
			[_recognitionView finishDetectingGesture:YES];
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

	if (_appController.gestureSetupController.setupModel.fullscreenOption) {
		_backgroundView.alphaValue = 0.92;
		_backgroundView.roundRadius = 0;
	}
	else {
		windowRect.size.height /= 2.3;
		windowRect.size.width = windowRect.size.height * 3 / 2;
		windowRect.origin.x += (screenRect.size.width - windowRect.size.width) / 2;
		windowRect.origin.y += (screenRect.size.height - windowRect.size.height) / 2;

		_backgroundView.alphaValue = 0.87;
		_backgroundView.roundRadius = windowRect.size.height / 48;
	}

	[_recognitionWindow setFrame:windowRect display:NO];

	NSRect recognitionRect = NSMakeRect(0, 0, windowRect.size.width, windowRect.size.height);
	[_recognitionView setFrame:recognitionRect];
	[_backgroundView setFrame:recognitionRect];

	NSRect alertIconRect = NSMakeRect((recognitionRect.size.width - (recognitionRect.size.height / 2)) / 2,
	                                  recognitionRect.size.height / 3.4,
	                                  recognitionRect.size.height / 2,
	                                  recognitionRect.size.height / 2);
	[_appIconAlert setFrame:alertIconRect];

	NSRect alertDescriptionRect = NSMakeRect(0,
	                                         recognitionRect.size.height / 5.5,
	                                         recognitionRect.size.width,
	                                         recognitionRect.size.height / 12);
	[_appDescriptionAlert setFont:[NSFont fontWithName:@"Lucida Grande" size:recognitionRect.size.width / 26]];
	[_appDescriptionAlert setFrame:alertDescriptionRect];

	NSRect partialIconRect = NSMakeRect(recognitionRect.size.width / 40,
	                                    recognitionRect.size.width / 50,
	                                    recognitionRect.size.width / 6.4,
	                                    recognitionRect.size.width / 6.4);
	[_partialIconAlert setFrame:partialIconRect];

	NSRect partialDescriptionRect = NSMakeRect(recognitionRect.size.width / 5,
	                                           recognitionRect.size.width / 40,
	                                           recognitionRect.size.width,
	                                           recognitionRect.size.width / 28);
	[_partialDescriptionAlert setFont:[NSFont fontWithName:@"Lucida Grande" size:recognitionRect.size.width / 40]];
	[_partialDescriptionAlert setFrame:partialDescriptionRect];
}

#pragma mark -

@end
