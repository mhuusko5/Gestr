#import "GestureRecognitionModel.h"
#import "AppController.h"
#import "GestureRecognitionWindow.h"
#import "GestureRecognitionView.h"
#import "GestureRecognizer.h"
#import "Launchable.h"
#import "MultitouchManager.h"
#import "RepeatedImageView.h"
@class GestureRecognitionView, GestureRecognizer, AppController, RepeatedImageView;

@interface GestureRecognitionController : NSObject

@property GestureRecognitionModel *recognitionModel;
@property AppController *appController;
@property IBOutlet GestureRecognitionWindow *recognitionWindow;
@property IBOutlet GestureRecognitionView *recognitionView;

#pragma mark -
#pragma mark Initialization
- (void)awakeFromNib;
- (void)applicationDidFinishLaunching;
#pragma mark -

#pragma mark -
#pragma mark Recognition Utilities
- (void)checkPartialGestureWithStrokes:(NSMutableArray *)strokes;
- (void)recognizeGestureWithStrokes:(NSMutableArray *)strokes;
- (void)shouldStartDetectingGesture;
#pragma mark -

#pragma mark -
#pragma mark Activation Event Handling
- (void)handleMultitouchEvent:(MultitouchEvent *)event;
- (CGEventRef)handleEvent:(CGEventRef)event withType:(int)type;
CGEventRef handleEvent(CGEventTapProxy proxy, CGEventType type, CGEventRef eventRef, void *refcon);

#pragma mark -

#pragma mark -
#pragma mark Window Methods
- (void)fadeOutRecognitionWindow;
- (void)toggleOutRecognitionWindow:(BOOL)fadeOut;
- (void)toggleInRecognitionWindow;
- (void)hideRecognitionWindow;
- (void)windowDidResignKey:(NSNotification *)notification;
- (void)layoutRecognitionWindow;
#pragma mark -

@end
