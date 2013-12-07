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
	[_target performSelector:_callback onThread:_thread withObject:event waitUntilDone:NO];
}

@end
