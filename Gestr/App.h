#import <Foundation/Foundation.h>

@interface App : NSObject {
	NSString *displayName;
	NSString *bundleName;
	NSString *bundleId;
	NSImage *icon;
	NSDate *lastUsed;
	int useCount;
}
@property (assign) NSString *displayName, *bundleName, *bundleId;
@property (assign) NSImage *icon;
@property (assign) NSDate *lastUsed;
@property (assign) int useCount;

- (id)initWithDisplayName:(NSString *)_displayName bundleName:(NSString *)_bundleName bundleId:(NSString *)_bundle icon:(NSImage *)_icon lastUsed:(NSDate *)_used andUseCount:(int)_count;
@end
