#import "Launchable.h"
#import <ScriptingBridge/ScriptingBridge.h>
#import "Chrome.h"
#import "Website.h"

@interface ChromePage : Website 

- (id)initWithDisplayName:(NSString *)_displayName icon:(NSImage *)_icon url:(NSString *)_url;
- (void)launch;

@end
