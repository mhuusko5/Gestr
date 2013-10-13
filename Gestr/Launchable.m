#import "Launchable.h"

@implementation Launchable

@synthesize displayName, launchId, icon;

- (id)initWithDisplayName:(NSString *)_displayName launchId:(NSString *)_launchId icon:(NSImage *)_icon {
	self = [super init];
    
	displayName = _displayName;
	launchId = _launchId;
	icon = _icon;
    
	return self;
}

- (void)launchWithNewThread:(BOOL)newThread {
	if (newThread) {
		[NSThread detachNewThreadSelector:@selector(launchWithNewThread:) toTarget:self withObject:NO];
	}
	else {
		@try {
			if ([self respondsToSelector:@selector(launch)]) {
				[self performSelector:@selector(launch)];
			}
		}
		@catch (NSException *exception)
		{
		}
	}
}

@end
