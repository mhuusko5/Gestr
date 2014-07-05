#import "Launchable.h"

@interface Script : Launchable

@property NSAppleScript *script;

- (id)initWithDisplayName:(NSString *)displayName icon:(NSImage *)icon fileURL:(NSURL *)fileURL;
- (void)launch;

@end
