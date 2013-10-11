#import "AppController.h"

@implementation AppController

@synthesize gestureSetupController, gestureRecognitionController;

- (void)awakeFromNib {
	[[NSApplication sharedApplication] hide:self];
    
	[gestureSetupController setAppController:self];
	[gestureRecognitionController setAppController:self];
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeAndQuit:) name:NSApplicationWillTerminateNotification object:[NSApplication sharedApplication]];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
	[gestureSetupController checkForUpdate:YES];
}

- (IBAction)closeAndQuit:(id)outlet {
	[[MultitouchManager sharedMultitouchManager] stopForwardingMultitouchEventsToListeners];
    
	if ([gestureSetupController.setupWindow alphaValue] > 0) {
		[gestureSetupController toggleGestureSetupWindow:nil];
	}
    
	[NSApp terminate:self];
}

- (void)applicationDidResignActive:(NSNotification *)aNotification {
	if ([gestureRecognitionController.recognitionWindow alphaValue] > 0 && gestureRecognitionController.recognitionView.detectingInput) {
		[gestureRecognitionController.recognitionView finishDetectingGesture:YES];
	}
    
	if ([gestureSetupController.setupWindow alphaValue] > 0) {
		if (gestureSetupController.setupView.detectingInput) {
			[gestureSetupController.setupView finishDetectingGesture:YES];
		}
        
		[gestureSetupController toggleGestureSetupWindow:nil];
	}
    
	[gestureSetupController updateSetupControls];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
	[gestureSetupController updateSetupControls];
}

@end
