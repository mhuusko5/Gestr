#import "WebPage.h"

@implementation WebPage

@synthesize url;
@synthesize targetBrowserId;

- (id)initWithDisplayName:(NSString *)_displayName icon:(NSImage *)_icon url:(NSString *)_url targetBrowserId:(NSString *)_targetBrowserId {
	NSString *_launchId = [NSString stringWithFormat:@"%@:%@", _targetBrowserId, _url];
    
	self = [super initWithDisplayName:_displayName launchId:_launchId icon:_icon];
    
	url = _url;
	targetBrowserId = _targetBrowserId;
    
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
