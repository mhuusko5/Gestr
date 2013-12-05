#import "Application.h"

@implementation Application

- (id)initWithDisplayName:(NSString *)displayName icon:(NSImage *)icon bundleId:(NSString *)bundleId {
	NSString *launchId = bundleId;
    
	self = [super initWithDisplayName:displayName launchId:launchId icon:icon];
    
	_bundleId = bundleId;
    
	return self;
}

- (void)launch {
	[[NSWorkspace sharedWorkspace] launchAppWithBundleIdentifier:self.bundleId options:NSWorkspaceLaunchDefault additionalEventParamDescriptor:nil launchIdentifier:nil];
}

@end
