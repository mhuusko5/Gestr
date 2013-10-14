#import "ChromePage.h"

@implementation ChromePage

- (id)initWithDisplayName:(NSString *)_displayName icon:(NSImage *)_icon url:(NSString *)_url {
	self = [super initWithDisplayName:_displayName icon:_icon url:_url targetBrowserId:@"com.google.Chrome"];
    
	return self;
}

- (void)launch {
	ChromeApplication *chrome = [SBApplication applicationWithBundleIdentifier:@"com.google.Chrome"];
	[chrome activate];
    
	if (chrome.windows.count == 0) {
		[chrome.windows addObject:[[[chrome classForScriptingClass:@"window"] alloc] init]];
		((ChromeWindow *)[chrome.windows objectAtIndex:0]).activeTab.URL = url;
	}
	else {
		BOOL tabExists = NO;
		int tabIndex = -1;
		ChromeWindow *window = nil;
		for (window in chrome.windows) {
			for (int i = 0; i < window.tabs.count; i++) {
				ChromeTab *tab = [window.tabs objectAtIndex:i];
				if ([[[self class] stripUrl:tab.URL] isEqualToString:[[self class] stripUrl:url]]) {
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
			ChromeTab *newTab = [[[chrome classForScriptingClass:@"tab"] alloc] initWithProperties:@{ @"URL": url }];
			window = [chrome.windows objectAtIndex:0];
			[window.tabs addObject:newTab];
			window.index = 1;
		}
	}
}

@end
