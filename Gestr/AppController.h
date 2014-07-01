#import "GestureSetupController.h"
#import "GestureRecognitionController.h"
#import "MultitouchManager.h"
#import "PFMoveApplication.h"
@class GestureSetupController, GestureRecognitionController;

@interface AppController : NSObject <NSApplicationDelegate>

@property GestureSetupController *gestureSetupController;
@property GestureRecognitionController *gestureRecognitionController;

- (void)awakeFromNib;
- (IBAction)closeAndQuit:(id)sender;
- (void)applicationWillFinishLaunching:(NSNotification *)notification;
- (void)applicationDidFinishLaunching:(NSNotification *)notification;
- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag;

@end
