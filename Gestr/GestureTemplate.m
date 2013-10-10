#import "GestureTemplate.h"

@implementation GestureTemplate

@synthesize stroke, startUnitVector, originalStroke;

- (id)initWithPoints:(GestureStroke *)_points {
	self = [super init];
    
	originalStroke = _points;
    
	stroke = GUResample(originalStroke);
	stroke = GUScale(stroke);
	stroke = GUTranslateToOrigin(stroke);
    
	startUnitVector = GUCalcStartUnitVector(stroke);
    
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:originalStroke forKey:@"originalStroke"];
	[coder encodeObject:stroke forKey:@"stroke"];
	[coder encodeObject:startUnitVector forKey:@"startUnitVector"];
}

- (id)initWithCoder:(NSCoder *)coder {
	self = [super init];
    
	originalStroke = [coder decodeObjectForKey:@"originalStroke"];
	stroke = [coder decodeObjectForKey:@"stroke"];
	startUnitVector = [coder decodeObjectForKey:@"startUnitVector"];
    
	return self;
}

- (id)copyWithZone:(NSZone *)zone {
	GestureTemplate *copy = [[GestureTemplate allocWithZone:zone] initWithPoints:[originalStroke copy]];
    
	return copy;
}

- (NSString *)description {
	NSMutableString *desc = [[NSMutableString alloc] init];
	for (GesturePoint *point in stroke.points) {
		[desc appendFormat:@"%@ \r", [point description]];
	}
    
	return desc;
}

@end
