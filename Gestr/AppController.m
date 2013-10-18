#import "AppController.h"

@implementation AppController

@synthesize gestureSetupController, gestureRecognitionController;

- (void)awakeFromNib {
	if (!awakedFromNib) {
		awakedFromNib = YES;
        
		gestureSetupController.appController = self;
		gestureRecognitionController.appController = self;
        
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeAndQuit:) name:NSApplicationWillTerminateNotification object:NSApp];
	}
}

- (IBAction)closeAndQuit:(id)sender {
	[[MultitouchManager sharedMultitouchManager] stopForwardingMultitouchEventsToListeners];
    
	[NSApp terminate:self];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
	[gestureRecognitionController applicationDidFinishLaunching];
	[gestureSetupController applicationDidFinishLaunching];
}

@end
