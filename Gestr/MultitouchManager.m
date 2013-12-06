#import "MultitouchManager.h"

@interface MultitouchManager ()

@property NSMutableArray *multitouchListeners;
@property NSMutableArray *multitouchDevices;
@property BOOL forwardingMultitouchEventsToListeners;

@end

@implementation MultitouchManager

- (void)handleMultitouchEvent:(MultitouchEvent *)event {
	if (self.forwardingMultitouchEventsToListeners) {
		int multitouchListenerCount = (int)self.multitouchListeners.count;
		while (multitouchListenerCount-- > 0) {
			MultitouchListener *multitouchListenerToForwardEvent = (self.multitouchListeners)[multitouchListenerCount];
			[multitouchListenerToForwardEvent sendMultitouchEvent:event];
		}
	}
}

- (void)startForwardingMultitouchEventsToListeners {
	if ([[NSThread currentThread] isMainThread]) {
		if (!self.forwardingMultitouchEventsToListeners && [MultitouchManager systemIsMultitouchCapable]) {
			NSArray *mtDevices = (NSArray *)CFBridgingRelease(MTDeviceCreateList());

			int mtDeviceCount = (int)mtDevices.count;
			while (mtDeviceCount-- > 0) {
				id device = mtDevices[mtDeviceCount];

				@try {
					MTDeviceRef mtDevice = (__bridge MTDeviceRef)device;
					MTRegisterContactFrameCallback(mtDevice, mtEventHandler);
					MTDeviceStart(mtDevice, 0);
				}
				@catch (NSException *exception)
				{
				}

				[self.multitouchDevices addObject:device];
			}

			self.forwardingMultitouchEventsToListeners = YES;
		}
	}
	else {
		[self performSelectorOnMainThread:@selector(startForwardingMultitouchEventsToListeners) withObject:nil waitUntilDone:NO];
	}
}

- (void)stopForwardingMultitouchEventsToListeners {
	if ([[NSThread currentThread] isMainThread]) {
		if (self.forwardingMultitouchEventsToListeners) {
			int multitouchDeviceCount = (int)self.multitouchDevices.count;
			while (multitouchDeviceCount-- > 0) {
				id device = (self.multitouchDevices)[multitouchDeviceCount];

				[self.multitouchDevices removeObject:device];

				@try {
					MTDeviceRef mtDevice = (__bridge MTDeviceRef)device;
					MTUnregisterContactFrameCallback(mtDevice, mtEventHandler);
					MTDeviceStop(mtDevice);
					MTDeviceRelease(mtDevice);
				}
				@catch (NSException *exception)
				{
				}
			}

			self.forwardingMultitouchEventsToListeners = NO;
		}
	}
	else {
		[self performSelectorOnMainThread:@selector(stopForwardingMultitouchEventsToListeners) withObject:nil waitUntilDone:NO];
	}
}

- (void)removeMultitouchListenersWithTarget:(id)target andCallback:(SEL)callback {
	int multitouchListenerCount = (int)self.multitouchListeners.count;
	while (multitouchListenerCount-- > 0) {
		MultitouchListener *multitouchListenerToRemove = (self.multitouchListeners)[multitouchListenerCount];
		if ([multitouchListenerToRemove.target isEqual:target] && (!callback || multitouchListenerToRemove.callback == callback)) {
			[self.multitouchListeners removeObject:multitouchListenerToRemove];
		}
	}
}

- (void)addMultitouchListenerWithTarget:(id)target callback:(SEL)callback andThread:(NSThread *)thread {
	[self removeMultitouchListenersWithTarget:target andCallback:callback];

	[self.multitouchListeners addObject:[[MultitouchListener alloc] initWithTarget:target callback:callback andThread:thread]];

	[self startForwardingMultitouchEventsToListeners];
}

static int mtEventHandler(int mtEventDeviceId, MTTouch *mtEventTouches, int mtEventTouchesNum, double mtEventTimestamp, int mtEventFrameId) {
	MultitouchEvent *multitouchEvent = [[MultitouchEvent alloc] initWithDeviceIdentifier:mtEventDeviceId frameIdentifier:mtEventFrameId andTimestamp:mtEventTimestamp];

	NSMutableArray *multitouchTouches = [[NSMutableArray alloc] initWithCapacity:mtEventTouchesNum];
	for (int i = 0; i < mtEventTouchesNum; i++) {
		MultitouchTouch *multitouchTouch = [[MultitouchTouch alloc] initWithMTTouch:&mtEventTouches[i] andMultitouchEvent:multitouchEvent];
		[multitouchTouches addObject:multitouchTouch];
	}

	multitouchEvent.touches = multitouchTouches;

	[[MultitouchManager sharedMultitouchManager] handleMultitouchEvent:multitouchEvent];

	return 0;
}

- (void)restartMultitouchEventForwardingAfterWake:(NSNotification *)wakeNotification {
	if ([[NSThread currentThread] isMainThread]) {
		[self stopForwardingMultitouchEventsToListeners];
		[self startForwardingMultitouchEventsToListeners];
	}
	else {
		[self performSelectorOnMainThread:@selector(restartMultitouchEventForwardingAfterWake:) withObject:wakeNotification waitUntilDone:NO];
	}
}

- (id)init {
	self = [super init];

	_multitouchListeners = [NSMutableArray array];
	_multitouchDevices = [NSMutableArray array];

	[[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(restartMultitouchEventForwardingAfterWake:) name:NSWorkspaceDidWakeNotification object:nil];

	return self;
}

+ (BOOL)systemIsMultitouchCapable {
	return ((__bridge_transfer NSArray *)MTDeviceCreateList()).count > 0;
}

static MultitouchManager *sharedMultitouchManager = nil;

+ (void)initialize {
	if (!sharedMultitouchManager && self == [MultitouchManager class]) {
		sharedMultitouchManager = [[self alloc] init];
	}
}

+ (MultitouchManager *)sharedMultitouchManager {
	return sharedMultitouchManager;
}

@end
