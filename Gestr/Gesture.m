#import "Gesture.h"

@implementation Gesture

@synthesize identity, strokes, templates;

- (id)initWithIdentity:(NSString *)_identity andStrokes:(NSMutableArray *)_strokes {
	self = [super init];
    
	identity = _identity;
	strokes = _strokes;
    
	return self;
}

- (void)generateTemplates {
	templates = [NSMutableArray array];
    
	GestureStroke *allPoints = [[GestureStroke alloc] init];
	for (GestureStroke *stroke in strokes) {
		for (GesturePoint *point in stroke.points) {
			[allPoints addPoint:point];
		}
	}
    
	NSMutableArray *order = [NSMutableArray array];
	for (int i = 0; i < strokes.count; i++) {
		[order insertObject:[NSNumber numberWithInt:i] atIndex:i];
	}
    
	NSMutableArray *unistrokes = GUMakeUnistrokes(strokes, GUHeapPermute((int)strokes.count, order, [NSMutableArray array]));
    
	for (int j = 0; j < unistrokes.count; j++) {
		[templates addObject:[[GestureTemplate alloc] initWithPoints:[unistrokes objectAtIndex:j]]];
	}
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:strokes forKey:@"strokes"];
	[coder encodeObject:identity forKey:@"identity"];
}

- (id)initWithCoder:(NSCoder *)coder {
	self = [super init];
    
	strokes = [coder decodeObjectForKey:@"strokes"];
	identity = [coder decodeObjectForKey:@"identity"];
    
	return self;
}

- (id)copyWithZone:(NSZone *)zone {
	Gesture *copy = [[Gesture allocWithZone:zone] initWithIdentity:[identity copy] andStrokes:[strokes copy]];
    
	return copy;
}

- (NSString *)description {
	NSMutableString *desc = [[NSMutableString alloc] init];
	for (GestureStroke *stroke in strokes) {
		[desc appendFormat:@"%@ \r", [stroke description]];
	}
    
	return desc;
}

@end
