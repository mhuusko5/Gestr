#import <Cocoa/Cocoa.h>
#import "GestureSetupController.h"
#import "Gesture.h"
#import "MultitouchManager.h"
@class GestureSetupController;

@interface GestureSetupView : NSView

@property GestureSetupController *setupController;
@property BOOL detectingInput;

- (id)initWithFrame:(NSRect)frame;

- (void)dealWithMouseEvent:(NSEvent *)event ofType:(NSString *)mouseType;
- (void)dealWithMultitouchEvent:(MultitouchEvent *)event;

- (void)startMultitouchInput;
- (void)startDetectingGesture;

- (void)finishDetectingGesture;
- (void)finishDetectingGestureIgnore;
- (void)finishDetectingGesture:(BOOL)ignore;

- (void)showGesture:(Gesture *)gesture;

- (BOOL)resignFirstResponder;

- (void)resetInputTimers;
- (void)resetAll;
- (BOOL)acceptsFirstResponder;
- (BOOL)canBecomeKeyView;
- (void)drawRect:(NSRect)dirtyRect;

@end
