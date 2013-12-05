#import "Launchable.h"

@interface Application : Launchable

@property NSString *bundleId;

- (id)initWithDisplayName:(NSString *)displayName icon:(NSImage *)icon bundleId:(NSString *)bundleId;
- (void)launch;

@end
