#import "GesturePoint.h"

@implementation GesturePoint

@synthesize strokeId;

- (id)initWithX:(float)_x andY:(float)_y andStrokeId:(int)_strokeId {
	self = [super init];
    
#if (TARGET_OS_IPHONE || TARGET_OS_IPAD || TARGET_IPHONE_SIMULATOR)
	point = [NSValue valueWithCGPoint:CGPointMake(_x, _y)];
#else
	point = [NSValue valueWithPoint:NSMakePoint(_x, _y)];
#endif
    
	strokeId = _strokeId;
    
	return self;
}

#if (TARGET_OS_IPHONE || TARGET_OS_IPAD || TARGET_IPHONE_SIMULATOR)
- (id)initWithPoint:(CGPoint)_point andStrokeId:(int)_strokeId {
	return [self initWithX:_point.x andY:_point.y andStrokeId:_strokeId];
}

#else
- (id)initWithPoint:(NSPoint)_point andStrokeId:(int)_strokeId {
	return [self initWithX:_point.x andY:_point.y andStrokeId:_strokeId];
}

#endif


- (id)initWithValue:(NSValue *)_value andStrokeId:(int)_strokeId {
	self = [super init];
    
	point = _value;
	strokeId = _strokeId;
    
	return self;
}

- (void)setX:(float)_x {
#if (TARGET_OS_IPHONE || TARGET_OS_IPAD || TARGET_IPHONE_SIMULATOR)
	point = [NSValue valueWithCGPoint:CGPointMake(_x, [self getY])];
#else
	point = [NSValue valueWithPoint:NSMakePoint(_x, [self getY])];
#endif
}

- (void)setY:(float)_y {
#if (TARGET_OS_IPHONE || TARGET_OS_IPAD || TARGET_IPHONE_SIMULATOR)
	point = [NSValue valueWithCGPoint:CGPointMake([self getX], _y)];
#else
	point = [NSValue valueWithPoint:NSMakePoint([self getX], _y)];
#endif
}

- (float)getX {
#if (TARGET_OS_IPHONE || TARGET_OS_IPAD || TARGET_IPHONE_SIMULATOR)
	return [point CGPointValue].x;
#else
	return [point pointValue].x;
#endif
}

- (float)getY {
#if (TARGET_OS_IPHONE || TARGET_OS_IPAD || TARGET_IPHONE_SIMULATOR)
	return [point CGPointValue].y;
#else
	return [point pointValue].y;
#endif
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:point forKey:@"point"];
	[coder encodeObject:[NSNumber numberWithInt:strokeId] forKey:@"strokeId"];
}

- (id)initWithCoder:(NSCoder *)coder {
	self = [super init];
    
	point = [coder decodeObjectForKey:@"point"];
	strokeId = [[coder decodeObjectForKey:@"strokeId"] intValue];
    
	return self;
}

- (id)copyWithZone:(NSZone *)zone {
	GesturePoint *copy = [[GesturePoint allocWithZone:zone] initWithValue:[point copy] andStrokeId:strokeId];
    
	return copy;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"X: %f Y: %f Stroke: %i", [self getX], [self getY], strokeId];
}

@end
