#import "AppController.h"

@interface AppController ()

@property BOOL awakedFromNib;

@end

@implementation AppController

- (void)awakeFromNib {
	if (!_awakedFromNib) {
		_awakedFromNib = YES;

		int instancesOfCurrentApplication = 0;
		for (NSRunningApplication *application in[[NSWorkspace sharedWorkspace] runningApplications]) {
			if ([application.bundleIdentifier isEqualToString:[[NSBundle mainBundle] bundleIdentifier]]) {
				if (++instancesOfCurrentApplication > 1) {
					[NSApp terminate:self];
				}
			}
		}

		_gestureSetupController.appController = self;
		_gestureRecognitionController.appController = self;

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeAndQuit:) name:NSApplicationWillTerminateNotification object:NSApp];
	}
}

- (IBAction)closeAndQuit:(id)sender {
	[[MultitouchManager sharedMultitouchManager] stopForwardingMultitouchEventsToListeners];

	[NSApp terminate:self];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
	[_gestureRecognitionController applicationDidFinishLaunching];
	[_gestureSetupController applicationDidFinishLaunching];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag {
	[_gestureSetupController toggleSetupWindow:nil];
	return NO;
}

@end
