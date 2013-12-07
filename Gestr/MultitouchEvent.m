#import "MultitouchEvent.h"

@implementation MultitouchEvent

- (id)initWithDeviceIdentifier:(int)deviceId frameIdentifier:(int)frameId timestamp:(double)timestamp andTouches:(NSArray *)touches {
	self = [super init];

	_deviceIdentifier = @(deviceId);
	_frameIdentifier = @(frameId);
	_timestamp = timestamp;
	_touches = touches;

	return self;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"Device: %i, Frame: %i, Time: %f, Touches: %@", [_deviceIdentifier intValue], [_frameIdentifier intValue], _timestamp, [_touches description]];
}

@end
