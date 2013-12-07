#import "Gesture.h"

@implementation Gesture

- (id)initWithIdentity:(NSString *)identity andStrokes:(NSMutableArray *)strokes {
	self = [super init];

	_identity = identity;
	_strokes = strokes;

	return self;
}

- (void)generateTemplates {
	GestureStroke *allPoints = [[GestureStroke alloc] init];
	for (GestureStroke *stroke in _strokes) {
		for (GesturePoint *point in stroke.points) {
			[allPoints addPoint:point];
		}
	}

	NSMutableArray *order = [NSMutableArray array];
	for (int i = 0; i < _strokes.count; i++) {
		[order insertObject:@(i) atIndex:i];
	}

	NSMutableArray *unistrokes = GUMakeUnistrokes(_strokes, GUHeapPermute((int)_strokes.count, order, [NSMutableArray array]));

	_templates = [NSMutableArray array];
	for (int j = 0; j < unistrokes.count; j++) {
		[_templates addObject:[[GestureTemplate alloc] initWithPoints:unistrokes[j]]];
	}
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:_strokes forKey:@"strokes"];
	[coder encodeObject:_identity forKey:@"identity"];
}

- (id)initWithCoder:(NSCoder *)coder {
	self = [super init];

	_strokes = [coder decodeObjectForKey:@"strokes"];
	_identity = [coder decodeObjectForKey:@"identity"];

	return self;
}

- (id)copyWithZone:(NSZone *)zone {
	Gesture *copy = [[Gesture allocWithZone:zone] initWithIdentity:[_identity copy] andStrokes:[_strokes copy]];

	return copy;
}

- (NSString *)description {
	NSMutableString *desc = [[NSMutableString alloc] init];
	for (GestureStroke *stroke in _strokes) {
		[desc appendFormat:@"%@ \r", [stroke description]];
	}

	return desc;
}

@end
