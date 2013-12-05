#import "GestureTemplate.h"

@implementation GestureTemplate

- (id)initWithPoints:(GestureStroke *)points {
	self = [super init];

	_originalStroke = points;

	_stroke = GUResample(_originalStroke);
	_stroke = GUScale(_stroke);
	_stroke = GUTranslateToOrigin(_stroke);

	_startUnitVector = GUCalcStartUnitVector(_stroke);

	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:self.originalStroke forKey:@"originalStroke"];
	[coder encodeObject:self.stroke forKey:@"stroke"];
	[coder encodeObject:self.startUnitVector forKey:@"startUnitVector"];
}

- (id)initWithCoder:(NSCoder *)coder {
	self = [super init];

	_originalStroke = [coder decodeObjectForKey:@"originalStroke"];
	_stroke = [coder decodeObjectForKey:@"stroke"];
	_startUnitVector = [coder decodeObjectForKey:@"startUnitVector"];

	return self;
}

- (id)copyWithZone:(NSZone *)zone {
	GestureTemplate *copy = [[GestureTemplate allocWithZone:zone] initWithPoints:[self.originalStroke copy]];

	return copy;
}

- (NSString *)description {
	NSMutableString *desc = [[NSMutableString alloc] init];
	for (GesturePoint *point in self.stroke.points) {
		[desc appendFormat:@"%@ \r", [point description]];
	}

	return desc;
}

@end
