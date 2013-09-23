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
- (void)removeGestureWithName:(NSString *)name;
- (void)addGesture:(Gesture *)gesture;

@end
