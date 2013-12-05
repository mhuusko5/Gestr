#import "AppController.h"

@interface AppController ()

@property BOOL awakedFromNib;

@end

@implementation AppController

- (void)awakeFromNib {
	if (!self.awakedFromNib) {
		self.awakedFromNib = YES;
        
        int instancesOfCurrentApplication = 0;
        for (NSRunningApplication *application in [[NSWorkspace sharedWorkspace] runningApplications]) {
            if ([application.bundleIdentifier isEqualToString:[[NSBundle mainBundle] bundleIdentifier]]) {
                if (++instancesOfCurrentApplication > 1) {
                    [NSApp terminate:self];
                }
            }
        }
        
		self.gestureSetupController.appController = self;
		self.gestureRecognitionController.appController = self;
        
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeAndQuit:) name:NSApplicationWillTerminateNotification object:NSApp];
	}
}

- (IBAction)closeAndQuit:(id)sender {
	[[MultitouchManager sharedMultitouchManager] stopForwardingMultitouchEventsToListeners];
    
	[NSApp terminate:self];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
	[self.gestureRecognitionController applicationDidFinishLaunching];
	[self.gestureSetupController applicationDidFinishLaunching];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag {
    [self.gestureSetupController toggleSetupWindow:nil];
    return NO;
}

@end
