#import "MultitouchTouch.h"

@implementation MultitouchTouch

@synthesize event, identifier, state, x, y, minorAxis, majorAxis, angle, size, velX, velY;

- (id)initWithMTTouch:(MTTouch *)touch andMultitouchEvent:(MultitouchEvent *)_event {
	self = [super init];
    
	event = _event;
	identifier = [NSNumber numberWithInt:touch->identifier];
	state = touch->state;
	x = touch->normalized.position.x;
	y = touch->normalized.position.y;
	minorAxis = touch->minorAxis;
	majorAxis = touch->majorAxis;
	angle = touch->angle;
	size = touch->size;
	velX = touch->normalized.velocity.x;
	velY = touch->normalized.velocity.y;
    
	return self;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"Id: %i, State: %i, X: %f, Y: %f, MinorAxis: %f, MajorAxis: %f, Angle: %f, Size: %f, VelocityX: %f, VelocityY: %f", [identifier intValue], state, x, y, minorAxis, majorAxis, angle, size, velX, velY];
}

@end
