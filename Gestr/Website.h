#import "Launchable.h"

@interface Website : Launchable {
    NSString *url;
    NSString *targetBrowserId;
}
@property NSString *url;
@property NSString *targetBrowserId;

- (id)initWithDisplayName:(NSString *)_displayName icon:(NSImage *)_icon url:(NSString *)_url targetBrowserId:(NSString *)_targetBrowserId;
+ (NSString *)stripUrl:(NSString *)url;

@end
