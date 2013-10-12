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
- (void)removeGestureWithIdentity:(NSString *)identity;
- (void)addGesture:(Gesture *)gesture;

@end
