#import "AppController.h"

@implementation AppController

@synthesize gestureSetupController, gestureRecognitionController;

- (void)awakeFromNib {
	if (!awakedFromNib) {
		awakedFromNib = YES;
        
		gestureSetupController.appController = self;
		gestureRecognitionController.appController = self;
        
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeAndQuit:) name:NSApplicationWillTerminateNotification object:[NSApplication sharedApplication]];
	}
}

- (IBAction)closeAndQuit:(id)sender {
	[[MultitouchManager sharedMultitouchManager] stopForwardingMultitouchEventsToListeners];
    
	if (gestureSetupController.setupWindow.alphaValue > 0) {
		[gestureSetupController toggleSetupWindow:nil];
	}
    
	[NSApp terminate:self];
}

- (void)applicationDidResignActive:(NSNotification *)aNotification {
	if (gestureRecognitionController.recognitionWindow.alphaValue > 0 && gestureRecognitionController.recognitionView.detectingInput) {
		[gestureRecognitionController.recognitionView finishDetectingGesture:YES];
	}
    
	if (gestureSetupController.setupWindow.alphaValue > 0) {
		if (gestureSetupController.setupView.detectingInput) {
			[gestureSetupController.setupView finishDetectingGesture:YES];
		}
        
		[gestureSetupController toggleSetupWindow:nil];
	}
    
	[gestureSetupController updateSetupControls];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
	[gestureSetupController updateSetupControls];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
	[gestureRecognitionController applicationDidFinishLaunching];
	[gestureSetupController applicationDidFinishLaunching];
}

@end
