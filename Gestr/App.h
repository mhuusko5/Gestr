#import <Foundation/Foundation.h>

@interface App : NSObject {
	NSString *name;
	NSImage *icon;
	NSString *bundle;
	NSDate *lastUsed;
	int useCount;
}
@property (assign) NSString *name, *bundle;
@property (assign) NSImage *icon;
@property (assign) NSDate *lastUsed;
@property (assign) int useCount;

- (id)initWithName:(NSString *)_name andIcon:(NSImage *)_icon andBundle:(NSString *)_bundle andLastUsed:(NSDate *)_used andUseCount:(int)_count;
@end
