#import "GestureStroke.h"

@implementation GestureStroke

- (id)init {
	self = [super init];

	_points = [NSMutableArray array];

	return self;
}

- (id)initWithPoints:(NSMutableArray *)points {
	self = [super init];

	_points = points;

	return self;
}

- (void)addPoint:(GesturePoint *)point {
	[_points addObject:point];
}

- (int)pointCount {
	return (int)_points.count;
}

- (GesturePoint *)pointAtIndex:(int)i {
	return _points[i];
}

- (void)insertPoint:(GesturePoint *)point atIndex:(int)i {
	[_points insertObject:point atIndex:i];
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:_points forKey:@"points"];
}

- (id)initWithCoder:(NSCoder *)coder {
	self = [super init];

	_points = [[coder decodeObjectForKey:@"points"] mutableCopy];

	return self;
}

- (id)copyWithZone:(NSZone *)zone {
	GestureStroke *copy = [[GestureStroke allocWithZone:zone] initWithPoints:[_points mutableCopy]];

	return copy;
}

- (NSString *)description {
	NSMutableString *desc = [[NSMutableString alloc] init];
	for (GesturePoint *point in _points) {
		[desc appendFormat:@"%@ \r", [point description]];
	}

	return desc;
}

@end
