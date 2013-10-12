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
        
        successfulRecognitionScoreTextField.stringValue = [NSString stringWithFormat:@"%i", setupModel.successfulRecognitionScore];
        readingDelayTextField.stringValue = [NSString stringWithFormat:@"%i", setupModel.readingDelayNumber];
        multitouchCheckbox.state = setupModel.multitouchRecognition;
        fullscreenCheckbox.state = setupModel.fullscreenRecognition;
        hideDockIconCheckbox.state = setupModel.hideDockIcon;
        startAtLaunchCheckbox.state = setupModel.startAtLaunch;
        
        statusBarItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
        statusBarItem.title = @"";
        statusBarView.alphaValue = 0.0;
        statusBarItem.view = statusBarView;
	}
}

- (void)applicationDidFinishLaunching {
    [[statusBarView animator] setAlphaValue:1.0];
    
	if (appController.gestureRecognitionController.recognitionModel.gestureDetector.loadedGestures.count < 1) {
		[self toggleSetupWindow:nil];
	}
    
	[self updateSetupControls];
    
    [launchableTypePicker setSelectedSegment:0];
    launchableArrayController.content = setupModel.normalAppArray;
}

#pragma mark -

#pragma mark -
#pragma mark Launchable Management
- (Launchable *)launchableWithId:(NSString *)identity {
	for (Launchable *launch in setupModel.normalAppArray) {
		if ([launch.launchId isEqualTo:identity]) {
			return launch;
		}
	}
    
	for (Launchable *launch in setupModel.utilitiesAppArray) {
		if ([launch.launchId isEqualTo:identity]) {
			return launch;
		}
	}
    
	for (Launchable *launch in setupModel.systemAppArray) {
		if ([launch.launchId isEqualTo:identity]) {
			return launch;
		}
	}
    
	return nil;
}

- (NSMutableArray *)currentLaunchableArray {
	return (NSMutableArray *)launchableArrayController.content;
}

- (NSTableView *)currentLaunchableTableView {
	return launchableTableView;
}

- (IBAction)launchableTypeChanged:(id)sender {
	switch (launchableTypePicker.selectedSegment) {
		case 0:
            launchableArrayController.content = setupModel.normalAppArray;
			break;
            
		case 1:
            launchableArrayController.content = setupModel.utilitiesAppArray;
			break;
            
		case 2:
			launchableArrayController.content = setupModel.systemAppArray;
			break;
            
		default:
			break;
	}
    
	[showGestureButton setEnabled:NO];
	[assignGestureButton setEnabled:NO];
	[deleteGestureButton setEnabled:NO];
}
#pragma mark -

#pragma mark -
#pragma mark Tableview Control
- (void)tableViewFocus:(BOOL)lost {
	if (lost) {
		[showGestureButton setEnabled:NO];
		[assignGestureButton setEnabled:NO];
		[deleteGestureButton setEnabled:NO];
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
	Launchable *app = [[self currentLaunchableArray] objectAtIndex:row];
	result.imageView.image = app.icon;
	result.textField.stringValue = app.displayName;
    
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
				[deleteGestureButton setEnabled:YES];
			}
			else {
				[showGestureButton setEnabled:NO];
				[assignGestureButton setEnabled:YES];
				[deleteGestureButton setEnabled:NO];
			}
		}
		else {
			[showGestureButton setEnabled:NO];
			[assignGestureButton setEnabled:NO];
			[deleteGestureButton setEnabled:NO];
		}
	}
    
	if (![MultitouchManager systemIsMultitouchCapable]) {
        multitouchCheckbox.alphaValue = 0.5;
		[multitouchCheckbox setEnabled:NO];
		multitouchRecognitionLabel.alphaValue = 0.5;
        
		[multitouchCheckbox setState:NO];
		[self multitouchRecognitionSelected:nil];
	}
	else {
		multitouchCheckbox.alphaValue = 1.0;
		[multitouchCheckbox setEnabled:YES];
		multitouchRecognitionLabel.alphaValue = 1.0;
	}
}

- (void)showDrawNowText:(BOOL)show {
	if (show) {
		drawNowText.alphaValue = 1.0;
	}
	else {
		drawNowText.alphaValue = 0.0;
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
    
	Launchable *gestureToSaveApp = [[self currentLaunchableArray] objectAtIndex:launchableSelectedIndex];
    
	[appController.gestureRecognitionController.recognitionModel saveGestureWithStrokes:gestureStrokes andIdentity:gestureToSaveApp.launchId];
    
	[self updateSetupControls];
}

#pragma mark -

#pragma mark -
#pragma mark Setup Actions
- (IBAction)assignSelectedGesture:(id)sender {
	[setupWindow makeFirstResponder:setupView];
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
- (IBAction)successfulRecognitionScoreSelected:(id)sender {
	int newScore = [successfulRecognitionScoreTextField intValue];
	if (newScore >= 70 && newScore <= 100) {
		[setupModel saveSuccessfulRecognitionScore:newScore];
	}
	else {
		NSAlert *infoAlert = [[NSAlert alloc] init];
		[infoAlert addButtonWithTitle:@"Sure"];
		[infoAlert setMessageText:@"It's better to set a score between 70 and 100..."];
		[infoAlert setAlertStyle:NSInformationalAlertStyle];
		[infoAlert beginSheetModalForWindow:setupWindow modalDelegate:self didEndSelector:nil contextInfo:nil];
	}
}

- (IBAction)readingDelayNumberSelected:(id)sender {
	int newNum = [readingDelayTextField intValue];
	if (newNum >= 1 && newNum <= 1000) {
		[setupModel saveReadingDelayNumber:newNum];
	}
	else {
		NSAlert *infoAlert = [[NSAlert alloc] init];
		[infoAlert addButtonWithTitle:@"Okay"];
		[infoAlert setMessageText:@"Somewhere between 1 and 1000 milliseconds is more reasonable..."];
		[infoAlert setAlertStyle:NSInformationalAlertStyle];
		[infoAlert beginSheetModalForWindow:setupWindow modalDelegate:self didEndSelector:nil contextInfo:nil];
	}
}

- (IBAction)multitouchRecognitionSelected:(id)sender {
	[setupModel saveMultitouchRecognition:multitouchCheckbox.state];
}

- (IBAction)fullscreenRecognitionSelected:(id)sender {
	[setupModel saveFullscreenRecognition:fullscreenCheckbox.state];
}

- (IBAction)hideDockIconSelected:(id)sender {
	[setupModel saveHideDockIcon:hideDockIconCheckbox.state];
}

- (IBAction)startAtLaunchSelected:(id)sender {
	[setupModel saveStartAtLaunch:startAtLaunchCheckbox.state];
    
    startAtLaunchCheckbox.state = [setupModel fetchStartAtLaunch];
}

#pragma mark -

@end
