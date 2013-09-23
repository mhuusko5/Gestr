#import <Cocoa/Cocoa.h>
#import "GestureSetupController.h"
#import "GestureRecognitionController.h"

@class GestureSetupController, GestureRecognitionController;

@interface AppController : NSObject <NSApplicationDelegate> {
	IBOutlet GestureSetupController *gestureSetupController;
	IBOutlet GestureRecognitionController *gestureRecognitionController;
}
@property (retain) GestureSetupController *gestureSetupController;
@property (retain) GestureRecognitionController *gestureRecognitionController;

- (void)awakeFromNib;
- (IBAction)closeAndQuit:(id)outlet;
- (void)applicationDidResignActive:(NSNotification *)notification;
- (void)applicationDidBecomeActive:(NSNotification *)notification;

@end
