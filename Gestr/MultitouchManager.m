#import "MultitouchManager.h"

@interface MultitouchManager ()

@property NSMutableArray *multitouchListeners;
@property NSMutableArray *multitouchDevices;
@property BOOL forwardingMultitouchEventsToListeners;
@property NSTimer *multitouchHardwareCheckTimer;

@end

@implementation MultitouchManager

static BOOL laptopLidClosed = NO;
- (void)checkMultitouchHardware {
	CGDirectDisplayID builtInDisplay = 0;
	CGDirectDisplayID activeDisplays[10];
	uint32_t numActiveDisplays;
	CGGetActiveDisplayList(10, activeDisplays, &numActiveDisplays);

	while (numActiveDisplays-- > 0) {
		if (CGDisplayIsBuiltin(activeDisplays[numActiveDisplays])) {
			builtInDisplay = activeDisplays[numActiveDisplays];
			break;
		}
	}

	laptopLidClosed = (builtInDisplay == 0);

	NSArray *mtDevices = (NSArray *)CFBridgingRelease(MTDeviceCreateList());

	int mtDeviceCount = (int)mtDevices.count;
	if (mtDeviceCount != _multitouchDevices.count) {
		[_multitouchHardwareCheckTimer invalidate];
		_multitouchHardwareCheckTimer = nil;

		[self restartMultitouchEventForwardingAfterWake:nil];
	}
}

- (void)handleMultitouchEvent:(MultitouchEvent *)event {
	if (_forwardingMultitouchEventsToListeners) {
		int multitouchListenerCount = (int)_multitouchListeners.count;
		while (multitouchListenerCount-- > 0) {
			MultitouchListener *multitouchListenerToForwardEvent = _multitouchListeners[multitouchListenerCount];
			[multitouchListenerToForwardEvent sendMultitouchEvent:event];
		}
	}
}

- (void)startForwardingMultitouchEventsToListeners {
	if ([[NSThread currentThread] isMainThread]) {
		if (!_forwardingMultitouchEventsToListeners && [MultitouchManager systemIsMultitouchCapable]) {
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

				[_multitouchDevices addObject:device];
			}

			_multitouchHardwareCheckTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(checkMultitouchHardware) userInfo:nil repeats:YES];

			_forwardingMultitouchEventsToListeners = YES;
		}
	}
	else {
		[self performSelectorOnMainThread:@selector(startForwardingMultitouchEventsToListeners) withObject:nil waitUntilDone:NO];
	}
}

- (void)stopForwardingMultitouchEventsToListeners {
	if ([[NSThread currentThread] isMainThread]) {
		if (_forwardingMultitouchEventsToListeners) {
			[_multitouchHardwareCheckTimer invalidate];
			_multitouchHardwareCheckTimer = nil;

			int multitouchDeviceCount = (int)_multitouchDevices.count;
			while (multitouchDeviceCount-- > 0) {
				id device = _multitouchDevices[multitouchDeviceCount];

				[_multitouchDevices removeObject:device];

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

			_forwardingMultitouchEventsToListeners = NO;
		}
	}
	else {
		[self performSelectorOnMainThread:@selector(stopForwardingMultitouchEventsToListeners) withObject:nil waitUntilDone:NO];
	}
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

- (void)removeMultitouchListenersWithTarget:(id)target andCallback:(SEL)callback {
	int multitouchListenerCount = (int)_multitouchListeners.count;
	while (multitouchListenerCount-- > 0) {
		MultitouchListener *multitouchListenerToRemove = _multitouchListeners[multitouchListenerCount];
		if ([multitouchListenerToRemove.target isEqual:target] && (!callback || multitouchListenerToRemove.callback == callback)) {
			[_multitouchListeners removeObject:multitouchListenerToRemove];
		}
	}
}

- (void)addMultitouchListenerWithTarget:(id)target callback:(SEL)callback andThread:(NSThread *)thread {
	[self removeMultitouchListenersWithTarget:target andCallback:callback];

	[_multitouchListeners addObject:[[MultitouchListener alloc] initWithTarget:target callback:callback andThread:thread]];

	[self startForwardingMultitouchEventsToListeners];
}

static void mtEventHandler(MTDeviceRef mtEventDevice, MTTouch mtEventTouches[], int mtEventTouchesNum, double mtEventTimestamp, int mtEventFrameId) {
	if (MTDeviceIsBuiltIn && MTDeviceIsBuiltIn(mtEventDevice) && laptopLidClosed) {
		/*When a Mac laptop lid is closed, it can cause the trackpad to send random
         multitouch input (insane, I know!). Obviously we want to ignore that input.*/
		return;
	}

	NSMutableArray *multitouchTouches = [[NSMutableArray alloc] initWithCapacity:mtEventTouchesNum];
	for (int i = 0; i < mtEventTouchesNum; i++) {
		MultitouchTouch *multitouchTouch = [[MultitouchTouch alloc] initWithMTTouch:&mtEventTouches[i]];
		multitouchTouches[i] = multitouchTouch;
	}

	MultitouchEvent *multitouchEvent = [[MultitouchEvent alloc] initWithDeviceIdentifier:(int)mtEventDevice frameIdentifier:mtEventFrameId timestamp:mtEventTimestamp andTouches:multitouchTouches];

	[[MultitouchManager sharedMultitouchManager] handleMultitouchEvent:multitouchEvent];
}

- (id)init {
	self = [super init];

	_multitouchListeners = [NSMutableArray array];
	_multitouchDevices = [NSMutableArray array];

	[[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(restartMultitouchEventForwardingAfterWake:) name:NSWorkspaceDidWakeNotification object:nil];

	return self;
}

+ (BOOL)systemIsMultitouchCapable {
	return MTDeviceIsAvailable();
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
