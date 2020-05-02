#import "Launchable.h"

@interface WebPage : Launchable

@property NSString *url;
@property NSString *targetBrowserId;

- (id)initWithDisplayName:(NSString *)displayName icon:(NSImage *)icon url:(NSString *)url targetBrowserId:(NSString *)targetBrowserId;
- (void)launch;

@end
