#import <ScriptingBridge/ScriptingBridge.h>
#import "Chrome.h"
#import "WebPage.h"

@interface ChromePage : WebPage

- (id)initWithDisplayName:(NSString *)_displayName icon:(NSImage *)_icon url:(NSString *)_url;
- (void)launch;

@end
