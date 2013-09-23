#import "MultitouchEvent.h"

@implementation MultitouchEvent

@synthesize deviceIdentifier, frameIdentifier, timestamp, touches;

- (id)initWithDeviceIdentifier:(int)deviceId frameIdentifier:(int)frameId andTimestamp:(double)_timestamp {
	self = [super init];
    
	deviceIdentifier = [NSNumber numberWithInt:deviceId];
	frameIdentifier = [NSNumber numberWithInt:frameId];
	timestamp = _timestamp;
    
	return self;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"Device: %i, Frame: %i, Time: %f, Touches: %@", [deviceIdentifier intValue], [frameIdentifier intValue], timestamp, [touches description]];
}

@end
