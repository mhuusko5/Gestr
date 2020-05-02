#import "WebPage.h"

@implementation WebPage

- (id)initWithDisplayName:(NSString *)displayName icon:(NSImage *)icon url:(NSString *)url targetBrowserId:(NSString *)targetBrowserId {
	NSString *launchId = [NSString stringWithFormat:@"%@:%@", targetBrowserId, url];

	self = [super initWithDisplayName:displayName launchId:launchId icon:icon];

	_url = url;
	_targetBrowserId = targetBrowserId;

	return self;
}

- (void)launch {
    [NSWorkspace.sharedWorkspace openURLs:@[[NSURL URLWithString:self.url]]
                  withAppBundleIdentifier:self.targetBrowserId
                                  options:0
           additionalEventParamDescriptor:nil
                        launchIdentifiers:nil];
}

@end
