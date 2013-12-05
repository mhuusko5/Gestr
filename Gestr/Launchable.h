@interface Launchable : NSObject

@property NSString *displayName;
@property NSString *launchId;
@property NSImage *icon;

- (id)initWithDisplayName:(NSString *)displayName launchId:(NSString *)launchId icon:(NSImage *)icon;
- (void)launchWithNewThread:(BOOL)newThread;

@end
