#import "GestureSetupModel.h"

@implementation GestureSetupModel

@synthesize normalAppArray, utilitiesAppArray, systemAppArray;
@synthesize readingDelayTime, minimumRecognitionScore;
@synthesize multitouchOption, fullscreenOption, hiddenIconOption, loginStartOption;

- (id)init {
	self = [super init];
    
	userDefaults = [NSUserDefaults standardUserDefaults];
    
    [self fetchNormalAppArray];
    [self fetchUtilitiesAppArray];
    [self fetchSystemAppArray];
    
	[self fetchMinimumRecognitionScore];
	[self fetchReadingDelayTime];
	[self fetchMultitouchOption];
	[self fetchFullscreenOption];
	[self saveHiddenIconOption:[self fetchHiddenIconOption]];
	[self saveLoginStartOption:[self fetchLoginStartOption]];
    
	return self;
}

#pragma mark -
#pragma mark Launchable Management
- (Launchable *)findLaunchableWithId:(NSString *)identity {
    for (Launchable *launch in normalAppArray) {
		if ([launch.launchId isEqualTo:identity]) {
			return launch;
		}
	}
    
	for (Launchable *launch in utilitiesAppArray) {
		if ([launch.launchId isEqualTo:identity]) {
			return launch;
		}
	}
    
	for (Launchable *launch in systemAppArray) {
		if ([launch.launchId isEqualTo:identity]) {
			return launch;
		}
	}
    
	return nil;
}
#pragma mark -

#pragma mark -
#pragma mark Applications Arrays
- (NSMutableArray *)fetchNormalAppArray {
    return (normalAppArray = [self addApplicationsAtPath:@"/Applications" toArray:[NSMutableArray array] depth:1]);
}

- (NSMutableArray *)fetchUtilitiesAppArray {
    return (utilitiesAppArray = [self addApplicationsAtPath:@"/Applications/Utilities" toArray:[NSMutableArray array] depth:1]);
}

- (NSMutableArray *)fetchSystemAppArray {
    systemAppArray = [self addApplicationsAtPath:@"/System/Library/CoreServices" toArray:[NSMutableArray array] depth:0];
    for (Launchable *maybeFinder in systemAppArray) {
        if ([[maybeFinder.launchId lowercaseString] isEqualToString:@"com.apple.finder"]) {
            [systemAppArray removeObject:maybeFinder];
            [systemAppArray insertObject:maybeFinder atIndex:0];
            break;
        }
    }
    return systemAppArray;
}

- (NSMutableArray *)addApplicationsAtPath:(NSString *)path toArray:(NSMutableArray *)arr depth:(int)depth {
    NSURL *url;
	if (!(url = [NSURL URLWithString:[path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]])) {
		return nil;
	}
	NSDirectoryEnumerator *directoryEnumerator = [[NSFileManager defaultManager] enumeratorAtURL:url includingPropertiesForKeys:nil options:(NSDirectoryEnumerationSkipsSubdirectoryDescendants | NSDirectoryEnumerationSkipsPackageDescendants | NSDirectoryEnumerationSkipsHiddenFiles) errorHandler:nil];
	NSURL *fileUrl;
	while (fileUrl = [directoryEnumerator nextObject]) {
		NSString *filePath = [fileUrl path];
		BOOL isDir;
		if ([[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDir]) {
			if ([[fileUrl pathExtension] isEqualToString:@"app"]) {
				NSDictionary *dict = [[NSBundle bundleWithPath:[fileUrl path]] infoDictionary];
                
                NSString *bundleId = [dict objectForKey:@"CFBundleIdentifier"];
				NSString *displayName = [[[NSFileManager defaultManager] displayNameAtPath:filePath] stringByDeletingPathExtension];
				NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFile:filePath];
                
				if (![displayName isEqualToString:@"Gestr"]) {
					[arr addObject:[[Launchable alloc] initWithDisplayName:displayName launchId:bundleId icon:icon]];
				}
			}
			else if (isDir && depth > 0 && ![filePath isEqualToString:@"/Applications/Utilities"]) {
				[self addApplicationsAtPath:filePath toArray:arr depth:depth - 1];
			}
		}
	}
    
    return arr;
}
#pragma mark -

#pragma mark -
#pragma mark Recognition Options
- (int)fetchMinimumRecognitionScore {
	id storedMinimumRecognitionScore;
	if ((storedMinimumRecognitionScore = [userDefaults objectForKey:@"minimumRecognitionScore"])) {
		minimumRecognitionScore = [storedMinimumRecognitionScore intValue];
	}
	else {
		[self saveMinimumRecognitionScore:80];
	}
    
	return minimumRecognitionScore;
}

- (void)saveMinimumRecognitionScore:(int)newScore {
	[userDefaults setInteger:(minimumRecognitionScore = newScore) forKey:@"minimumRecognitionScore"];
	[userDefaults synchronize];
}

- (int)fetchReadingDelayTime {
	id storedReadingDelayTime;
	if ((storedReadingDelayTime = [userDefaults objectForKey:@"readingDelayTime"])) {
		readingDelayTime = [storedReadingDelayTime intValue];
	}
	else {
		[self saveReadingDelayTime:5];
	}
    
	return readingDelayTime;
}

- (void)saveReadingDelayTime:(int)newTime {
	[userDefaults setInteger:(readingDelayTime = newTime) forKey:@"readingDelayTime"];
	[userDefaults synchronize];
}

- (BOOL)fetchMultitouchOption {
	id storedMultitouchRecognition;
	if ((storedMultitouchRecognition = [userDefaults objectForKey:@"multitouchOption"])) {
		multitouchOption = [storedMultitouchRecognition boolValue];
	}
	else {
		[self saveMultitouchOption:[MultitouchManager systemIsMultitouchCapable]];
	}
    
	return multitouchOption;
}

- (void)saveMultitouchOption:(BOOL)newChoice {
	[userDefaults setBool:(multitouchOption = newChoice) forKey:@"multitouchOption"];
	[userDefaults synchronize];
}

- (BOOL)fetchFullscreenOption {
	id storedFullscreenRecognition;
	if ((storedFullscreenRecognition = [userDefaults objectForKey:@"fullscreenOption"])) {
		fullscreenOption = [storedFullscreenRecognition boolValue];
	}
	else {
		[self saveFullscreenOption:NO];
	}
    
	return fullscreenOption;
}

- (void)saveFullscreenOption:(BOOL)newChoice {
	[userDefaults setBool:(fullscreenOption = newChoice) forKey:@"fullscreenOption"];
	[userDefaults synchronize];
}

- (BOOL)fetchHiddenIconOption {
	id storedHideDockIcon;
	if ((storedHideDockIcon = [userDefaults objectForKey:@"hiddenIconOption"])) {
		hiddenIconOption = [storedHideDockIcon boolValue];
	}
	else {
		[self saveHiddenIconOption:NO];
	}
    
	return hiddenIconOption;
}

- (void)saveHiddenIconOption:(BOOL)newChoice {
	[userDefaults setBool:(hiddenIconOption = newChoice) forKey:@"hiddenIconOption"];
	[userDefaults synchronize];
    
	ProcessSerialNumber psn = { 0, kCurrentProcess };
	if (hiddenIconOption) {
		TransformProcessType(&psn, kProcessTransformToUIElementApplication);
		[[NSApplication sharedApplication] performSelector:@selector(activateIgnoringOtherApps:) withObject:YES afterDelay:0.005];
		[[NSApplication sharedApplication] performSelector:@selector(activateIgnoringOtherApps:) withObject:YES afterDelay:0.01];
		[[NSApplication sharedApplication] performSelector:@selector(activateIgnoringOtherApps:) withObject:YES afterDelay:0.1];
		[[NSApplication sharedApplication] performSelector:@selector(activateIgnoringOtherApps:) withObject:YES afterDelay:0.25];
		[[NSApplication sharedApplication] performSelector:@selector(activateIgnoringOtherApps:) withObject:YES afterDelay:0.5];
	}
	else {
		TransformProcessType(&psn, kProcessTransformToForegroundApplication);
	}
}

- (BOOL)fetchLoginStartOption {
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
				if (foundIt) {
					break;
				}
			}
		}
		CFRelease(loginItems);
	}
    
	return (loginStartOption = foundIt);
}

- (void)saveLoginStartOption:(BOOL)newChoice {
	loginStartOption = newChoice;
    
	NSURL *itemURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
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
		if (loginStartOption && (existingItem == NULL)) {
			LSSharedFileListInsertItemURL(loginItems, kLSSharedFileListItemBeforeFirst, NULL, NULL, (CFURLRef)itemURL, NULL, NULL);
		}
		else if (!loginStartOption && (existingItem != NULL)) {
			LSSharedFileListItemRemove(loginItems, existingItem);
		}
		CFRelease(loginItems);
	}
}

#pragma mark -

@end
