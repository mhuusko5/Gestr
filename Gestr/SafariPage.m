#import "SafariPage.h"

@implementation SafariPage

- (id)initWithDisplayName:(NSString *)_displayName icon:(NSImage *)_icon url:(NSString *)_url {
    self = [super initWithDisplayName:_displayName icon:_icon url:_url targetBrowserId:@"com.apple.Safari"];
    
    return self;
}

- (void)launch {
	NSLog(@"%@", url);
}

@end
