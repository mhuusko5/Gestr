#import "Gesture.h"

@implementation Gesture

- (id)initWithIdentity:(NSString *)identity andStrokes:(NSMutableArray *)strokes {
	self = [super init];

	_identity = identity;
	_strokes = strokes;

	return self;
}

- (void)generateTemplates {
	self.templates = [NSMutableArray array];

	GestureStroke *allPoints = [[GestureStroke alloc] init];
	for (GestureStroke *stroke in self.strokes) {
		for (GesturePoint *point in stroke.points) {
			[allPoints addPoint:point];
		}
	}

	NSMutableArray *order = [NSMutableArray array];
	for (int i = 0; i < self.strokes.count; i++) {
		[order insertObject:@(i) atIndex:i];
	}

	NSMutableArray *unistrokes = GUMakeUnistrokes(self.strokes, GUHeapPermute((int)self.strokes.count, order, [NSMutableArray array]));

	for (int j = 0; j < unistrokes.count; j++) {
		[self.templates addObject:[[GestureTemplate alloc] initWithPoints:unistrokes[j]]];
	}
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:self.strokes forKey:@"strokes"];
	[coder encodeObject:self.identity forKey:@"identity"];
}

- (id)initWithCoder:(NSCoder *)coder {
	self = [super init];

	self.strokes = [coder decodeObjectForKey:@"strokes"];
	self.identity = [coder decodeObjectForKey:@"identity"];

	return self;
}

- (id)copyWithZone:(NSZone *)zone {
	Gesture *copy = [[Gesture allocWithZone:zone] initWithIdentity:[self.identity copy] andStrokes:[self.strokes copy]];

	return copy;
}

- (NSString *)description {
	NSMutableString *desc = [[NSMutableString alloc] init];
	for (GestureStroke *stroke in self.strokes) {
		[desc appendFormat:@"%@ \r", [stroke description]];
	}

	return desc;
}

@end
