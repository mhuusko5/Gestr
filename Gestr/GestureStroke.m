#import "GestureStroke.h"

@implementation GestureStroke

- (id)init {
	self = [super init];

	_points = [NSMutableArray array];

	return self;
}

- (id)initWithPoints:(NSMutableArray *)points {
	self = [super init];

	_points = [NSMutableArray arrayWithArray:points];

	return self;
}

- (void)addPoint:(GesturePoint *)point {
	[self.points addObject:point];
}

- (int)pointCount {
	return (int)self.points.count;
}

- (void)insertPoint:(GesturePoint *)point AtIndex:(int)index {
	[self.points insertObject:point atIndex:index];
}

- (GesturePoint *)pointAtIndex:(int)i {
	return (self.points)[i];
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:self.points forKey:@"points"];
}

- (id)initWithCoder:(NSCoder *)coder {
	self = [super init];

	_points = [coder decodeObjectForKey:@"points"];

	return self;
}

- (id)copyWithZone:(NSZone *)zone {
	GestureStroke *copy = [[GestureStroke allocWithZone:zone] initWithPoints:[self.points copy]];

	return copy;
}

- (NSString *)description {
	NSMutableString *desc = [[NSMutableString alloc] init];
	for (GesturePoint *point in self.points) {
		[desc appendFormat:@"%@ \r", [point description]];
	}

	return desc;
}

@end
