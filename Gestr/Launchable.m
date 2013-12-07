#import "Launchable.h"

@implementation Launchable

- (id)initWithDisplayName:(NSString *)displayName launchId:(NSString *)launchId icon:(NSImage *)icon {
	self = [super init];

	_displayName = displayName;
	_launchId = launchId;
	_icon = icon;

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
