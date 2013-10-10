#import "Gesture.h"

@implementation Gesture

@synthesize identifier, strokes, templates;

- (id)initWithId:(NSString *)_id andStrokes:(NSMutableArray *)_strokes {
	self = [super init];
    
	identifier = _id;
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
	for (int i = 0; i < [strokes count]; i++) {
		[order insertObject:[NSNumber numberWithInt:i] atIndex:i];
	}
    
	NSMutableArray *unistrokes = GUMakeUnistrokes(strokes, GUHeapPermute((int)[strokes count], order, [NSMutableArray array]));
    
	for (int j = 0; j < [unistrokes count]; j++) {
		[templates addObject:[[GestureTemplate alloc] initWithPoints:[unistrokes objectAtIndex:j]]];
	}
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:strokes forKey:@"strokes"];
	[coder encodeObject:identifier forKey:@"identifier"];
}

- (id)initWithCoder:(NSCoder *)coder {
	self = [super init];
    
	strokes = [coder decodeObjectForKey:@"strokes"];
	identifier = [coder decodeObjectForKey:@"identifier"];
    
	return self;
}

- (id)copyWithZone:(NSZone *)zone {
	Gesture *copy = [[Gesture allocWithZone:zone] initWithId:[identifier copy] andStrokes:[strokes copy]];
    
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
