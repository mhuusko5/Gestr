#import "Launchable.h"
#import <ScriptingBridge/ScriptingBridge.h>
#import "Chrome.h"

@interface ChromePage : Launchable

- (NSString *)stripUrl:(NSString *)url;
- (void)launch;

@end
