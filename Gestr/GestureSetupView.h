#import <Cocoa/Cocoa.h>
#import "GestureSetupController.h"
#import "Gesture.h"
#import "MultitouchManager.h"

@class GestureSetupController;

@interface GestureSetupView : NSView {
	NSMutableDictionary *touchPaths;
	NSMutableDictionary *gestureStrokes;
	NSMutableArray *orderedStrokeIds;
    
	NSTimer *shouldDetectTimer;
	NSTimer *noInputTimer;
    
	GestureSetupController *setupController;
    
	int mouseStrokeIndex;
    
	BOOL showingStoredGesture;
    
	NSDate *lastMultitouchRedraw;
	NSNumber *initialMultitouchDeviceId;
    
	BOOL detectingInput;
}
@property (retain) GestureSetupController *setupController;
@property BOOL detectingInput;

- (id)initWithFrame:(NSRect)frame;
- (void)dealWithMouseEvent:(NSEvent *)event ofType:(NSString *)mouseType;
- (void)dealWithMultitouchEvent:(MultitouchEvent *)event;
- (void)startDealingWithMultitouchEvents;
- (void)showGesture:(Gesture *)gesture;
- (void)startDetectingGesture;
- (void)checkNoInput;
- (void)finishDetectingGesture;
- (void)finishDetectingGesture:(BOOL)ignore;
- (BOOL)resignFirstResponder;
- (void)resetAll;
- (BOOL)acceptsFirstResponder;
- (BOOL)canBecomeKeyView;
- (void)drawRect:(NSRect)dirtyRect;

@end
