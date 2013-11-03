#import "MultitouchListener.h"

@implementation MultitouchListener

@synthesize target, callback, thread;

- (id)initWithTarget:(id)_target callback:(SEL)_callback andThread:(NSThread *)_thread {
	self = [super init];
    
	if (!_thread) {
		_thread = [NSThread currentThread];
	}
    
	target = _target;
	callback = _callback;
	thread = _thread;
    
	return self;
}

- (void)sendMultitouchEvent:(MultitouchEvent *)event {
	@try {
		[target performSelector:callback onThread:thread withObject:event waitUntilDone:NO];
	}
	@catch (NSException *exception)
	{
	}
}

@end
