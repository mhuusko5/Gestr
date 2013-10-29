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
- (void)applicationDidFinishLaunching:(NSNotification *)notification;
- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag;

@end
