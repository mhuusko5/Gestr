#import <Cocoa/Cocoa.h>
#import "GestureSetupController.h"
#import "Gesture.h"

@class GestureSetupController;

@interface GestureSetupView : NSView {
	NSBezierPath *drawPath;
	NSMutableDictionary *touchPaths;
	NSTimer *shouldDetectTimer;
	NSMutableDictionary *gestureStrokes;
	NSMutableArray *orderedStrokeIds;
    
	GestureSetupController *setupController;
    
	int detectedStrokeIndex;
    
	BOOL showingStoredGesture;
    
    BOOL detectingInput;
    
     NSTimer *noInputTimer;
}
@property (retain) GestureSetupController *setupController;
@property BOOL detectingInput;

- (id)initWithFrame:(NSRect)frame;
- (void)dealWithMouseEvent:(NSEvent *)event ofType:(NSString *)mouseType;
- (void)showGesture:(Gesture *)gesture;
- (void)startDetectingGesture;
- (void)checkNoInput;
- (void)finishDetectingGesture;
- (void)finishDetectingGesture:(BOOL)ignore;
- (void)resetAll;
- (BOOL)acceptsFirstResponder;
- (BOOL)canBecomeKeyView;
- (void)clearCanvas;
- (void)drawRect:(NSRect)dirtyRect;

@end
