#import <Cocoa/Cocoa.h>
#import "GestureRecognitionController.h"
#import "MultitouchEvent.h"

@class GestureRecognitionController;

@interface GestureRecognitionView : NSView {
	NSMutableDictionary *touchPaths;
	NSMutableDictionary *gestureStrokes;
	NSMutableArray *orderedStrokeIds;
    
	NSTimer *shouldDetectTimer;
	NSTimer *checkPartialGestureTimer;
	NSTimer *noInputTimer;
    
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
- (void)startDealingWithMultitouchEvents;
- (void)startDetectingGesture;
- (void)checkNoInput;
- (void)checkPartialGestureOnNewThread;
- (void)checkPartialGesture;
- (void)finishDetectingGesture;
- (void)finishDetectingGesture:(BOOL)ignore;
- (void)resetAll;
- (BOOL)acceptsFirstResponder;
- (BOOL)canBecomeKeyView;
- (void)drawRect:(NSRect)dirtyRect;

@end
