#import "GestureStroke.h"

@implementation GestureStroke

@synthesize points;

- (id)init {
	self = [super init];
    
	points = [NSMutableArray array];
    
	return self;
}

- (id)initWithPoints:(NSMutableArray *)_points {
	self = [super init];
    
	points = [NSMutableArray arrayWithArray:_points];
    
	return self;
}

- (void)addPoint:(GesturePoint *)point {
	[points addObject:point];
}

- (int)pointCount {
	return (int)points.count;
}

- (void)insertPoint:(GesturePoint *)point AtIndex:(int)index {
	[points insertObject:point atIndex:index];
}

- (GesturePoint *)pointAtIndex:(int)i {
	return [points objectAtIndex:i];
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:points forKey:@"points"];
}

- (id)initWithCoder:(NSCoder *)coder {
	self = [super init];
    
	points = [coder decodeObjectForKey:@"points"];
    
	return self;
}

- (id)copyWithZone:(NSZone *)zone {
	GestureStroke *copy = [[GestureStroke allocWithZone:zone] initWithPoints:[points copy]];
    
	return copy;
}

- (NSString *)description {
	NSMutableString *desc = [[NSMutableString alloc] init];
	for (GesturePoint *point in points) {
		[desc appendFormat:@"%@ \r", [point description]];
	}
    
	return desc;
}

@end
