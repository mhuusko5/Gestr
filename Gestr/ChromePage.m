#import "ChromePage.h"

@implementation ChromePage

- (NSString *)stripUrl:(NSString *)url {
	NSUInteger prefix = [url rangeOfString:@"://"].location;
	if (prefix != NSNotFound) {
		url = [url substringFromIndex:prefix + 3];
	}
	if ([url characterAtIndex:url.length - 1] == '/') {
		url = [url substringToIndex:url.length - 1];
	}
	return url;
}

- (void)launch {
	ChromeApplication *chrome = [SBApplication applicationWithBundleIdentifier:@"com.google.Chrome"];
	[chrome activate];
    
	if (chrome.windows.count == 0) {
		[chrome.windows addObject:[[[chrome classForScriptingClass:@"window"] alloc] initWithProperties:nil]];
        ((ChromeWindow *)[chrome.windows objectAtIndex:0]).activeTab.URL = launchId;
	} else {
        BOOL tabExists = NO;
        int tabIndex = -1;
        ChromeWindow *window = nil;
        for (window in chrome.windows) {
            for (int i = 0; i < window.tabs.count; i++) {
                ChromeTab *tab = [window.tabs objectAtIndex:i];
                if ([[self stripUrl:tab.URL] isEqualToString:[self stripUrl:launchId]]) {
                    tabIndex = i;
                    tabExists = YES;
                    break;
                }
            }
            if (tabExists) {
                break;
            }
        }
        
        if (tabExists) {
            window.activeTabIndex = tabIndex + 1;
            window.index = 1;
        }
        else {
            ChromeTab *newTab = [[[chrome classForScriptingClass:@"tab"] alloc] initWithProperties:nil];
            window = [chrome.windows objectAtIndex:0];
            [window.tabs addObject:newTab];
            newTab.URL = launchId;
            window.index = 1;
        }
    }
}

@end
