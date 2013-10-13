#import "Application.h"

@implementation Application

- (void)launch {
	[[NSWorkspace sharedWorkspace] launchAppWithBundleIdentifier:launchId options:NSWorkspaceLaunchDefault additionalEventParamDescriptor:nil launchIdentifier:nil];
}

@end
