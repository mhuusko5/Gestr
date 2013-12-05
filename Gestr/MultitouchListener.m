#import "MultitouchListener.h"

@implementation MultitouchListener

- (id)initWithTarget:(id)target callback:(SEL)callback andThread:(NSThread *)thread {
	self = [super init];

	if (!thread) {
		thread = [NSThread currentThread];
	}

	_target = target;
	_callback = callback;
	_thread = thread;

	return self;
}

- (void)sendMultitouchEvent:(MultitouchEvent *)event {
	@try {
		[self.target performSelector:self.callback onThread:self.thread withObject:event waitUntilDone:NO];
	}
	@catch (NSException *exception)
	{
	}
}

@end
