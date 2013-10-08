#import "GestureRecognitionController.h"

@implementation GestureRecognitionController

@synthesize gesturesLoaded, recognitionView, recognitionWindow, appController, gestureDetector, updatedGestureDictionary, currentApp, recognitionBackground;

- (id)init {
	self = [super init];
    
	gestureDetector = [[GestureRecognizer alloc] init];
    
	[self fetchUpdatedGestureDictionary];
    
	@try {
		if (!updatedGestureDictionary) {
			@throw [NSException exceptionWithName:@"InvalidGesture" reason:@"Corrupted gesture data." userInfo:nil];
		}
        
		for (id plistGestureKey in updatedGestureDictionary) {
			Gesture *plistGesture = [updatedGestureDictionary objectForKey:plistGestureKey];
			if (!plistGesture || !plistGesture.name || !plistGesture.strokes || plistGesture.strokes.count < 1) {
				@throw [NSException exceptionWithName:@"InvalidGesture" reason:@"Corrupted gesture data." userInfo:nil];
			}
			else {
				[gestureDetector addGesture:plistGesture];
			}
		}
	}
	@catch (NSException *exception)
	{
		updatedGestureDictionary = [NSMutableDictionary dictionary];
		[self saveUpdatedGestureDictionary];
        
		gestureDetector = [[GestureRecognizer alloc] init];
	}
    
	gesturesLoaded = YES;
    
	lastRightClick = [NSDate date];
    
	fourFingerTouches = [NSMutableArray array];
    
	return self;
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
	if (appController.gestureSetupController.fullscreenRecognition) {
        NSRect alertDescriptionRect = NSMakeRect(recognitionRect.origin.x + (recognitionRect.size.height / 40), recognitionRect.size.height / 3, recognitionRect.size.width - 2 * (recognitionRect.size.height / 40), recognitionRect.size.height / 22);
		[appDescriptionAlert setFont:[NSFont fontWithName:@"Lucida Grande" size:recognitionRect.size.width / 52]];
		[appDescriptionAlert setFrame:alertDescriptionRect];
        
		NSSize alertIconSize = NSMakeSize(recognitionRect.size.width / 6, recognitionRect.size.width / 6);
		NSRect alertIconRect = NSMakeRect(recognitionRect.size.width / 2 - alertIconSize.width / 2, recognitionRect.size.height / 1.9 - alertIconSize.height / 2, alertIconSize.width, alertIconSize.height);
		[appIconAlert setFrame:alertIconRect];
        
		[recognitionView setFrame:recognitionRect];
		[recognitionBackground setFrame:recognitionRect];
		[recognitionBackground setAlphaValue:0.88];
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
		[recognitionBackground setAlphaValue:0.93];
		((RepeatedImageView *)recognitionBackground).roundRadius = recognitionRect.size.height / 46;
        
		NSSize partialIconSize = NSMakeSize(recognitionRect.size.width / 7, recognitionRect.size.width / 7);
		NSRect partialIconRect = NSMakeRect(recognitionRect.size.width / 80 + partialIconSize.width / 10, recognitionRect.size.width / 80, partialIconSize.width, partialIconSize.height);
		[partialIconAlert setFrame:partialIconRect];
        
		NSRect partialDescriptionRect = NSMakeRect(2 * (recognitionRect.size.width / 80) + partialIconSize.width * 1.2, recognitionRect.size.width / 100, recognitionRect.size.width - 2 * partialIconSize.width, recognitionRect.size.height / 16);
		[partialDescriptionAlert setFont:[NSFont fontWithName:@"Lucida Grande" size:recognitionRect.size.width / 50]];
		[partialDescriptionAlert setFrame:partialDescriptionRect];
	}
}

- (void)awakeFromNib {
	[recognitionView setRecognitionController:self];
    
    [recognitionWindow setFrameOrigin:NSMakePoint(-10000, -10000)];
    
	[self setupActivationHanding];
}

- (void)fetchUpdatedGestureDictionary {
	NSMutableDictionary *gestures;
	@try {
		NSData *gestureData;
		if ((gestureData = [[NSUserDefaults standardUserDefaults] objectForKey:@"Gestures"])) {
			gestures = [NSMutableDictionary dictionaryWithDictionary:[NSKeyedUnarchiver unarchiveObjectWithData:gestureData]];
		}
		else {
			gestures = [NSMutableDictionary dictionary];
		}
	}
	@catch (NSException *exception)
	{
		gestures = [NSMutableDictionary dictionary];
	}
    
	updatedGestureDictionary = gestures;
    
	[self saveUpdatedGestureDictionary];
}

- (void)saveUpdatedGestureDictionary {
	[[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:updatedGestureDictionary] forKey:@"Gestures"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

CFMachPortRef eventTap;
- (void)setupActivationHanding {
	eventTap = CGEventTapCreate(kCGHIDEventTap, kCGHeadInsertEventTap, kCGEventTapOptionDefault, kCGEventMaskForAllEvents, handleAllEvents, self);
	CFRunLoopSourceRef runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0);
	CFRunLoopAddSource(CFRunLoopGetMain(), runLoopSource, kCFRunLoopCommonModes);
	CGEventTapEnable(eventTap, YES);
    
	[[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(applicationBecameActive:) name:NSWorkspaceDidActivateApplicationNotification object:nil];
    
	[[MultitouchManager sharedMultitouchManager] addMultitouchListenerWithTarget:self callback:@selector(handleMultitouchEvent:) andThread:nil];
}

- (void)checkFourFingerTouches {
	int totalCount = 0;
	float totalVelocity = 0.0f;
	for (MultitouchEvent *fourFingerEvent in fourFingerTouches) {
		for (MultitouchTouch *touch in fourFingerEvent.touches) {
			totalCount++;
			totalVelocity += (fabs(touch.velX) + fabs(touch.velY));
		}
	}
    
	[fourFingerTouches removeAllObjects];
    
	if (totalCount / 4 <= 30 && (totalVelocity / totalCount) <= 0.5) {
		[self shouldStartDetectingGesture];
	}
}

static int multitouchTouchActive = 4;
- (void)handleMultitouchEvent:(MultitouchEvent *)event {
	if ([[self recognitionWindow] alphaValue] > 0) {
		return;
	}
    
	if (event && event.touches.count == 4 && ((MultitouchTouch *)[event.touches objectAtIndex:0]).state == multitouchTouchActive && ((MultitouchTouch *)[event.touches objectAtIndex:1]).state == multitouchTouchActive && ((MultitouchTouch *)[event.touches objectAtIndex:2]).state == multitouchTouchActive && ((MultitouchTouch *)[event.touches objectAtIndex:3]).state == multitouchTouchActive) {
		[fourFingerTouches addObject:event];
	}
	else if (fourFingerTouches.count > 0) {
		[self checkFourFingerTouches];
	}
}

- (void)applicationBecameActive:(NSNotification *)notification {
	NSRunningApplication *newApp = ((NSRunningApplication *)[[notification userInfo] objectForKey:NSWorkspaceApplicationKey]);
	if (![newApp.bundleIdentifier isEqualToString:[NSRunningApplication currentApplication].bundleIdentifier]) {
		currentApp = newApp;
	}
}

NSDate *lastRightClick;

- (void)handleEvent:(CGEventRef)event withType:(int)type {
	if ([[self recognitionWindow] alphaValue] > 0) {
		return;
	}
    
	if (type == kCGEventRightMouseDown) {
		if ([[NSDate date] timeIntervalSinceDate:lastRightClick] * 1000 < 380) {
			[self shouldStartDetectingGesture];
			lastRightClick = [NSDate date];
			return;
		}
		else {
			lastRightClick = [NSDate date];
		}
	}
}

CGEventRef handleAllEvents(CGEventTapProxy proxy, CGEventType type, CGEventRef eventRef, void *refcon) {
	GestureRecognitionController *recognitionController = (GestureRecognitionController *)refcon;
    
	if (recognitionController.appController.gestureSetupController.multitouchRecognition && recognitionController.recognitionView.detectingInput) {
		if (type == kCGEventKeyUp || type == kCGEventKeyDown) {
			[recognitionController.recognitionView finishDetectingGesture:YES];
			return eventRef;
		}
		else {
			return NULL;
		}
	}
    
	[(GestureRecognitionController *)refcon handleEvent : eventRef withType : (int)type];
    
	return eventRef;
}

- (void)shouldStartDetectingGesture {
	if ([[self recognitionWindow] alphaValue] <= 0 && ([[gestureDetector loadedGestures] count] > 0)) {
		if ([self.appController.gestureSetupController.setupWindow alphaValue] > 0) {
			[self.appController.gestureSetupController toggleGestureSetupWindow:nil];
		}
        
		[appDescriptionAlert setStringValue:@""];
		[appIconAlert setImage:NULL];
        
		[partialDescriptionAlert setStringValue:@""];
		[partialIconAlert setImage:NULL];
        
        
		[self showGestureRecognitionWindow];
        
		[recognitionWindow makeFirstResponder:recognitionView];
		[recognitionView setNeedsDisplay:YES];
		[recognitionView startDetectingGesture];
	}
}

- (void)launchAppWithBundleId:(NSString *)bundle {
	@try {
		[[NSWorkspace sharedWorkspace] launchAppWithBundleIdentifier:bundle options:NSWorkspaceLaunchAsync additionalEventParamDescriptor:nil launchIdentifier:nil];
	}
	@catch (NSException *exception)
	{
		return;
	}
}

- (void)checkPartialGestureWithStrokes:(NSMutableArray *)strokes {
	GestureResult *result = [gestureDetector recognizeGestureWithStrokes:strokes];
	int rating;
	if (result && (rating = result.score) >= appController.gestureSetupController.successfulRecognitionScore) {
		App *appToShow = [appController.gestureSetupController appWithName:result.name];
		if (appToShow != nil) {
			[partialDescriptionAlert setStringValue:[NSString stringWithFormat:@"%@ - %i%%", appToShow.name, rating]];
			[partialIconAlert setImage:appToShow.icon];
		}
	}
	else {
		[partialDescriptionAlert setStringValue:@""];
		[partialIconAlert setImage:NULL];
	}
}

- (void)recognizeGestureWithStrokes:(NSMutableArray *)strokes {
	GestureResult *result = [gestureDetector recognizeGestureWithStrokes:strokes];
	int rating;
	if (result && (rating = result.score) >= appController.gestureSetupController.successfulRecognitionScore) {
		App *appToLaunch = [appController.gestureSetupController appWithName:result.name];
		if (appToLaunch != nil) {
			[appDescriptionAlert setStringValue:appToLaunch.name];
			[appIconAlert setImage:appToLaunch.icon];
            
			[partialDescriptionAlert setStringValue:[NSString stringWithFormat:@"%@ - %i%%", appToLaunch.name, rating]];
			[partialIconAlert setImage:appToLaunch.icon];
            
            [self launchAppWithBundleId:appToLaunch.bundle];
		}
		else {
			[appController.gestureSetupController deleteGestureWithName:result.name];
		}
        
		[self hideGestureRecognitionWindow:YES];
	}
	else {
		[self hideGestureRecognitionWindow:NO];
	}
}

- (void)fadeOutGestureRecognitionWindow {
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:0.18];
    [[NSAnimationContext currentContext] setCompletionHandler:^{
        [self hideGestureRecognitionWindow:NO];
    }];
    [[recognitionWindow animator] setAlphaValue:0.0];
    [NSAnimationContext endGrouping];
}

- (void)hideGestureRecognitionWindow:(BOOL)fade {
	if (fade) {
        [self performSelector:@selector(fadeOutGestureRecognitionWindow) withObject:nil afterDelay:0.34];
	} else {
        [recognitionWindow setAlphaValue:0.0];
        [recognitionWindow orderOut:self];
        [[recognitionWindow parentWindow] removeChildWindow:recognitionWindow];
        
        [recognitionWindow setFrameOrigin:NSMakePoint(-10000, -10000)];
        
        [[NSApplication sharedApplication] hide:self];
    }
}

- (void)showGestureRecognitionWindow {
    [recognitionWindow setAlphaValue:1.0];
	[self layoutRecognitionWindow];
    
	[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
	[recognitionWindow makeKeyAndOrderFront:self];
}

@end
