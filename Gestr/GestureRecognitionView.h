#import <Cocoa/Cocoa.h>
#import "GestureRecognitionController.h"

@class GestureRecognitionController;

@interface GestureRecognitionView : NSView {
	NSMutableDictionary *touchPaths;
	NSMutableDictionary *gestureStrokes;
	NSMutableArray *orderedStrokeIds;
    
	NSTimer *shouldDetectTimer;
	NSTimer *checkPartialGestureTimer;
    
	GestureRecognitionController *recognitionController;
    
	int mouseStrokeIndex;
}
@property (retain) GestureRecognitionController *recognitionController;
@property BOOL detectingInput;

- (id)initWithFrame:(NSRect)frame;
- (void)dealWithMouseEvent:(NSEvent *)event ofType:(NSString *)mouseType;
- (void)startDetectingGesture;
- (void)checkPartialGesture;
- (void)finishDetectingGesture;
- (void)finishDetectingGesture:(BOOL)ignore;
- (void)resetAll;
- (BOOL)acceptsFirstResponder;
- (BOOL)canBecomeKeyView;
- (void)drawRect:(NSRect)dirtyRect;

@end
