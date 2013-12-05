@interface Launchable : NSObject

@property (assign) NSString *displayName;
@property (assign) NSString *launchId;
@property (assign) NSImage *icon;

- (id)initWithDisplayName:(NSString *)displayName launchId:(NSString *)launchId icon:(NSImage *)icon;
- (void)launchWithNewThread:(BOOL)newThread;

@end
