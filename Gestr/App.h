#import <Foundation/Foundation.h>

@interface App : NSObject {
	NSString *displayName;
	NSImage *icon;
	NSString *bundleId;
	NSDate *lastUsed;
	int useCount;
}
@property (assign) NSString *displayName, *bundleId;
@property (assign) NSImage *icon;
@property (assign) NSDate *lastUsed;
@property (assign) int useCount;

- (id)initWithDisplayName:(NSString *)_displayName andIcon:(NSImage *)_icon andBundle:(NSString *)_bundle andLastUsed:(NSDate *)_used andUseCount:(int)_count;
@end
