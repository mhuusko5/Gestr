#import <ApplicationServices/ApplicationServices.h>
#import <Foundation/Foundation.h>
#import <Carbon/Carbon.h>
#import "AppController.h"
#import "GestureRecognitionWindow.h"
#import "GestureRecognitionView.h"
#import "GestureRecognizer.h"
#import "App.h"
#import "MultitouchManager.h"

@class GestureRecognitionView, GestureRecognizer, AppController;

@interface GestureRecognitionController : NSObject {
	IBOutlet GestureRecognitionWindow *recognitionWindow;
	IBOutlet NSImageView *recognitionBackground;
	IBOutlet GestureRecognitionView *recognitionView;
	IBOutlet NSImageView *appIconAlert;
	IBOutlet NSTextField *appDescriptionAlert;
    
	IBOutlet NSImageView *partialIconAlert;
	IBOutlet NSTextField *partialDescriptionAlert;
    
	NSRunningApplication *currentApp;
    
	AppController *appController;
	GestureRecognizer *gestureDetector;
    
	NSMutableDictionary *updatedGestureDictionary;
    
	BOOL gesturesLoaded;
    
	NSMutableArray *fourFingerTouches;
}
@property BOOL gesturesLoaded;
@property (retain) GestureRecognitionWindow *recognitionWindow;
@property (retain) GestureRecognitionView *recognitionView;
@property (retain) AppController *appController;
@property (retain) NSMutableDictionary *updatedGestureDictionary;
@property (retain) GestureRecognizer *gestureDetector;
@property (retain) NSRunningApplication *currentApp;

- (id)init;
- (void)layoutRecognitionWindow;
- (void)awakeFromNib;
- (void)fetchUpdatedGestureDictionary;
- (void)saveUpdatedGestureDictionary;
- (void)setupActivationHanding;
- (void)handleEvent:(CGEventRef)event withType:(int)type;
CGEventRef handleAllEvents(CGEventTapProxy proxy, CGEventType type, CGEventRef eventRef, void *refcon);

- (void)handleMultitouchEvent:(MultitouchEvent *)event;
- (void)applicationBecameActive:(NSNotification *)notification;
- (void)shouldStartDetectingGesture;
- (void)launchAppWithBundleId:(NSString *)bundle;
- (void)checkPartialGestureWithStrokes:(NSMutableArray *)strokes;
- (void)recognizeGestureWithStrokes:(NSMutableArray *)strokes;
- (void)hideGestureRecognitionWindow:(BOOL)fade;
- (void)showGestureRecognitionWindow;

@end
