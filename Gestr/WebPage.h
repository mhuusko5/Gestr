#import "Launchable.h"

@interface WebPage : Launchable

@property NSString *url;
@property NSString *targetBrowserId;

- (id)initWithDisplayName:(NSString *)displayName icon:(NSImage *)icon url:(NSString *)url targetBrowserId:(NSString *)targetBrowserId;
+ (NSString *)stripUrl:(NSString *)url;

@end
