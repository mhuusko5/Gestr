#import "AppController.h"

@implementation AppController

@synthesize gestureSetupController, gestureRecognitionController;

- (void)awakeFromNib {
	if (!awakedFromNib) {
		awakedFromNib = YES;
        
        int instancesOfCurrentApplication = 0;
        for (NSRunningApplication *application in [[NSWorkspace sharedWorkspace] runningApplications]) {
            if ([application.bundleIdentifier isEqualToString:[[NSBundle mainBundle] bundleIdentifier]]) {
                if (++instancesOfCurrentApplication > 1) {
                    [NSApp terminate:self];
                }
            }
        }
        
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

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag {
    [gestureSetupController toggleSetupWindow:nil];
    return NO;
}

@end
