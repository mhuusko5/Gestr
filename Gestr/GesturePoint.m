#import "GesturePoint.h"

@implementation GesturePoint

- (id)initWithX:(float)x andY:(float)y andStrokeId:(int)strokeId {
	self = [super init];

	_x = x;
	_y = y;
	_strokeId = strokeId;

	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeFloat:_x forKey:@"x"];
	[coder encodeFloat:_y forKey:@"y"];
	[coder encodeInt:_strokeId forKey:@"strokeId"];
}

- (id)initWithCoder:(NSCoder *)coder {
	self = [super init];

	_x = [coder decodeFloatForKey:@"x"];
	_y = [coder decodeFloatForKey:@"y"];
	_strokeId = [coder decodeIntForKey:@"strokeId"];

	return self;
}

- (id)copyWithZone:(NSZone *)zone {
	GesturePoint *copy = [[GesturePoint allocWithZone:zone] initWithX:_x andY:_y andStrokeId:_strokeId];

	return copy;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"X: %f Y: %f Stroke: %i", _x, _y, _strokeId];
}

@end
