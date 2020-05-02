#import "ChromePage.h"

@implementation ChromePage

- (id)initWithDisplayName:(NSString *)displayName icon:(NSImage *)icon url:(NSString *)url {
	return (self = [super initWithDisplayName:displayName icon:icon url:url targetBrowserId:@"com.google.Chrome"]);
}

@end
