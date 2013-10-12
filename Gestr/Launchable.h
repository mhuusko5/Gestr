#import <Foundation/Foundation.h>

@interface Launchable : NSObject {
	NSString *displayName;
	NSString *launchId;
	NSImage *icon;
}
@property (assign) NSString *displayName, *launchId;
@property (assign) NSImage *icon;

- (id)initWithDisplayName:(NSString *)_displayName launchId:(NSString *)_launchId icon:(NSImage *)_icon;
- (void)launchWithNewThread:(BOOL)newThread;

@end
