#import "MultitouchTouch.h"

@implementation MultitouchTouch

- (id)initWithMTTouch:(MTTouch *)touch {
	self = [super init];

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
	return [NSString stringWithFormat:@"Id: %i, State: %i, X: %f, Y: %f, MinorAxis: %f, MajorAxis: %f, Angle: %f, Size: %f, VelocityX: %f, VelocityY: %f", [_identifier intValue], _state, _x, _y, _minorAxis, _majorAxis, _angle, _size, _velX, _velY];
}

@end
