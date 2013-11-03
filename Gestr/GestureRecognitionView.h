#import "GestureRecognitionController.h"
#import "MultitouchEvent.h"

@class GestureRecognitionController;

@interface GestureRecognitionView : NSView {
	NSMutableDictionary *touchPaths;
	NSMutableDictionary *gestureStrokes;
	NSMutableArray *orderedStrokeIds;
    
    NSTimer *startInputTimer;
    NSTimer *noInputTimer;
	NSTimer *detectInputTimer;
	NSTimer *checkPartialGestureTimer;
    
	GestureRecognitionController *recognitionController;
    
	int mouseStrokeIndex;
    
	NSDate *lastMultitouchRedraw;
	NSNumber *initialMultitouchDeviceId;
    
	BOOL detectingInput;
}
@property (retain) GestureRecognitionController *recognitionController;
@property BOOL detectingInput;

- (id)initWithFrame:(NSRect)frame;

- (void)dealWithMouseEvent:(NSEvent *)event ofType:(NSString *)mouseType;
- (void)dealWithMultitouchEvent:(MultitouchEvent *)event;

- (void)startMultitouchInput;
- (void)startDetectingGesture;

- (void)finishDetectingGesture;
- (void)finishDetectingGestureIgnore;
- (void)finishDetectingGesture:(BOOL)ignore;

- (void)checkPartialGesture;
- (void)checkPartialGestureOnNewThread;

- (void)resetInputTimers;
- (void)resetAll;
- (BOOL)acceptsFirstResponder;
- (BOOL)canBecomeKeyView;
- (void)drawRect:(NSRect)dirtyRect;

@end
