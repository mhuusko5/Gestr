#import <ScriptingBridge/ScriptingBridge.h>
#import "Safari.h"
#import "WebPage.h"

@interface SafariPage : WebPage

- (id)initWithDisplayName:(NSString *)displayName icon:(NSImage *)icon url:(NSString *)url;
- (void)launch;

@end
