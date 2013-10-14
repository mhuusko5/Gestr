#import <ScriptingBridge/ScriptingBridge.h>
#import "Safari.h"
#import "WebPage.h"

@interface SafariPage : WebPage

- (id)initWithDisplayName:(NSString *)_displayName icon:(NSImage *)_icon url:(NSString *)_url;
- (void)launch;

@end
