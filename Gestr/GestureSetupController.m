#import "GestureSetupController.h"

@implementation GestureSetupController

@synthesize appController, setupModel, setupWindow, setupView;

#pragma mark -
#pragma mark Initialization
- (void)awakeFromNib {
	if (!awakedFromNib) {
		awakedFromNib = YES;
        
		setupView.setupController = self;
        
		[self hideSetupWindow];
        
		setupModel = [[GestureSetupModel alloc] init];
        
		statusBarItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
		statusBarItem.title = @"";
		statusBarView.alphaValue = 0.0;
		statusBarItem.view = statusBarView;
	}
}

- (void)applicationDidFinishLaunching {
	[[statusBarView animator] setAlphaValue:1.0];
    
	[launchableTypePicker setSelectedSegment:0];
	launchableArrayController.content = setupModel.normalAppArray;
    
	if (appController.gestureRecognitionController.recognitionModel.gestureDetector.loadedGestures.count < 1) {
		[self toggleSetupWindow:nil];
	}
    
	[self updateSetupControls];
}

#pragma mark -

#pragma mark -
#pragma mark Tableview Management
- (NSMutableArray *)currentLaunchableArray {
	return (NSMutableArray *)launchableArrayController.content;
}

- (NSTableView *)currentLaunchableTableView {
	return launchableTableView;
}

- (IBAction)launchableTypeChanged:(id)sender {
	switch (launchableTypePicker.selectedSegment) {
		case 0:
			[setupModel fetchNormalAppArray];
			launchableArrayController.content = setupModel.normalAppArray;
			break;
            
		case 1:
			[setupModel fetchWebPageArray];
			launchableArrayController.content = setupModel.webPageArray;
			break;
            
		case 2:
            [setupModel fetchUtilitiesAppArray];
			launchableArrayController.content = setupModel.utilitiesAppArray;
			break;
            
        case 3:
			[setupModel fetchSystemAppArray];
			launchableArrayController.content = setupModel.systemAppArray;
			break;
            
		default:
			break;
	}
    
	[showGestureButton setEnabled:NO];
	[assignGestureButton setEnabled:NO];
	[clearGestureButton setEnabled:NO];
}

- (void)tableViewFocus:(BOOL)lost {
	if (lost) {
		[showGestureButton setEnabled:NO];
		[assignGestureButton setEnabled:NO];
		[clearGestureButton setEnabled:NO];
	}
	else {
		[self updateSetupControls];
	}
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
	[setupView finishDetectingGesture:YES];
    
	[self updateSetupControls];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
	return [self currentLaunchableArray].count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	NSTableCellView *result = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
	Launchable *launchable = [[self currentLaunchableArray] objectAtIndex:row];
	result.imageView.image = launchable.icon;
	result.textField.stringValue = launchable.displayName;
    
	return result;
}

#pragma mark -

#pragma mark -
#pragma mark Interface Control
- (void)updateSetupControls {
	[setupView resetAll];
    
	[setupWindow makeFirstResponder:[self currentLaunchableTableView]];
    
	launchableSelectedIndex = (int)([[self currentLaunchableTableView] selectedRow]);
    
	if (launchableSelectedIndex >= 0) {
		BOOL gestureExistsForSelectedApp = NO;
        
		gestureExistsForSelectedApp = ([appController.gestureRecognitionController.recognitionModel getGestureWithIdentity:((Launchable *)[[self currentLaunchableArray] objectAtIndex:launchableSelectedIndex]).launchId] != nil);
        
		if ([[NSApplication sharedApplication] isActive]) {
			if (gestureExistsForSelectedApp) {
				[showGestureButton setEnabled:YES];
				[assignGestureButton setEnabled:YES];
				[clearGestureButton setEnabled:YES];
			}
			else {
				[showGestureButton setEnabled:NO];
				[assignGestureButton setEnabled:YES];
				[clearGestureButton setEnabled:NO];
			}
		}
		else {
			[showGestureButton setEnabled:NO];
			[assignGestureButton setEnabled:NO];
			[clearGestureButton setEnabled:NO];
		}
	}
    
	if (![MultitouchManager systemIsMultitouchCapable]) {
		multitouchOptionField.alphaValue = 0.5;
		[multitouchOptionField setEnabled:NO];
		multitouchRecognitionLabel.alphaValue = 0.5;
        
		if (setupModel.multitouchOption) {
			[setupModel saveMultitouchOption:NO];
		}
	}
	else {
		multitouchOptionField.alphaValue = 1.0;
		[multitouchOptionField setEnabled:YES];
		multitouchRecognitionLabel.alphaValue = 1.0;
	}
    
	minimumRecognitionScoreField.stringValue = [NSString stringWithFormat:@"%i", setupModel.minimumRecognitionScore];
	readingDelayTimeField.stringValue = [NSString stringWithFormat:@"%i", setupModel.readingDelayTime];
	multitouchOptionField.state = setupModel.multitouchOption;
	fullscreenOptionField.state = setupModel.fullscreenOption;
	hiddenIconOptionField.state = setupModel.hiddenIconOption;
	loginStartOptionField.state = setupModel.loginStartOption;
}

- (void)showDrawNotification:(BOOL)show {
	if (setupModel.multitouchOption) {
		drawNotificationText.stringValue = @"Draw now!";
	}
	else {
		drawNotificationText.stringValue = @"Draw here!";
	}
    
	if (show) {
		drawNotificationText.alphaValue = 1.0;
	}
	else {
		drawNotificationText.alphaValue = 0.0;
	}
}

#pragma mark -

#pragma mark -
#pragma mark Setup Utilities
- (void)saveGestureWithStrokes:(NSMutableArray *)gestureStrokes {
	int inputPointCount = 0;
	for (GestureStroke *stroke in gestureStrokes) {
		inputPointCount += [stroke pointCount];
	}
	if (inputPointCount < GUMinimumPointCount) {
		NSAlert *infoAlert = [[NSAlert alloc] init];
		[infoAlert addButtonWithTitle:@"Ok, then"];
		[infoAlert setMessageText:@"Please make your gesture strokes a tad longer..."];
		[infoAlert setAlertStyle:NSInformationalAlertStyle];
		[infoAlert beginSheetModalForWindow:setupWindow modalDelegate:self didEndSelector:nil contextInfo:nil];
		return;
	}
    
	Launchable *gestureToSaveLaunchable = [[self currentLaunchableArray] objectAtIndex:launchableSelectedIndex];
    
	[appController.gestureRecognitionController.recognitionModel saveGestureWithStrokes:gestureStrokes andIdentity:gestureToSaveLaunchable.launchId];
    
	[self updateSetupControls];
}

#pragma mark -

#pragma mark -
#pragma mark Setup Actions
- (IBAction)assignSelectedGesture:(id)sender {
	[setupView startDetectingGesture];
}

- (IBAction)showSelectedGesture:(id)sender {
	if (showGestureThread) {
		[showGestureThread cancel];
		showGestureThread = nil;
	}
    
	if (launchableSelectedIndex >= 0) {
		@try {
			Gesture *gestureToShow = [appController.gestureRecognitionController.recognitionModel getGestureWithIdentity:((Launchable *)[[self currentLaunchableArray] objectAtIndex:launchableSelectedIndex]).launchId];
			showGestureThread = [[NSThread alloc] initWithTarget:setupView selector:@selector(showGesture:) object:gestureToShow];
			[showGestureThread start];
		}
		@catch (NSException *exception)
		{
		}
	}
}

- (IBAction)clearSelectedGesture:(id)sender {
	if (launchableSelectedIndex >= 0) {
		[appController.gestureRecognitionController.recognitionModel deleteGestureWithName:((Launchable *)[[self currentLaunchableArray] objectAtIndex:launchableSelectedIndex]).launchId];
	}
    
	[self updateSetupControls];
}

#pragma mark -

#pragma mark -
#pragma mark Window Methods
- (void)showUpdateAlert:(NSString *)version {
	if (setupWindow.alphaValue <= 0) {
		[self toggleSetupWindow:nil];
	}
    
	NSAlert *infoAlert = [[NSAlert alloc] init];
	[infoAlert addButtonWithTitle:@"Will do!"];
	[infoAlert setMessageText:[NSString stringWithFormat:@"Head over to mhuusko5.com for version %@ of Gestr!", version]];
	[infoAlert setAlertStyle:NSInformationalAlertStyle];
	[infoAlert beginSheetModalForWindow:setupWindow modalDelegate:self didEndSelector:nil contextInfo:nil];
}

- (IBAction)toggleSetupWindow:(id)sender {
	NSRect menuBarFrame = [[[statusBarItem view] window] frame];
	NSPoint pt = NSMakePoint(NSMidX(menuBarFrame), NSMidY(menuBarFrame));
    
	pt.y -= menuBarFrame.size.height / 2;
	pt.x -= (setupWindow.frame.size.width) / 2;
    
	NSRect frame = [setupWindow frame];
	if ([setupWindow alphaValue] <= 0) {
		frame.origin.y = pt.y;
		frame.origin.x = pt.x;
		[setupWindow setFrame:frame display:YES];
        
		frame.origin.y -= frame.size.height;
		setupWindow.alphaValue = 1.0;
		[setupWindow makeKeyAndOrderFront:self];
		[setupWindow setFrame:frame display:YES animate:YES];
        
		[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
	}
	else {
		if ([[NSApplication sharedApplication] isHidden]) {
			[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
		}
		else {
			frame.origin.x = pt.x;
			frame.origin.y = pt.y;
			[setupWindow setFrame:frame display:YES animate:YES];
            
			[self hideSetupWindow];
            
			[[NSApplication sharedApplication] hide:self];
		}
	}
    
	[self updateSetupControls];
}

- (void)hideSetupWindow {
	setupWindow.alphaValue = 0.0;
	[setupWindow orderOut:self];
	[setupWindow setFrameOrigin:NSMakePoint(-10000, -10000)];
}

#pragma mark -

#pragma mark -
#pragma mark Recognition Options
- (IBAction)minimumRecognitionScoreChanged:(id)sender {
	[setupView finishDetectingGesture:YES];
    
	int newScore = [minimumRecognitionScoreField intValue];
	if (newScore >= 70 && newScore <= 100) {
		[setupModel saveMinimumRecognitionScore:newScore];
	}
	else {
		NSAlert *infoAlert = [[NSAlert alloc] init];
		[infoAlert addButtonWithTitle:@"Sure"];
		[infoAlert setMessageText:@"It's better to set a score between 70 and 100..."];
		[infoAlert setAlertStyle:NSInformationalAlertStyle];
		[infoAlert beginSheetModalForWindow:setupWindow modalDelegate:self didEndSelector:nil contextInfo:nil];
	}
    
	[self updateSetupControls];
}

- (IBAction)readingDelayTimeChanged:(id)sender {
	[setupView finishDetectingGesture:YES];
    
	int newTime = [readingDelayTimeField intValue];
	if (newTime >= 1 && newTime <= 1000) {
		[setupModel saveReadingDelayTime:newTime];
	}
	else {
		NSAlert *infoAlert = [[NSAlert alloc] init];
		[infoAlert addButtonWithTitle:@"Okay"];
		[infoAlert setMessageText:@"Somewhere between 1 and 1000 milliseconds is more reasonable..."];
		[infoAlert setAlertStyle:NSInformationalAlertStyle];
		[infoAlert beginSheetModalForWindow:setupWindow modalDelegate:self didEndSelector:nil contextInfo:nil];
	}
    
	[self updateSetupControls];
}

- (IBAction)multitouchOptionChanged:(id)sender {
	[setupView finishDetectingGesture:YES];
    
	[setupModel saveMultitouchOption:multitouchOptionField.state];
    
	[self updateSetupControls];
}

- (IBAction)fullscreenOptionChanged:(id)sender {
	[setupView finishDetectingGesture:YES];
    
	[setupModel saveFullscreenOption:fullscreenOptionField.state];
    
	[self updateSetupControls];
}

- (IBAction)hiddenIconOptionChanged:(id)sender {
	[setupView finishDetectingGesture:YES];
    
	[setupModel saveHiddenIconOption:hiddenIconOptionField.state];
    
	[self updateSetupControls];
}

- (IBAction)loginStartOptionChanged:(id)sender {
	[setupView finishDetectingGesture:YES];
    
	[setupModel saveLoginStartOption:loginStartOptionField.state];
    
	loginStartOptionField.state = [setupModel fetchLoginStartOption];
    
	[self updateSetupControls];
}

#pragma mark -

@end
