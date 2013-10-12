#import "GestureSetupModel.h"

@implementation GestureSetupModel

@synthesize normalAppArray, utilitiesAppArray, systemAppArray;
@synthesize readingDelayNumber, successfulRecognitionScore;
@synthesize multitouchRecognition, fullscreenRecognition, hideDockIcon, startAtLaunch;

- (id)init {
	self = [super init];
    
	userDefaults = [NSUserDefaults standardUserDefaults];
    
    [self fetchNormalAppArray];
    [self fetchUtilitiesAppArray];
    [self fetchSystemAppArray];
    
	[self fetchSuccessfulRecognitionScore];
	[self fetchReadingDelayNumber];
	[self fetchMultitouchRecognition];
	[self fetchFullscreenRecognition];
	[self saveHideDockIcon:[self fetchHideDockIcon]];
	[self saveStartAtLaunch:[self fetchStartAtLaunch]];
    
	return self;
}

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
- (int)fetchSuccessfulRecognitionScore {
	id storedSuccessfulRecognitionScore;
	if ((storedSuccessfulRecognitionScore = [userDefaults objectForKey:@"successfulRecognitionScore"])) {
		successfulRecognitionScore = [storedSuccessfulRecognitionScore intValue];
	}
	else {
		[self saveSuccessfulRecognitionScore:80];
	}
    
	return successfulRecognitionScore;
}

- (void)saveSuccessfulRecognitionScore:(int)newScore {
	[userDefaults setInteger:(successfulRecognitionScore = newScore) forKey:@"successfulRecognitionScore"];
	[userDefaults synchronize];
}

- (int)fetchReadingDelayNumber {
	id storedReadingDelayNumber;
	if ((storedReadingDelayNumber = [userDefaults objectForKey:@"readingDelayNumber"])) {
		readingDelayNumber = [storedReadingDelayNumber intValue];
	}
	else {
		[self saveReadingDelayNumber:5];
	}
    
	return readingDelayNumber;
}

- (void)saveReadingDelayNumber:(int)newNum {
	[userDefaults setInteger:(readingDelayNumber = newNum) forKey:@"readingDelayNumber"];
	[userDefaults synchronize];
}

- (BOOL)fetchMultitouchRecognition {
	id storedMultitouchRecognition;
	if ((storedMultitouchRecognition = [userDefaults objectForKey:@"multitouchRecognition"])) {
		multitouchRecognition = [storedMultitouchRecognition boolValue];
	}
	else {
		[self saveMultitouchRecognition:[MultitouchManager systemIsMultitouchCapable]];
	}
    
	return multitouchRecognition;
}

- (void)saveMultitouchRecognition:(BOOL)newValue {
	[userDefaults setBool:(multitouchRecognition = newValue) forKey:@"multitouchRecognition"];
	[userDefaults synchronize];
}

- (BOOL)fetchFullscreenRecognition {
	id storedFullscreenRecognition;
	if ((storedFullscreenRecognition = [userDefaults objectForKey:@"fullscreenRecognition"])) {
		fullscreenRecognition = [storedFullscreenRecognition boolValue];
	}
	else {
		[self saveFullscreenRecognition:NO];
	}
    
	return fullscreenRecognition;
}

- (void)saveFullscreenRecognition:(BOOL)newValue {
	[userDefaults setBool:(fullscreenRecognition = newValue) forKey:@"fullscreenRecognition"];
	[userDefaults synchronize];
}

- (BOOL)fetchHideDockIcon {
	id storedHideDockIcon;
	if ((storedHideDockIcon = [userDefaults objectForKey:@"hideDockIcon"])) {
		hideDockIcon = [storedHideDockIcon boolValue];
	}
	else {
		[self saveHideDockIcon:NO];
	}
    
	return hideDockIcon;
}

- (void)saveHideDockIcon:(BOOL)newValue {
	[userDefaults setBool:(hideDockIcon = newValue) forKey:@"hideDockIcon"];
	[userDefaults synchronize];
    
	ProcessSerialNumber psn = { 0, kCurrentProcess };
	if (hideDockIcon) {
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

- (BOOL)fetchStartAtLaunch {
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
    
	return (startAtLaunch = foundIt);
}

- (void)saveStartAtLaunch:(BOOL)newValue {
	startAtLaunch = newValue;
    
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
		if (startAtLaunch && (existingItem == NULL)) {
			LSSharedFileListInsertItemURL(loginItems, kLSSharedFileListItemBeforeFirst, NULL, NULL, (CFURLRef)itemURL, NULL, NULL);
		}
		else if (!startAtLaunch && (existingItem != NULL)) {
			LSSharedFileListItemRemove(loginItems, existingItem);
		}
		CFRelease(loginItems);
	}
}

#pragma mark -

@end
