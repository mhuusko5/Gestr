#import "App.h"

@implementation App

@synthesize name, icon, bundle, lastUsed, useCount;

- (id)initWithName:(NSString *)_name andIcon:(NSImage *)_icon andBundle:(NSString *)_bundle andLastUsed:(NSDate *)_used andUseCount:(int)_count {
	self = [super init];
    
	self.name = _name;
	self.icon = _icon;
	self.bundle = _bundle;
	self.lastUsed = _used;
	self.useCount = _count;
    
	return self;
}

@end
