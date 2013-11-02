#import "GestureSetupModel.h"

@implementation GestureSetupModel

@synthesize webPageArray;
@synthesize normalAppArray, utilitiesAppArray, systemAppArray;
@synthesize readingDelayTime, minimumRecognitionScore;
@synthesize multitouchOption, fullscreenOption, loginStartOption;

- (id)init {
	self = [super init];
    
	userDefaults = [NSUserDefaults standardUserDefaults];
    
	[self fetchWebPageArray];
    
	[self fetchNormalAppArray];
	[self fetchUtilitiesAppArray];
	[self fetchSystemAppArray];
    
	[self fetchMinimumRecognitionScore];
	[self fetchReadingDelayTime];
	[self fetchMultitouchOption];
	[self fetchFullscreenOption];
	[self saveLoginStartOption:[self fetchLoginStartOption]];
    
	return self;
}

#pragma mark -
#pragma mark Launchable Management
- (Launchable *)findLaunchableWithId:(NSString *)identity {
	for (ChromePage *page in webPageArray) {
		if ([page.launchId isEqualTo:identity]) {
			return page;
		}
	}
    
	for (Application *app in normalAppArray) {
		if ([app.launchId isEqualTo:identity]) {
			return app;
		}
	}
    
	for (Application *app in utilitiesAppArray) {
		if ([app.launchId isEqualTo:identity]) {
			return app;
		}
	}
    
	for (Application *app in systemAppArray) {
		if ([app.launchId isEqualTo:identity]) {
			return app;
		}
	}
    
	return nil;
}

#pragma mark -

#pragma mark -
#pragma mark Web Page Management
- (NSMutableArray *)fetchWebPageArray {
	webPageArray = [NSMutableArray array];
    
	[webPageArray addObjectsFromArray:[self fetchChromePages]];
	[webPageArray addObjectsFromArray:[self fetchSafariPages]];
    
	webPageArray = [NSMutableArray arrayWithArray:[webPageArray sortedArrayUsingComparator: ^NSComparisonResult (WebPage *a, WebPage *b) {
	    return [a.displayName compare:b.displayName];
	}]];
    
	return webPageArray;
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
				if ([[bookmark valueForKey:@"type"] isEqualToString:@"url"]) {
					[chromePages addObject:[[ChromePage alloc] initWithDisplayName:[bookmark valueForKey:@"name"] icon:chromeIcon url:[bookmark valueForKey:@"url"]]];
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
					@try {
						[safariPages addObject:[[SafariPage alloc] initWithDisplayName:[[bookmark valueForKey:@"URIDictionary"] valueForKey:@"title"] icon:safariIcon url:[bookmark valueForKey:@"URLString"]]];
					}
					@catch (NSException *exception)
					{
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
	return (normalAppArray = [self addApplicationsAtPath:@"/Applications" toArray:[NSMutableArray array] depth:1]);
}

- (NSMutableArray *)fetchUtilitiesAppArray {
	return (utilitiesAppArray = [self addApplicationsAtPath:@"/Applications/Utilities" toArray:[NSMutableArray array] depth:1]);
}

- (NSMutableArray *)fetchSystemAppArray {
	systemAppArray = [self addApplicationsAtPath:@"/System/Library/CoreServices" toArray:[NSMutableArray array] depth:0];
	for (Application *maybeFinder in systemAppArray) {
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
                
				if (bundleId && ![displayName isEqualToString:@"Gestr"]) {
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
