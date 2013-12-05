#import "MultitouchEvent.h"

@implementation MultitouchEvent

- (id)initWithDeviceIdentifier:(int)deviceId frameIdentifier:(int)frameId andTimestamp:(double)timestamp {
	self = [super init];

	_deviceIdentifier = @(deviceId);
	_frameIdentifier = @(frameId);
	_timestamp = timestamp;

	return self;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"Device: %i, Frame: %i, Time: %f, Touches: %@", [self.deviceIdentifier intValue], [self.frameIdentifier intValue], self.timestamp, [self.touches description]];
}

@end
