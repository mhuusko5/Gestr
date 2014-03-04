#import "GestureRecognitionController.h"
#import "MultitouchEvent.h"
@class GestureRecognitionController;

@interface GestureRecognitionView : NSView

@property GestureRecognitionController *recognitionController;
@property BOOL detectingInput;

- (id)initWithFrame:(NSRect)frame;

- (void)dealWithMouseEvent:(NSEvent *)event ofType:(NSString *)mouseType;
- (void)dealWithMultitouchEvent:(MultitouchEvent *)event;

- (void)startMultitouchInput;
- (void)startDetectingGesture:(BOOL)quick;

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
