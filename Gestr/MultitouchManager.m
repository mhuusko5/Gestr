#import "MultitouchManager.h"

@implementation MultitouchManager

@synthesize forwardingMultitouchEventsToListeners;

- (void)handleMultitouchEvent:(MultitouchEvent *)event {
	if (forwardingMultitouchEventsToListeners) {
		for (MultitouchListener *multitouchListenerToForwardEvent in multitouchListeners) {
			[multitouchListenerToForwardEvent sendMultitouchEvent:event];
		}
	}
}

- (void)startForwardingMultitouchEventsToListeners {
	if ([[NSThread currentThread] isMainThread]) {
		if (!forwardingMultitouchEventsToListeners) {
			NSArray *mtDevices = (NSArray *)CFBridgingRelease(MTDeviceCreateList());
            
            BOOL anyAttachedMtDevices = NO;
            
			for (id device in mtDevices) {
				MTDeviceRef mtDevice = (__bridge MTDeviceRef)device;
				MTRegisterContactFrameCallback(mtDevice, mtEventHandler);
				MTDeviceStart(mtDevice, 0);
                
                anyAttachedMtDevices = YES;
                
				[multitouchDevices addObject:device];
			}
            
			forwardingMultitouchEventsToListeners = anyAttachedMtDevices;
		}
	}
	else {
		[self performSelectorOnMainThread:@selector(startForwardingMultitouchEventsToListeners) withObject:nil waitUntilDone:NO];
	}
}

- (void)stopForwardingMultitouchEventsToListeners {
	if ([[NSThread currentThread] isMainThread]) {
		if (forwardingMultitouchEventsToListeners) {
			for (int i = (int)multitouchDevices.count - 1; i > 0; i--) {
				id device = [multitouchDevices objectAtIndex:i];
				[multitouchDevices removeObject:device];
                
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
            
			forwardingMultitouchEventsToListeners = NO;
		}
	}
	else {
		[self performSelectorOnMainThread:@selector(stopForwardingMultitouchEventsToListeners) withObject:nil waitUntilDone:NO];
	}
}

- (void)removeMultitouchListersWithTarget:(id)target andCallback:(SEL)callback {
	for (MultitouchListener *multitouchListerToRemove in multitouchListeners) {
		if ([multitouchListerToRemove.target isEqual:target] && (!callback || multitouchListerToRemove.callback == callback)) {
			[multitouchListeners removeObject:multitouchListerToRemove];
		}
	}
}

- (void)addMultitouchListenerWithTarget:(id)target callback:(SEL)callback andThread:(NSThread *)thread {
	[multitouchListeners addObject:[[MultitouchListener alloc] initWithTarget:target callback:callback andThread:thread]];
    
	[self startForwardingMultitouchEventsToListeners];
}

static int mtEventHandler(int mtEventDeviceId, MTTouch *mtEventTouches, int mtEventTouchesNum, double mtEventTimestamp, int mtEventFrameId) {
	MultitouchEvent *multitouchEvent = [[MultitouchEvent alloc] initWithDeviceIdentifier:mtEventDeviceId frameIdentifier:mtEventDeviceId andTimestamp:mtEventTimestamp];
    
	NSMutableArray *multitouchTouches = [[NSMutableArray alloc] initWithCapacity:mtEventTouchesNum];
	for (int i = 0; i < mtEventTouchesNum; i++) {
		MultitouchTouch *multitouchTouch = [[MultitouchTouch alloc] initWithMTTouch:&mtEventTouches[i] andMultitouchEvent:multitouchEvent];
		[multitouchTouches addObject:multitouchTouch];
	}
    
	[multitouchEvent setTouches:[NSArray arrayWithArray:multitouchTouches]];
    
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
    
	multitouchListeners = [NSMutableArray array];
	multitouchDevices = [NSMutableArray array];
    
	[[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(restartMultitouchEventForwardingAfterWake:) name:NSWorkspaceDidWakeNotification object:nil];
    
	return self;
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
