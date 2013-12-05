#import <ScriptingBridge/ScriptingBridge.h>
#import "Chrome.h"
#import "WebPage.h"

@interface ChromePage : WebPage

- (id)initWithDisplayName:(NSString *)displayName icon:(NSImage *)icon url:(NSString *)url;
- (void)launch;

@end
