#import "App.h"

@implementation App

@synthesize displayName, icon, bundleId, lastUsed, useCount;

- (id)initWithDisplayName:(NSString *)_displayName andIcon:(NSImage *)_icon andBundle:(NSString *)_bundle andLastUsed:(NSDate *)_used andUseCount:(int)_count {
	self = [super init];
    
	self.displayName = _displayName;
	self.icon = _icon;
	self.bundleId = _bundle;
	self.lastUsed = _used;
	self.useCount = _count;
    
	return self;
}

@end
