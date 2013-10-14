#import "Launchable.h"

@interface Application : Launchable {
	NSString *bundleId;
}
@property NSString *bundleId;

- (id)initWithDisplayName:(NSString *)_displayName icon:(NSImage *)_icon bundleId:(NSString *)_bundleId;
- (void)launch;

@end
