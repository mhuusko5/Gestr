#import "GestureRecognizer.h"

@implementation GestureRecognizer

@synthesize loadedGestures;

- (id)init {
	self = [super init];
    
	loadedGestures = [NSMutableArray array];
    
	return self;
}

- (GestureResult *)recognizeGestureWithStrokes:(NSMutableArray *)strokes {
	@try {
		GestureStroke *currentPoints = [[GestureStroke alloc] init];
		for (GestureStroke *stroke in strokes) {
			for (GesturePoint *point in stroke.points) {
				[currentPoints addPoint:point];
			}
		}
        
		GestureResult *result = [[GestureResult alloc] init];
        
		if ([currentPoints pointCount] > GUMinimumPointCount) {
			GestureTemplate *inputTemplate = [[GestureTemplate alloc] initWithPoints:currentPoints];
            
			float lowestDistance = FLT_MAX;
			for (int i = 0; i < [loadedGestures count]; i++) {
				Gesture *gestureToMatch = [loadedGestures objectAtIndex:i];
                
				if (gestureToMatch.strokes.count == strokes.count) {
					NSMutableArray *loadedGestureTemplates = [gestureToMatch templates];
                    
					for (GestureTemplate *templateToMatch in loadedGestureTemplates) {
						if (GUAngleBetweenUnitVectors(inputTemplate.startUnitVector, templateToMatch.startUnitVector) <= GUDegreesToRadians(GUStartAngleLeniency)) {
							float distance = GUDistanceAtBestAngle(inputTemplate.stroke, templateToMatch.stroke);
							if (distance < lowestDistance) {
								lowestDistance = distance;
                                
								result.gestureId = gestureToMatch.identifier;
								result.score = (int)ceilf(100.0 * (1.0 - (lowestDistance / (0.5 * sqrt(2 * pow(GUBoundingBoxSize, 2))))));
							}
						}
					}
				}
			}
		}
        
		if ([result.gestureId length] > 0 && result.score > 0) {
			return result;
		}
	}
	@catch (NSException *exception)
	{
		return nil;
	}
    
	return nil;
}

- (void)removeGestureWithId:(NSString *)_id {
	for (int i = 0; i < [loadedGestures count]; i++) {
		if ([[[loadedGestures objectAtIndex:i] identifier] isEqualToString:_id]) {
			[loadedGestures removeObjectAtIndex:i];
			return;
		}
	}
}

- (void)addGesture:(Gesture *)gesture {
	[self removeGestureWithId:gesture.identifier];
    
	[gesture generateTemplates];
    
	[loadedGestures addObject:gesture];
}

@end
