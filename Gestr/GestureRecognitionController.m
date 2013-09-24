#import "GestureRecognitionController.h"

@implementation GestureRecognitionController

@synthesize gesturesLoaded, recognitionView, recognitionWindow, appController, gestureDetector, updatedGestureDictionary, currentApp;

- (id)init {
	self = [super init];
    
	gestureDetector = [[GestureRecognizer alloc] init];
    
	[self fetchUpdatedGestureDictionary];
    
	@try {
		[updatedGestureDictionary enumerateKeysAndObjectsUsingBlock: ^(id plistGestureKey, Gesture *plistGesture, BOOL *shouldStop) {
		    if (plistGesture.name && plistGesture.strokes.count > 0) {
		        [gestureDetector addGesture:plistGesture];
			}
		    else {
		        @throw [NSException exceptionWithName:@"InvalidGesture" reason:@"Corrupted gesture data." userInfo:nil];
			}
		}];
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
	while ((screen = [screenEnum nextObject]) && !NSMouseInRect(mouseLoc, [screen frame], NO)) ;
    
	NSRect recognitionRect = [screen frame];
	[recognitionWindow setFrame:recognitionRect display:NO];
	recognitionRect.origin.x = 0;
	recognitionRect.origin.y = 0;
	[recognitionView setFrame:recognitionRect];
	[recognitionBackground setFrame:recognitionRect];
    
	NSRect alertDescriptionRect = NSMakeRect(recognitionRect.origin.x + (recognitionRect.size.height / 40), recognitionRect.size.height / 3, recognitionRect.size.width - 2 * (recognitionRect.size.height / 40), recognitionRect.size.height / 22);
	[appDescriptionAlert setFont:[NSFont fontWithName:@"Lucida Grande" size:recognitionRect.size.width / 52]];
	[appDescriptionAlert setFrame:alertDescriptionRect];
    
	NSSize alertIconSize = NSMakeSize(recognitionRect.size.width / 6, recognitionRect.size.width / 6);
	NSRect alertIconRect = NSMakeRect(recognitionRect.size.width / 2 - alertIconSize.width / 2, recognitionRect.size.height / 1.8 - alertIconSize.height / 2, alertIconSize.width, alertIconSize.height);
	[appIconAlert setFrame:alertIconRect];
    
	NSSize partialIconSize = NSMakeSize(recognitionRect.size.width / 10, recognitionRect.size.width / 10);
	NSRect partialIconRect = NSMakeRect(recognitionRect.size.width / 80 + partialIconSize.width / 10, recognitionRect.size.width / 80, partialIconSize.width, partialIconSize.height);
	[partialIconAlert setFrame:partialIconRect];
    
	NSRect partialDescriptionRect = NSMakeRect(2 * (recognitionRect.size.width / 80) + partialIconSize.width * 1.2, recognitionRect.size.width / 80 + partialIconSize.height / 10, recognitionRect.size.width - 2 * partialIconSize.width, recognitionRect.size.height / 30);
	[partialDescriptionAlert setFont:[NSFont fontWithName:@"Lucida Grande" size:recognitionRect.size.width / 72]];
	[partialDescriptionAlert setFrame:partialDescriptionRect];
}

- (void)awakeFromNib {
	[recognitionView setRecognitionController:self];
    
	[self layoutRecognitionWindow];
    
	[recognitionWindow setFrame:NSMakeRect(-10000, -10000, recognitionWindow.frame.size.width, recognitionWindow.frame.size.height) display:NO];
    
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
	eventTap = CGEventTapCreate(kCGHIDEventTap, kCGHeadInsertEventTap, kCGEventTapOptionListenOnly, kCGEventMaskForAllEvents, handleAllEvents, self);
	CFRunLoopSourceRef runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0);
	CFRunLoopAddSource(CFRunLoopGetMain(), runLoopSource, kCFRunLoopCommonModes);
	CGEventTapEnable(eventTap, true);
    
	[[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(applicationBecameActive:) name:NSWorkspaceDidActivateApplicationNotification object:nil];
    
    [[MultitouchManager sharedMultitouchManager] addMultitouchListenerWithTarget:self callback:@selector(handleMultitouchEvent:) andThread:nil];
}

- (void)checkFourFingerTouches
{
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
- (void)handleMultitouchEvent:(MultitouchEvent *)event
{
    if ([[self recognitionWindow] alphaValue] > 0.5) {
        return;
    }
    
    if (event && event.touches.count == 4 && ((MultitouchTouch *)[event.touches objectAtIndex:0]).state == multitouchTouchActive && ((MultitouchTouch *)[event.touches objectAtIndex:1]).state == multitouchTouchActive && ((MultitouchTouch *)[event.touches objectAtIndex:2]).state == multitouchTouchActive && ((MultitouchTouch *)[event.touches objectAtIndex:3]).state == multitouchTouchActive) {
        [fourFingerTouches addObject:event];
    } else if (fourFingerTouches.count > 0) {
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
    if ([[self recognitionWindow] alphaValue] > 0.5) {
        return;
    }
    
	if (type == kCGEventRightMouseDown) {
		if ([[NSDate date] timeIntervalSinceDate:lastRightClick] * 1000 < 400) {
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
	[(GestureRecognitionController *)refcon handleEvent : eventRef withType : (int)type];
    
	return eventRef;
}

- (void)shouldStartDetectingGesture {
	if ([[self recognitionWindow] alphaValue] < 0.5 && ([[gestureDetector loadedGestures] count] > 0)) {
        [appDescriptionAlert setStringValue:@""];
        [appIconAlert setImage:NULL];
        
        [partialDescriptionAlert setStringValue:@""];
        [partialIconAlert setImage:NULL];
        
		[self showGestureRecognitionWindow];
		[recognitionWindow makeKeyAndOrderFront:self];
		[recognitionWindow makeFirstResponder:recognitionView];
		[recognitionView startDetectingGesture];
	}
}

- (void)launchAppWithBundleId:(NSString *)bundle {
	@try {
		[[NSWorkspace sharedWorkspace] launchAppWithBundleIdentifier:bundle options:NSWorkspaceLaunchAllowingClassicStartup additionalEventParamDescriptor:nil launchIdentifier:nil];
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

- (void)hideGestureRecognitionWindow:(BOOL)fade {
	if (fade) {
        [NSThread sleepForTimeInterval:0.2];
        
		float alpha = 1.0;
		[recognitionWindow setAlphaValue:alpha];
		while ([recognitionWindow alphaValue] > 0.0) {
			alpha -= 0.03;
			[recognitionWindow setAlphaValue:alpha];
			[NSThread sleepForTimeInterval:0.01];
		}
        
		[[recognitionWindow parentWindow] removeChildWindow:recognitionWindow];
		[recognitionWindow orderOut:self];
	}
	else {
		[recognitionWindow orderOut:self];
		[recognitionWindow setAlphaValue:0.0];
	}
    
    [recognitionWindow setFrame:NSMakeRect(-10000, -10000, recognitionWindow.frame.size.width, recognitionWindow.frame.size.height) display:NO];
    [[NSApplication sharedApplication] hide:self];
}

- (void)showGestureRecognitionWindow {
	[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
	[self layoutRecognitionWindow];
	[recognitionWindow makeKeyAndOrderFront:self];
	[recognitionWindow setAlphaValue:1.0];
}

@end
