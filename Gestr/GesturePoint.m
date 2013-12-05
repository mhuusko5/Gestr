#import "GesturePoint.h"

@interface GesturePoint ()

@property NSValue *pointValue;

@end

@implementation GesturePoint

- (id)initWithX:(float)x andY:(float)y andStrokeId:(int)strokeId {
	self = [super init];

#if (TARGET_OS_IPHONE || TARGET_OS_IPAD || TARGET_IPHONE_SIMULATOR)
	_pointValue = [NSValue valueWithCGPoint:CGPointMake(x, y)];
#else
	_pointValue = [NSValue valueWithPoint:NSMakePoint(x, y)];
#endif

	_strokeId = strokeId;

	return self;
}

#if (TARGET_OS_IPHONE || TARGET_OS_IPAD || TARGET_IPHONE_SIMULATOR)
- (id)initWithPoint:(CGPoint)point andStrokeId:(int)strokeId {
	return [self initWithX:point.x andY:point.y andStrokeId:strokeId];
}

#else
- (id)initWithPoint:(NSPoint)point andStrokeId:(int)strokeId {
	return [self initWithX:point.x andY:point.y andStrokeId:strokeId];
}

#endif


- (id)initWithValue:(NSValue *)value andStrokeId:(int)strokeId {
	self = [super init];

	_pointValue = value;
	_strokeId = strokeId;

	return self;
}

- (void)setX:(float)x {
#if (TARGET_OS_IPHONE || TARGET_OS_IPAD || TARGET_IPHONE_SIMULATOR)
	self.pointValue = [NSValue valueWithCGPoint:CGPointMake(x, [self getY])];
#else
	self.pointValue = [NSValue valueWithPoint:NSMakePoint(x, [self getY])];
#endif
}

- (void)setY:(float)y {
#if (TARGET_OS_IPHONE || TARGET_OS_IPAD || TARGET_IPHONE_SIMULATOR)
	self.pointValue = [NSValue valueWithCGPoint:CGPointMake([self getX], y)];
#else
	self.pointValue = [NSValue valueWithPoint:NSMakePoint([self getX], y)];
#endif
}

- (float)getX {
#if (TARGET_OS_IPHONE || TARGET_OS_IPAD || TARGET_IPHONE_SIMULATOR)
	return [self.pointValue CGPointValue].x;
#else
	return [self.pointValue pointValue].x;
#endif
}

- (float)getY {
#if (TARGET_OS_IPHONE || TARGET_OS_IPAD || TARGET_IPHONE_SIMULATOR)
	return [self.pointValue CGPointValue].y;
#else
	return [self.pointValue pointValue].y;
#endif
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:self.pointValue forKey:@"point"];
	[coder encodeObject:@(self.strokeId) forKey:@"strokeId"];
}

- (id)initWithCoder:(NSCoder *)coder {
	self = [super init];

	_pointValue = [coder decodeObjectForKey:@"point"];
	_strokeId = [[coder decodeObjectForKey:@"strokeId"] intValue];

	return self;
}

- (id)copyWithZone:(NSZone *)zone {
	GesturePoint *copy = [[GesturePoint allocWithZone:zone] initWithValue:[self.pointValue copy] andStrokeId:self.strokeId];

	return copy;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"X: %f Y: %f Stroke: %i", [self getX], [self getY], self.strokeId];
}

@end
