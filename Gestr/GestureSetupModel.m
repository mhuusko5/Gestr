#import "GestureSetupModel.h"

@interface GestureSetupModel ()

@property NSUserDefaults *storage;

@end

@implementation GestureSetupModel

- (id)init {
	self = [super init];

	_storage = [NSUserDefaults standardUserDefaults];

	return self;
}

#pragma mark -
#pragma mark Setup
- (void)setup {
    [self fetchScriptArray];

	[self fetchWebPageArray];

	[self fetchNormalAppArray];
	[self fetchUtilitiesAppArray];
	[self fetchSystemAppArray];

	[self fetchMinimumRecognitionScore];
	[self fetchReadingDelayTime];
	[self fetchMultitouchOption];
	[self fetchFullscreenOption];
	[self saveLoginStartOption:[self fetchLoginStartOption]];
	[self fetchQuickdrawOption];
}

#pragma mark -

#pragma mark -
#pragma mark Launchable Management
- (Launchable *)findLaunchableWithId:(NSString *)identity {
    for (Script *script in _scriptArray) {
        if ([script.launchId isEqualTo: identity]) {
            return script;
        }
    }

	for (ChromePage *page in _webPageArray) {
		if ([page.launchId isEqualTo:identity]) {
			return page;
		}
	}

	for (Application *app in _normalAppArray) {
		if ([app.launchId isEqualTo:identity]) {
			return app;
		}
	}

	for (Application *app in _utilitiesAppArray) {
		if ([app.launchId isEqualTo:identity]) {
			return app;
		}
	}

	for (Application *app in _systemAppArray) {
		if ([app.launchId isEqualTo:identity]) {
			return app;
		}
	}

	return nil;
}

#pragma mark -

#pragma mark -
#pragma mark Script Managmeent
- (NSMutableArray *)fetchScriptArray {
    _scriptArray = [NSMutableArray array];

    NSArray *paths = [[NSBundle mainBundle] URLsForResourcesWithExtension:@"scpt" subdirectory:@"Scripts"];
    for (NSURL *pathURL in paths) {
        NSString *displayName = [[[NSFileManager defaultManager] displayNameAtPath:[pathURL path]] stringByDeletingPathExtension];
        NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFile:[pathURL path]];
        if (displayName && icon) {
            [_scriptArray addObject:[[Script alloc] initWithDisplayName:displayName icon:icon fileURL:pathURL]];
        }
    }

    NSMutableArray *customScripts = [NSMutableArray array];

    @try {
        NSString *path = [[NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Gestr/Scripts"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path] || [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil]) {
            NSDirectoryEnumerator *directoryEnumerator = [[NSFileManager defaultManager] enumeratorAtURL:[NSURL URLWithString:[path stringByReplacingOccurrencesOfString:@" " withString:@"%20"]] includingPropertiesForKeys:nil options:(NSDirectoryEnumerationSkipsSubdirectoryDescendants | NSDirectoryEnumerationSkipsPackageDescendants | NSDirectoryEnumerationSkipsHiddenFiles) errorHandler:nil];
            NSURL *fileUrl;
            while (fileUrl = [directoryEnumerator nextObject]) {
                NSString *filePath = [fileUrl path];
                BOOL isDir;
                if ([[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDir]) {
                    if ([[fileUrl pathExtension] isEqualToString:@"scpt"] || [[fileUrl pathExtension] isEqualToString:@"AppleScript"]) {
                        NSString *displayName = [[[NSFileManager defaultManager] displayNameAtPath:filePath] stringByDeletingPathExtension];
                        NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFile:filePath];
                        if (displayName && icon) {
                            [customScripts addObject:[[Script alloc] initWithDisplayName:displayName icon:icon fileURL:fileUrl]];
                        }
                    }
                }
            }
        }
    }
    @catch (NSException *exception) {
        customScripts = [NSMutableArray array];
    }

    [_scriptArray addObjectsFromArray:customScripts];

    _scriptArray = [[_scriptArray sortedArrayUsingComparator: ^NSComparisonResult (Script *a, Script *b) {
        return [a.displayName compare:b.displayName];
    }] mutableCopy];

    return _scriptArray;
}

#pragma mark -

#pragma mark -
#pragma mark Web Page Management
- (NSMutableArray *)fetchWebPageArray {
	_webPageArray = [self fetchChromePages];

	[_webPageArray addObjectsFromArray:[self fetchSafariPages]];

	_webPageArray = [[_webPageArray sortedArrayUsingComparator: ^NSComparisonResult (WebPage *a, WebPage *b) {
	    return [a.displayName compare:b.displayName];
	}] mutableCopy];

	return _webPageArray;
}

- (NSMutableArray *)fetchChromePages {
	NSMutableArray *chromePages = [NSMutableArray array];

	@try {
		NSImage *chromeIcon;
		if ((chromeIcon = [[NSWorkspace sharedWorkspace] iconForFile:@"/Applications/Google Chrome.app"]) || (chromeIcon = [[NSWorkspace sharedWorkspace] iconForFile:[@"~/Applications/Google Chrome.app" stringByExpandingTildeInPath]])) {
			NSData *chromeBooksmarksData = [NSData dataWithContentsOfFile:[@"~/Library/Application Support/Google/Chrome/Default/Bookmarks" stringByExpandingTildeInPath]];
			NSDictionary *chromeBookmarksJson = [NSJSONSerialization JSONObjectWithData:chromeBooksmarksData options:NSJSONReadingMutableContainers error:nil];

			NSArray *bookmarksBar = [[[chromeBookmarksJson valueForKey:@"roots"] valueForKey:@"bookmark_bar"] valueForKey:@"children"];
			for (NSDictionary *bookmark in bookmarksBar) {
				NSString *type = [bookmark valueForKey:@"type"];
				NSString *name = [bookmark valueForKey:@"name"];
				NSString *url = [bookmark valueForKey:@"url"];
				if ([type isEqualToString:@"url"] && name && url) {
					[chromePages addObject:[[ChromePage alloc] initWithDisplayName:name icon:chromeIcon url:url]];
				}
			}
		}
	}
	@catch (NSException *exception)
	{
		chromePages = [NSMutableArray array];
	}

	return chromePages;
}

- (NSMutableArray *)fetchSafariPages {
	NSMutableArray *safariPages = [NSMutableArray array];

	@try {
		NSImage *safariIcon;
		if ((safariIcon = [[NSWorkspace sharedWorkspace] iconForFile:@"/Applications/Safari.app"]) || (safariIcon = [[NSWorkspace sharedWorkspace] iconForFile:[@"~/Applications/Safari.app" stringByExpandingTildeInPath]])) {
			NSData *safariBooksmarksData = [NSData dataWithContentsOfFile:[@"~/Library/Safari/Bookmarks.plist" stringByExpandingTildeInPath]];
			NSDictionary *safariBookmarksPlist = [NSPropertyListSerialization propertyListWithData:safariBooksmarksData options:NSPropertyListImmutable format:nil error:nil];

			NSArray *bookmarksBar = nil;

			NSArray *bookmarkSections = [safariBookmarksPlist valueForKey:@"Children"];
			for (NSDictionary *bookmarkSection in bookmarkSections) {
				if ([[bookmarkSection valueForKey:@"Title"] isEqualToString:@"BookmarksBar"]) {
					bookmarksBar = [bookmarkSection valueForKey:@"Children"];
					break;
				}
			}

			if (bookmarksBar) {
				for (NSDictionary *bookmark in bookmarksBar) {
					NSString *title = [[bookmark valueForKey:@"URIDictionary"] valueForKey:@"title"];
					NSString *url = [bookmark valueForKey:@"URLString"];
					if (title && url) {
						[safariPages addObject:[[SafariPage alloc] initWithDisplayName:title icon:safariIcon url:url]];
					}
				}
			}
		}
	}
	@catch (NSException *exception)
	{
		safariPages = [NSMutableArray array];
	}

	return safariPages;
}

#pragma mark -

#pragma mark -
#pragma mark Applications Management
- (NSMutableArray *)fetchNormalAppArray {
    _normalAppArray = [self addApplicationsAtPath:@"/Applications" toArray:[NSMutableArray array] depth:1];

    [_normalAppArray addObjectsFromArray:[self addApplicationsAtPath:[NSHomeDirectory() stringByAppendingString:@"/Applications"]  toArray:[NSMutableArray array] depth:1]];
    return _normalAppArray;
}

- (NSMutableArray *)fetchUtilitiesAppArray {
	return (_utilitiesAppArray = [self addApplicationsAtPath:@"/Applications/Utilities" toArray:[NSMutableArray array] depth:1]);
}

- (NSMutableArray *)fetchSystemAppArray {
	_systemAppArray = [self addApplicationsAtPath:@"/System/Library/CoreServices" toArray:[NSMutableArray array] depth:0];
	for (Application *maybeFinder in _systemAppArray) {
		if ([[maybeFinder.launchId lowercaseString] isEqualToString:@"com.apple.finder"]) {
			Application *finder = maybeFinder;
			[_systemAppArray removeObject:maybeFinder];
			[_systemAppArray insertObject:finder atIndex:0];
			break;
		}
	}
	return _systemAppArray;
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

				NSString *bundleId = dict[@"CFBundleIdentifier"];
				NSString *displayName = [[[NSFileManager defaultManager] displayNameAtPath:filePath] stringByDeletingPathExtension];
				NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFile:filePath];

				if (bundleId && ![bundleId isEqualToString:[[NSBundle mainBundle] bundleIdentifier]] && ![bundleId isEqualToString:@"com.mhuusko5.Tapr"] && displayName && icon) {
					[arr addObject:[[Application alloc] initWithDisplayName:displayName icon:icon bundleId:bundleId]];
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
	if ((storedMinimumRecognitionScore = [_storage objectForKey:@"minimumRecognitionScore"])) {
		_minimumRecognitionScore = [storedMinimumRecognitionScore intValue];
	}
	else {
		[self saveMinimumRecognitionScore:80];
	}

	return _minimumRecognitionScore;
}

- (void)saveMinimumRecognitionScore:(int)newScore {
	[_storage setInteger:(_minimumRecognitionScore = newScore) forKey:@"minimumRecognitionScore"];
	[_storage synchronize];
}

- (int)fetchReadingDelayTime {
	id storedReadingDelayTime;
	if ((storedReadingDelayTime = [_storage objectForKey:@"readingDelayTime"])) {
		_readingDelayTime = [storedReadingDelayTime intValue];
	}
	else {
		[self saveReadingDelayTime:5];
	}

	return _readingDelayTime;
}

- (void)saveReadingDelayTime:(int)newTime {
	[_storage setInteger:(_readingDelayTime = newTime) forKey:@"readingDelayTime"];
	[_storage synchronize];
}

- (BOOL)fetchMultitouchOption {
	id storedMultitouchOption;
	if ((storedMultitouchOption = [_storage objectForKey:@"multitouchOption"])) {
		_multitouchOption = [storedMultitouchOption boolValue];
	}
	else {
		[self saveMultitouchOption:[MultitouchManager systemIsMultitouchCapable]];
	}

	return _multitouchOption;
}

- (void)saveMultitouchOption:(BOOL)newChoice {
	[_storage setBool:(_multitouchOption = newChoice) forKey:@"multitouchOption"];
	[_storage synchronize];
}

- (BOOL)fetchFullscreenOption {
	id storedFullscreenOption;
	if ((storedFullscreenOption = [_storage objectForKey:@"fullscreenOption"])) {
		_fullscreenOption = [storedFullscreenOption boolValue];
	}
	else {
		[self saveFullscreenOption:NO];
	}

	return _fullscreenOption;
}

- (void)saveFullscreenOption:(BOOL)newChoice {
	[_storage setBool:(_fullscreenOption = newChoice) forKey:@"fullscreenOption"];
	[_storage synchronize];
}

- (BOOL)fetchLoginStartOption {
	NSURL *itemURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
	Boolean foundIt = false;
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
	if (loginItems) {
		UInt32 seed = 0U;
		NSArray *currentLoginItems = (__bridge_transfer NSArray *)(LSSharedFileListCopySnapshot(loginItems, &seed));
		for (id itemObject in currentLoginItems) {
			LSSharedFileListItemRef item = (__bridge LSSharedFileListItemRef)itemObject;
			UInt32 resolutionFlags = kLSSharedFileListNoUserInteraction | kLSSharedFileListDoNotMountVolumes;
			CFURLRef URL = NULL;
			OSStatus err = LSSharedFileListItemResolve(item, resolutionFlags, &URL, /*outRef*/ NULL);
			if (err == noErr) {
				foundIt = CFEqual(URL, (__bridge CFTypeRef)(itemURL));
				CFRelease(URL);
				if (foundIt) {
					break;
				}
			}
		}
		CFRelease(loginItems);
	}

	return (_loginStartOption = foundIt);
}

- (void)saveLoginStartOption:(BOOL)newChoice {
	_loginStartOption = newChoice;

	NSURL *itemURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
	LSSharedFileListItemRef existingItem = NULL;
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
	if (loginItems) {
		UInt32 seed = 0U;
		NSArray *currentLoginItems = (__bridge_transfer NSArray *)(LSSharedFileListCopySnapshot(loginItems, &seed));
		for (id itemObject in currentLoginItems) {
			LSSharedFileListItemRef item = (__bridge LSSharedFileListItemRef)itemObject;
			UInt32 resolutionFlags = kLSSharedFileListNoUserInteraction | kLSSharedFileListDoNotMountVolumes;
			CFURLRef URL = NULL;
			OSStatus err = LSSharedFileListItemResolve(item, resolutionFlags, &URL, /*outRef*/ NULL);
			if (err == noErr) {
				Boolean foundIt = CFEqual(URL, (__bridge CFTypeRef)(itemURL));
				CFRelease(URL);
				if (foundIt) {
					existingItem = item;
					break;
				}
			}
		}
		if (_loginStartOption && (existingItem == NULL)) {
			LSSharedFileListInsertItemURL(loginItems, kLSSharedFileListItemBeforeFirst, NULL, NULL, (__bridge CFURLRef)itemURL, NULL, NULL);
		}
		else if (!_loginStartOption && (existingItem != NULL)) {
			LSSharedFileListItemRemove(loginItems, existingItem);
		}
		CFRelease(loginItems);
	}
}

- (BOOL)fetchQuickdrawOption {
	id storedQuickdrawOption;
	if ((storedQuickdrawOption = [_storage objectForKey:@"quickdrawOption"])) {
		_quickdrawOption = [storedQuickdrawOption boolValue];
	}
	else {
		[self saveQuickdrawOption:NO];
	}

	return _quickdrawOption;
}

- (void)saveQuickdrawOption:(BOOL)newChoice {
	[_storage setBool:(_quickdrawOption = newChoice) forKey:@"quickdrawOption"];
	[_storage synchronize];
}

#pragma mark -

@end
