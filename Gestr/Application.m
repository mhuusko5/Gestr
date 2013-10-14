#import "Application.h"

@implementation Application

@synthesize bundleId;

- (id)initWithDisplayName:(NSString *)_displayName icon:(NSImage *)_icon bundleId:(NSString *)_bundleId {
	NSString *_launchId = _bundleId;
    
	self = [super initWithDisplayName:_displayName launchId:_launchId icon:_icon];
    
	bundleId = _bundleId;
    
	return self;
}

- (void)launch {
	[[NSWorkspace sharedWorkspace] launchAppWithBundleIdentifier:bundleId options:NSWorkspaceLaunchDefault additionalEventParamDescriptor:nil launchIdentifier:nil];
}

@end
