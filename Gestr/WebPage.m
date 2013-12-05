#import "WebPage.h"

@implementation WebPage

- (id)initWithDisplayName:(NSString *)displayName icon:(NSImage *)icon url:(NSString *)url targetBrowserId:(NSString *)targetBrowserId {
	NSString *launchId = [NSString stringWithFormat:@"%@:%@", targetBrowserId, url];
    
	self = [super initWithDisplayName:displayName launchId:launchId icon:icon];
    
	_url = url;
	_targetBrowserId = targetBrowserId;
    
	return self;
}

+ (NSString *)stripUrl:(NSString *)url {
	NSUInteger prefix = [url rangeOfString:@"://"].location;
	if (prefix != NSNotFound) {
		url = [url substringFromIndex:prefix + 3];
	}
	if ([url characterAtIndex:url.length - 1] == '/') {
		url = [url substringToIndex:url.length - 1];
	}
	return url;
}

@end
