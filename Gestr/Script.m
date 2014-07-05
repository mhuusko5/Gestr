#import "Script.h"

@implementation Script

- (id)initWithDisplayName:(NSString *)displayName icon:(NSImage *)icon fileURL:(NSURL *)fileURL {
    NSString *launchId = [fileURL path];

	self = [super initWithDisplayName:displayName launchId:launchId icon:icon];

	_script = [[NSAppleScript alloc] initWithContentsOfURL:fileURL error:nil];

	return self;
}

- (void)launch {
    @try {
        [_script executeAndReturnError:nil];
    }
    @catch (NSException *exception) {}
}

@end
