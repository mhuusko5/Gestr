#import <Cocoa/Cocoa.h>
#import "GestureSetupController.h"
#import "GestureRecognitionController.h"
#import "MultitouchManager.h"

@class GestureSetupController, GestureRecognitionController;

@interface AppController : NSObject <NSApplicationDelegate> {
	BOOL awakedFromNib;
    
	IBOutlet GestureSetupController *gestureSetupController;
	IBOutlet GestureRecognitionController *gestureRecognitionController;
}
@property (retain) GestureSetupController *gestureSetupController;
@property (retain) GestureRecognitionController *gestureRecognitionController;

- (void)awakeFromNib;
- (IBAction)closeAndQuit:(id)sender;
- (void)applicationDidResignActive:(NSNotification *)aNotification;
- (void)applicationDidBecomeActive:(NSNotification *)notification;
- (void)applicationDidFinishLaunching:(NSNotification *)notification;
- (void)checkForApplicationUpdate;

@end
