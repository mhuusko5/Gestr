#import "MultitouchTouch.h"

@implementation MultitouchTouch

- (id)initWithMTTouch:(MTTouch *)touch andMultitouchEvent:(MultitouchEvent *)event {
	self = [super init];

	_event = event;
	_identifier = @(touch->identifier);
	_state = touch->state;
	_x = touch->normalized.position.x;
	_y = touch->normalized.position.y;
	_minorAxis = touch->minorAxis;
	_majorAxis = touch->majorAxis;
	_angle = touch->angle;
	_size = touch->size;
	_velX = touch->normalized.velocity.x;
	_velY = touch->normalized.velocity.y;

	return self;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"Id: %i, State: %i, X: %f, Y: %f, MinorAxis: %f, MajorAxis: %f, Angle: %f, Size: %f, VelocityX: %f, VelocityY: %f", [self.identifier intValue], self.state, self.x, self.y, self.minorAxis, self.majorAxis, self.angle, self.size, self.velX, self.velY];
}

@end
