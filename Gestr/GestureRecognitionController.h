#import <ApplicationServices/ApplicationServices.h>
#import <Foundation/Foundation.h>
#import <Carbon/Carbon.h>
#import "GestureRecognitionModel.h"
#import "AppController.h"
#import "GestureRecognitionWindow.h"
#import "GestureRecognitionView.h"
#import "GestureRecognizer.h"
#import "Launchable.h"
#import "MultitouchManager.h"
#import "RepeatedImageView.h"

@class GestureRecognitionView, GestureRecognizer, AppController, RepeatedImageView;

@interface GestureRecognitionController : NSObject {
	BOOL awakedFromNib;
    
	GestureRecognitionModel *recognitionModel;
    
	AppController *appController;
    
	IBOutlet GestureRecognitionWindow *recognitionWindow;
	IBOutlet GestureRecognitionView *recognitionView;
    
	IBOutlet RepeatedImageView *recognitionBackground;
    
	IBOutlet NSImageView *appIconAlert;
	IBOutlet NSTextField *appDescriptionAlert;
    
	IBOutlet NSImageView *partialIconAlert;
	IBOutlet NSTextField *partialDescriptionAlert;
    
	NSDate *recentRightClickDate;
	NSMutableArray *recentFourFingerTouches;
}
@property (retain) GestureRecognitionModel *recognitionModel;
@property (retain) AppController *appController;
@property (retain) GestureRecognitionWindow *recognitionWindow;
@property (retain) GestureRecognitionView *recognitionView;

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
