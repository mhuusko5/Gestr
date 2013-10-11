#import "App.h"

@implementation App

@synthesize displayName, bundleName, bundleId, icon, lastUsed, useCount;

- (id)initWithDisplayName:(NSString *)_displayName bundleName:(NSString *)_bundleName bundleId:(NSString *)_bundle icon:(NSImage *)_icon lastUsed:(NSDate *)_used andUseCount:(int)_count {
	self = [super init];
    
	self.displayName = _displayName;
	self.bundleName = _bundleName;
	self.bundleId = _bundle;
	self.icon = _icon;
	self.lastUsed = _used;
	self.useCount = _count;
    
	return self;
}

@end
