#import "SafariPage.h"

@implementation SafariPage

- (id)initWithDisplayName:(NSString *)_displayName icon:(NSImage *)_icon url:(NSString *)_url {
	self = [super initWithDisplayName:_displayName icon:_icon url:_url targetBrowserId:@"com.apple.Safari"];
    
	return self;
}

- (void)launch {
	SafariApplication *safari = [SBApplication applicationWithBundleIdentifier:@"com.apple.Safari"];
	[safari activate];
    
	if (safari.documents.count == 0) {
		[safari.documents addObject:[[[safari classForScriptingClass:@"document"] alloc] initWithProperties:@{ @"URL": url }]];
	}
	else {
		BOOL tabExists = NO;
		int tabIndex = -1;
		SafariWindow *window = nil;
		for (window in safari.windows) {
			for (int i = 0; i < window.tabs.count; i++) {
				SafariTab *tab = [window.tabs objectAtIndex:i];
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
			window.currentTab = [window.tabs objectAtIndex:tabIndex];
			window.index = 1;
		}
		else {
			SafariTab *newTab = [[[safari classForScriptingClass:@"tab"] alloc] initWithProperties:@{ @"URL": url }];
			window = [safari.windows objectAtIndex:0];
			[window.tabs addObject:newTab];
			window.currentTab = newTab;
			window.index = 1;
		}
	}
}

@end
