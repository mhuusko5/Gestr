#import <Foundation/Foundation.h>
#import "GestureUtils.h"
#import "Gesture.h"
#import "GestureTemplate.h"
#import "GestureResult.h"

@interface GestureRecognizer : NSObject {
	NSMutableArray *loadedGestures;
}
@property NSMutableArray *loadedGestures;

- (GestureResult *)recognizeGestureWithStrokes:(NSMutableArray *)strokes;
- (void)removeGestureWithId:(NSString *)_id;
- (void)addGesture:(Gesture *)gesture;

@end
