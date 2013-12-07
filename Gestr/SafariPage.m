#import "SafariPage.h"

@implementation SafariPage

- (id)initWithDisplayName:(NSString *)displayName icon:(NSImage *)icon url:(NSString *)url {
	self = [super initWithDisplayName:displayName icon:icon url:url targetBrowserId:@"com.apple.Safari"];

	return self;
}

- (void)launch {
	SafariApplication *safari = [SBApplication applicationWithBundleIdentifier:@"com.apple.Safari"];
	[safari activate];

	if (safari.documents.count == 0) {
		[safari.documents addObject:[[[safari classForScriptingClass:@"document"] alloc] initWithProperties:@{ @"URL": self.url }]];
	}
	else {
		BOOL tabExists = NO;
		int tabIndex = -1;
		SafariWindow *window = nil;
		for (window in safari.windows) {
			for (int i = 0; i < window.tabs.count; i++) {
				SafariTab *tab = window.tabs[i];
				if ([[[self class] stripUrl:tab.URL] isEqualToString:[[self class] stripUrl:self.url]]) {
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
			window.currentTab = window.tabs[tabIndex];
			window.index = 1;
		}
		else {
			SafariTab *newTab = [[[safari classForScriptingClass:@"tab"] alloc] initWithProperties:@{ @"URL": self.url }];
			window = safari.windows[0];
			[window.tabs addObject:newTab];
			window.currentTab = newTab;
			window.index = 1;
		}
	}
}

@end
