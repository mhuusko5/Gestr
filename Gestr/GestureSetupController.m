#import "GestureSetupController.h"

@implementation GestureSetupController

@synthesize drawNowText, multitouchRecognition, fullscreenRecognition, successfulRecognitionScore, readingDelayNumber, setupView, setupWindow, appController;

- (id)init {
	self = [super init];
    
	id storedSuccessfulRecognitionScore;
	if ((storedSuccessfulRecognitionScore = [[NSUserDefaults standardUserDefaults] objectForKey:@"successfulRecognitionScore"])) {
		successfulRecognitionScore = [storedSuccessfulRecognitionScore intValue];
	}
	else {
		[[NSUserDefaults standardUserDefaults] setInteger:(successfulRecognitionScore = 80) forKey:@"successfulRecognitionScore"];
	}
    
	id storedReadingDelayNumber;
	if ((storedReadingDelayNumber = [[NSUserDefaults standardUserDefaults] objectForKey:@"readingDelayNumber"])) {
		readingDelayNumber = [storedReadingDelayNumber intValue];
	}
	else {
		[[NSUserDefaults standardUserDefaults] setInteger:(readingDelayNumber = 5) forKey:@"readingDelayNumber"];
	}
    
	id storedMultitouchRecognition;
	if ((storedMultitouchRecognition = [[NSUserDefaults standardUserDefaults] objectForKey:@"multitouchRecognition"])) {
		multitouchRecognition = [storedMultitouchRecognition boolValue];
	}
	else {
		[[NSUserDefaults standardUserDefaults] setBool:(multitouchRecognition = [MultitouchManager systemIsMultitouchCapable]) forKey:@"multitouchRecognition"];
	}
    
	id storedFullscreenRecognition;
	if ((storedFullscreenRecognition = [[NSUserDefaults standardUserDefaults] objectForKey:@"fullscreenRecognition"])) {
		fullscreenRecognition = [storedFullscreenRecognition boolValue];
	}
	else {
		[[NSUserDefaults standardUserDefaults] setBool:(fullscreenRecognition = NO) forKey:@"fullscreenRecognition"];
	}
    
	id storedHideDockIcon;
	if ((storedHideDockIcon = [[NSUserDefaults standardUserDefaults] objectForKey:@"hideDockIcon"])) {
		hideDockIcon = [storedHideDockIcon boolValue];
	}
	else {
		[[NSUserDefaults standardUserDefaults] setBool:(hideDockIcon = NO) forKey:@"hideDockIcon"];
	}
    
	startAtLaunch = [self willStartAtLaunch];
    
	[self updateHideDockIcon];
	[self updateStartAtLaunch];
    
	[[NSUserDefaults standardUserDefaults] synchronize];
    
	[self loadApps];
    
	return self;
}

- (void)loadApps {
	appArray = [NSMutableArray array];
	[self addAppsAtPath:@"/Applications" toArray:appArray levels:1];
	appArray = [NSMutableArray arrayWithArray:[appArray sortedArrayUsingComparator: ^NSComparisonResult (App *a, App *b) {
	    NSComparisonResult *result = [b.lastUsed compare:a.lastUsed];
	    if (result == NSOrderedSame) {
	        return [[NSNumber numberWithInt:b.useCount] compare:[NSNumber numberWithInt:a.useCount]];
		}
        
	    return result;
	}
                                               
                                               ]];
    
	utilitiesArray = [NSMutableArray array];
	[self addAppsAtPath:@"/Applications/Utilities" toArray:utilitiesArray levels:1];
	utilitiesArray = [NSMutableArray arrayWithArray:[utilitiesArray sortedArrayUsingComparator: ^NSComparisonResult (App *a, App *b) {
	    NSComparisonResult *result = [b.lastUsed compare:a.lastUsed];
	    if (result == NSOrderedSame) {
	        return [[NSNumber numberWithInt:b.useCount] compare:[NSNumber numberWithInt:a.useCount]];
		}
        
	    return result;
	}
                                                     
                                                     ]];
    
	systemArray = [NSMutableArray array];
	[self addAppsAtPath:@"/System/Library/CoreServices" toArray:systemArray levels:0];
	systemArray = [NSMutableArray arrayWithArray:[systemArray sortedArrayUsingComparator: ^NSComparisonResult (App *a, App *b) {
	    NSComparisonResult *result = [b.lastUsed compare:a.lastUsed];
	    if ([a.name isEqualToString:@"Finder"]) {
	        result = NSOrderedAscending;
		}
	    else if ([b.name isEqualToString:@"Finder"]) {
	        result = NSOrderedDescending;
		}
        
	    if (result == NSOrderedSame) {
	        return [[NSNumber numberWithInt:b.useCount] compare:[NSNumber numberWithInt:a.useCount]];
		}
        
	    return result;
	}
                                                  
                                                  ]];
}

- (void)addAppsAtPath:(NSString *)path toArray:(NSMutableArray *)arr levels:(int)l {
	NSURL *url;
	if (!(url = [NSURL URLWithString:[path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]])) {
		return;
	}
    
	NSURL *file;
	NSDirectoryEnumerator *directoryEnumerator = [[NSFileManager defaultManager] enumeratorAtURL:url includingPropertiesForKeys:nil options:(NSDirectoryEnumerationSkipsSubdirectoryDescendants | NSDirectoryEnumerationSkipsPackageDescendants | NSDirectoryEnumerationSkipsHiddenFiles) errorHandler:nil];
    
	while (file = [directoryEnumerator nextObject]) {
		if ([[file pathExtension] isEqualToString:@"app"]) {
			NSDictionary *dict = [[NSBundle bundleWithPath:[file path]] infoDictionary];
            
			NSString *name = [dict objectForKey:@"CFBundleName"];
			if (!name) {
				name = [dict objectForKey:@"CFBundleExecutable"];
			}
            
			if (![name isEqualToString:@"Gestr"]) {
				NSImage *icon = nil;
				@try {
					icon = [[NSWorkspace sharedWorkspace] iconForFile:[file path]];
				}
				@catch (NSException *ex)
				{
					icon = [NSImage imageNamed:@"noIcon.png"];
				}
                
				NSDate *lastUsed = nil;
				int useCount = 0;
				@try {
					MDItemRef item = MDItemCreate(kCFAllocatorDefault, (CFStringRef)[file path]);
					CFArrayRef attributeNames = MDItemCopyAttributeNames(item);
					NSArray *array = (NSArray *)attributeNames;
					NSEnumerator *e = [array objectEnumerator];
					id arrayObject;
					while ((arrayObject = [e nextObject])) {
						CFTypeRef ref = MDItemCopyAttribute(item, (CFStringRef)[arrayObject description]);
						NSObject *tempObject = (NSObject *)ref;
                        
						if ([arrayObject isEqualToString:@"kMDItemLastUsedDate"]) {
							lastUsed = [tempObject copy];
						}
						else if ([arrayObject isEqualToString:@"kMDItemUseCount"]) {
							useCount = (int)tempObject;
						}
						if (ref != NULL) {
							CFRelease(ref);
						}
					}
                    
					if (attributeNames != NULL) {
						CFRelease(attributeNames);
					}
				}
				@catch (NSException *exception)
				{
					lastUsed = nil;
					useCount = 0;
				}
                
				if (name && ![name isEqualToString:@"(null)"]) {
					[arr addObject:[[App alloc] initWithName:name andIcon:icon andBundle:[dict objectForKey:@"CFBundleIdentifier"] andLastUsed:lastUsed andUseCount:useCount]];
				}
			}
		}
		else if ([[file pathExtension] isEqualToString:@""] && l > 0 && ![[file path] isEqualToString:@"/Applications/Utilities"]) {
			[self addAppsAtPath:[file path] toArray:arr levels:l - 1];
		}
	}
}

BOOL awakenedFromNib = NO;

- (void)awakeFromNib {
	if (!awakenedFromNib) {
		awakenedFromNib = YES;
        
		[setupView setSetupController:self];
        
        [setupWindow setFrameOrigin:NSMakePoint(-10000, -10000)];
        
		statusBarItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
		[statusBarItem setTitle:@""];
		[statusBarView setAlphaValue:1.0];
		[statusBarItem setView:statusBarView];
        
		[appTypePicker setSelectedSegment:0];
        
		[successfulRecognitionScoreTextField setStringValue:[NSString stringWithFormat:@"%i", successfulRecognitionScore]];
		[readingDelayTextField setStringValue:[NSString stringWithFormat:@"%i", readingDelayNumber]];
		[multitouchCheckbox setState:multitouchRecognition];
		[fullscreenCheckbox setState:fullscreenRecognition];
		[hideDockIconCheckbox setState:hideDockIcon];
		[startAtLaunchCheckbox setState:startAtLaunch];
        
		[self performSelector:@selector(delayedAwake) withObject:nil afterDelay:0.5];
	}
}

- (void)showUpdateAlert:(NSString *)version {
	NSAlert *infoAlert = [[NSAlert alloc] init];
	[infoAlert addButtonWithTitle:@"Will do!"];
	[infoAlert setMessageText:[NSString stringWithFormat:@"Head over to mhuusko5.com for version %@ of Gestr!", version]];
	[infoAlert setAlertStyle:NSInformationalAlertStyle];
	[infoAlert beginSheetModalForWindow:setupWindow modalDelegate:self didEndSelector:nil contextInfo:nil];
}

- (void)checkForUpdate:(BOOL)async {
	if (!checkedForUpdate) {
		if (async) {
			[NSThread detachNewThreadSelector:@selector(checkForUpdate:) toTarget:self withObject:NO];
			return;
		}
		else {
			checkedForUpdate = YES;
            
			@try {
				NSString *updatedVersionString = [NSString stringWithContentsOfURL:[[NSURL alloc] initWithString:@"http://mhuusko5.com/gestrVersion"] encoding:NSUTF8StringEncoding error:nil];
				float updatedVersion = [updatedVersionString floatValue];
				float thisVersion = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] floatValue];
				if (updatedVersion > thisVersion) {
					if ([setupWindow alphaValue] <= 0) {
						[self performSelectorOnMainThread:@selector(toggleGestureSetupWindow:) withObject:nil waitUntilDone:YES];
					}
					[self performSelectorOnMainThread:@selector(showUpdateAlert:) withObject:[NSString stringWithFormat:@"%g", updatedVersion] waitUntilDone:NO];
				}
			}
			@catch (NSException *exception)
			{
			}
		}
	}
}

- (void)delayedAwake {
	if (self.appController.gestureRecognitionController.gesturesLoaded) {
		if (self.appController.gestureRecognitionController.gestureDetector.loadedGestures.count < 1) {
			[self toggleGestureSetupWindow:nil];
		}
        
        [appController.gestureRecognitionController layoutRecognitionWindow];
        [appController.gestureRecognitionController.recognitionWindow  setFrameOrigin:NSMakePoint(-10000, -10000)];
	}
	else {
		[self performSelector:@selector(delayedAwake) withObject:nil afterDelay:0.5];
	}
    
	[self updateSetupControls];
}

- (void)saveGestureWithStrokes:(NSMutableArray *)gestureStrokes {
	for (GestureStroke *stroke in gestureStrokes) {
		if ([stroke.points count] < minimumPointCount) {
			NSAlert *infoAlert = [[NSAlert alloc] init];
			[infoAlert addButtonWithTitle:@"Ok, then"];
			[infoAlert setMessageText:@"Please make your gesture strokes a tad longer..."];
			[infoAlert setAlertStyle:NSInformationalAlertStyle];
			[infoAlert beginSheetModalForWindow:setupWindow modalDelegate:self didEndSelector:nil contextInfo:nil];
			return;
		}
	}
    
	App *gestureToSaveApp = [[self currentAppArray] objectAtIndex:[[self currentTableView] selectedRow]];
	Gesture *gestureToSave = [[Gesture alloc] initWithName:gestureToSaveApp.name andStrokes:gestureStrokes];
    
	[appController.gestureRecognitionController.updatedGestureDictionary setObject:gestureToSave forKey:gestureToSaveApp.name];
    
	[appController.gestureRecognitionController saveUpdatedGestureDictionary];
    
	[[[appController gestureRecognitionController] gestureDetector] addGesture:gestureToSave];
    
	[self updateSetupControls];
}

- (void)deleteGestureWithName:(NSString *)name {
	[appController.gestureRecognitionController.updatedGestureDictionary removeObjectForKey:name];
    
	[appController.gestureRecognitionController saveUpdatedGestureDictionary];
    
	[[[appController gestureRecognitionController] gestureDetector] removeGestureWithName:name];
}

- (App *)appWithName:(NSString *)name {
	for (App *app in appArray) {
		if ([[app name] isEqualTo:name]) {
			return app;
		}
	}
    
	for (App *app in utilitiesArray) {
		if ([[app name] isEqualTo:name]) {
			return app;
		}
	}
    
	for (App *app in systemArray) {
		if ([[app name] isEqualTo:name]) {
			return app;
		}
	}
    
	return nil;
}

- (NSMutableArray *)currentAppArray {
	switch ([appTypePicker selectedSegment]) {
		case 0:
			return appArray;
			break;
            
		case 1:
			return utilitiesArray;
			break;
            
		case 2:
			return systemArray;
			break;
            
		default:
			return appArray;
			break;
	}
}

- (NSTableView *)currentTableView {
	return appTableView;
}

- (IBAction)successfulRecognitionScoreChanged:(id)sender {
	int newScore = [successfulRecognitionScoreTextField intValue];
	if (!(newScore >= 70 && newScore <= 100)) {
		newScore = successfulRecognitionScore;
        
		NSAlert *infoAlert = [[NSAlert alloc] init];
		[infoAlert addButtonWithTitle:@"Sure"];
		[infoAlert setMessageText:@"It's better to set a score between 70 and 100..."];
		[infoAlert setAlertStyle:NSInformationalAlertStyle];
		[infoAlert beginSheetModalForWindow:setupWindow modalDelegate:self didEndSelector:nil contextInfo:nil];
	}
    
	[[NSUserDefaults standardUserDefaults] setInteger:(successfulRecognitionScore = newScore) forKey:@"successfulRecognitionScore"];
	[successfulRecognitionScoreTextField setStringValue:[NSString stringWithFormat:@"%i", successfulRecognitionScore]];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)useMultitouchOptionChanged:(id)sender {
	BOOL newMultitouchOption = (BOOL)[multitouchCheckbox state];
    
	[[NSUserDefaults standardUserDefaults] setBool:(multitouchRecognition = newMultitouchOption) forKey:@"multitouchRecognition"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)fullscreenOptionChanged:(id)sender {
	BOOL newFullscreenOption = (BOOL)[fullscreenCheckbox state];
    
	[[NSUserDefaults standardUserDefaults] setBool:(fullscreenRecognition = newFullscreenOption) forKey:@"fullscreenRecognition"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)updateHideDockIcon {
	ProcessSerialNumber psn = { 0, kCurrentProcess };
	if (hideDockIcon) {
		TransformProcessType(&psn, kProcessTransformToUIElementApplication);
	}
	else {
		TransformProcessType(&psn, kProcessTransformToForegroundApplication);
	}
}

- (void)updateStartAtLaunch {
	NSURL *itemURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
    
	OSStatus status;
	LSSharedFileListItemRef existingItem = NULL;
    
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
	if (loginItems) {
		UInt32 seed = 0U;
		NSArray *currentLoginItems = [NSMakeCollectable(LSSharedFileListCopySnapshot(loginItems, &seed)) autorelease];
		for (id itemObject in currentLoginItems) {
			LSSharedFileListItemRef item = (LSSharedFileListItemRef)itemObject;
            
			UInt32 resolutionFlags = kLSSharedFileListNoUserInteraction | kLSSharedFileListDoNotMountVolumes;
			CFURLRef URL = NULL;
			OSStatus err = LSSharedFileListItemResolve(item, resolutionFlags, &URL, /*outRef*/ NULL);
			if (err == noErr) {
				Boolean foundIt = CFEqual(URL, itemURL);
				CFRelease(URL);
                
				if (foundIt) {
					existingItem = item;
					break;
				}
			}
		}
        
		if (startAtLaunch && (existingItem == NULL)) {
			LSSharedFileListInsertItemURL(loginItems, kLSSharedFileListItemBeforeFirst, NULL, NULL, (CFURLRef)itemURL, NULL, NULL);
		}
		else if (!startAtLaunch && (existingItem != NULL)) {
			LSSharedFileListItemRemove(loginItems, existingItem);
		}
        
		CFRelease(loginItems);
	}
}

- (BOOL)willStartAtLaunch {
	NSURL *itemURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
    
	Boolean foundIt = false;
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
	if (loginItems) {
		UInt32 seed = 0U;
		NSArray *currentLoginItems = [NSMakeCollectable(LSSharedFileListCopySnapshot(loginItems, &seed)) autorelease];
		for (id itemObject in currentLoginItems) {
			LSSharedFileListItemRef item = (LSSharedFileListItemRef)itemObject;
            
			UInt32 resolutionFlags = kLSSharedFileListNoUserInteraction | kLSSharedFileListDoNotMountVolumes;
			CFURLRef URL = NULL;
			OSStatus err = LSSharedFileListItemResolve(item, resolutionFlags, &URL, /*outRef*/ NULL);
			if (err == noErr) {
				foundIt = CFEqual(URL, itemURL);
				CFRelease(URL);
                
				if (foundIt)
					break;
			}
		}
		CFRelease(loginItems);
	}
	return (BOOL)foundIt;
}

- (IBAction)hideIconOptionChanged:(id)sender {
	BOOL newHideDockIconOption = (BOOL)[hideDockIconCheckbox state];
    
	[[NSUserDefaults standardUserDefaults] setBool:(hideDockIcon = newHideDockIconOption) forKey:@"hideDockIcon"];
	[hideDockIconCheckbox setState:hideDockIcon];
	[[NSUserDefaults standardUserDefaults] synchronize];
    
	[self updateHideDockIcon];
    
	if (hideDockIcon) {
		[[NSApplication sharedApplication] performSelector:@selector(activateIgnoringOtherApps:) withObject:YES afterDelay:0.005];
		[[NSApplication sharedApplication] performSelector:@selector(activateIgnoringOtherApps:) withObject:YES afterDelay:0.01];
		[[NSApplication sharedApplication] performSelector:@selector(activateIgnoringOtherApps:) withObject:YES afterDelay:0.1];
		[[NSApplication sharedApplication] performSelector:@selector(activateIgnoringOtherApps:) withObject:YES afterDelay:0.25];
		[[NSApplication sharedApplication] performSelector:@selector(activateIgnoringOtherApps:) withObject:YES afterDelay:0.5];
	}
}

- (IBAction)loginStartOptionChanged:(id)sender {
	startAtLaunch = (BOOL)[startAtLaunchCheckbox state];
    
	[self updateStartAtLaunch];
    
	[startAtLaunchCheckbox setState:startAtLaunch];
}

- (IBAction)readingDelayNumberChanged:(id)sender {
	int newNum = [readingDelayTextField intValue];
	if (!(newNum >= 1 && newNum <= 1000)) {
		newNum = readingDelayNumber;
		NSAlert *infoAlert = [[NSAlert alloc] init];
		[infoAlert addButtonWithTitle:@"Okay"];
		[infoAlert setMessageText:@"Somewhere between 1 and 1000 milliseconds is more reasonable..."];
		[infoAlert setAlertStyle:NSInformationalAlertStyle];
		[infoAlert beginSheetModalForWindow:setupWindow modalDelegate:self didEndSelector:nil contextInfo:nil];
	}
    
	[[NSUserDefaults standardUserDefaults] setInteger:(readingDelayNumber = newNum) forKey:@"readingDelayNumber"];
	[readingDelayTextField setStringValue:[NSString stringWithFormat:@"%i", readingDelayNumber]];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)deleteSelectedGesture:(id)sender {
	if (selectedIndex >= 0) {
		NSString *appDescription = [[[self currentAppArray] objectAtIndex:selectedIndex] name];
		[self deleteGestureWithName:appDescription];
	}
    
	[self updateSetupControls];
}

- (IBAction)showSelectedGesture:(id)sender {
	if (showGestureThread) {
		[showGestureThread cancel];
		showGestureThread = nil;
	}
    
	if (selectedIndex >= 0) {
		NSString *appDescription = [[[self currentAppArray] objectAtIndex:selectedIndex] name];
        
		@try {
			Gesture *gestureToShow = [appController.gestureRecognitionController.updatedGestureDictionary objectForKey:appDescription];
			showGestureThread = [[NSThread alloc] initWithTarget:setupView selector:@selector(showGesture:) object:gestureToShow];
			[showGestureThread start];
		}
		@catch (NSException *exception)
		{
		}
	}
}

- (IBAction)assignSelectedGesture:(id)sender {
	[setupWindow makeKeyAndOrderFront:self];
	[setupWindow makeFirstResponder:setupWindow];
	[setupView startDetectingGesture];
}

- (void)tableViewFocus:(BOOL)lost {
	if (lost) {
		[showGestureButton setEnabled:NO];
		[assignGestureButton setEnabled:NO];
		[deleteGestureButton setEnabled:NO];
	}
	else {
		[self updateSetupControls];
	}
}

- (IBAction)appTypeChanged:(id)sender {
	switch ([appTypePicker selectedSegment]) {
		case 0:
			[appArrayController setContent:appArray];
			break;
            
		case 1:
			[appArrayController setContent:utilitiesArray];
			break;
            
		case 2:
			[appArrayController setContent:systemArray];
			break;
            
		default:
			break;
	}
    
	[showGestureButton setEnabled:NO];
	[assignGestureButton setEnabled:NO];
	[deleteGestureButton setEnabled:NO];
}

- (void)updateSetupControls {
	[setupView resetAll];
    
	[setupWindow makeFirstResponder:[self currentTableView]];
    
	selectedIndex = (int)([[self currentTableView] selectedRow]);
    
	if (selectedIndex >= 0) {
		NSString *appDescription = [[[self currentAppArray] objectAtIndex:selectedIndex] name];
        
		BOOL gestureExistsForSelectedApp = NO;
        
		gestureExistsForSelectedApp = ([appController.gestureRecognitionController.updatedGestureDictionary objectForKey:appDescription] != nil);
        
		if ([[NSApplication sharedApplication] isActive]) {
			if (gestureExistsForSelectedApp) {
				[showGestureButton setEnabled:YES];
				[assignGestureButton setEnabled:YES];
				[deleteGestureButton setEnabled:YES];
			}
			else {
				[showGestureButton setEnabled:NO];
				[assignGestureButton setEnabled:YES];
				[deleteGestureButton setEnabled:NO];
			}
		}
		else {
			[showGestureButton setEnabled:NO];
			[assignGestureButton setEnabled:NO];
			[deleteGestureButton setEnabled:NO];
		}
	}
    
    if (![MultitouchManager systemIsMultitouchCapable]) {
        [multitouchCheckbox setAlphaValue:0.5];
        [multitouchCheckbox setEnabled:NO];
        [multitouchRecognitionLabel setAlphaValue:0.5];
        
        [multitouchCheckbox setState:NO];
        [self useMultitouchOptionChanged:nil];
    } else {
        [multitouchCheckbox setAlphaValue:1.0];
        [multitouchCheckbox setEnabled:YES];
        [multitouchRecognitionLabel setAlphaValue:1.0];
    }
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
	[self updateSetupControls];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
	return [[self currentAppArray] count];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	NSTableCellView *result = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
	App *app = [[self currentAppArray] objectAtIndex:row];
	result.imageView.image = app.icon;
	result.textField.stringValue = app.name;
    
	return result;
}

- (IBAction)toggleGestureSetupWindow:(id)sender {
	NSRect menuBarFrame = [[[statusBarItem view] window] frame];
	NSPoint pt = NSMakePoint(NSMidX(menuBarFrame), NSMidY(menuBarFrame));
    
	pt.y -= menuBarFrame.size.height / 2;
	pt.x -= (setupWindow.frame.size.width) / 2;
    
	NSRect frame = [setupWindow frame];
	if ([setupWindow alphaValue] <= 0) {
		frame.origin.y = pt.y;
		frame.origin.x = pt.x;
		[setupWindow setFrame:frame display:YES];
        
		frame.origin.y -= frame.size.height;
		[setupWindow setAlphaValue:1.0];
		[setupWindow makeKeyAndOrderFront:self];
		[setupWindow setFrame:frame display:YES animate:YES];
        
		[setupWindow setIgnoresMouseEvents:NO];
		[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
	}
	else {
		if ([[NSApplication sharedApplication] isHidden]) {
			[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
		}
		else {
			frame.origin.x = pt.x;
			frame.origin.y = pt.y;
			[setupWindow setFrame:frame display:YES animate:YES];
            
			[setupWindow setIgnoresMouseEvents:YES];
			[setupWindow setAlphaValue:0.0];
			
            [setupWindow setFrameOrigin:NSMakePoint(-10000, -10000)];
            
			[[NSApplication sharedApplication] hide:self];
		}
	}
    
	[self updateSetupControls];
}

@end
