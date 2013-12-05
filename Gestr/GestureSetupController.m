#import "GestureSetupController.h"

@interface GestureSetupController ()

@property BOOL awakedFromNib;

@property NSStatusItem *statusBarItem;
@property IBOutlet NSView *statusBarView;

@property NSThread *showGestureThread;

@property IBOutlet NSTextField *drawNotificationText;

@property int launchableSelectedIndex;
@property IBOutlet NSSegmentedControl *launchableTypePicker;
@property IBOutlet NSTableView *launchableTableView;
@property IBOutlet NSArrayController *launchableArrayController;

@property IBOutlet NSButton *assignGestureButton, *showGestureButton, *clearGestureButton;

@property IBOutlet NSTextField *minimumRecognitionScoreField, *readingDelayTimeField;
@property IBOutlet NSTextField *multitouchRecognitionLabel;
@property IBOutlet NSButton *multitouchOptionField, *fullscreenOptionField;
@property IBOutlet NSButton *loginStartOptionField;

@end

@implementation GestureSetupController

#pragma mark -
#pragma mark Initialization
- (void)awakeFromNib {
	if (!self.awakedFromNib) {
		self.awakedFromNib = YES;
        
		self.setupView.setupController = self;
        
		[self hideSetupWindow];
        
		self.setupModel = [[GestureSetupModel alloc] init];
        [self.setupModel setup];
        
		self.statusBarItem = [NSStatusItemPrioritizer prioritizedStatusItem];
		self.statusBarItem.title = @"";
		self.statusBarView.alphaValue = 0.0;
		self.statusBarItem.view = self.statusBarView;
	}
}

- (void)applicationDidFinishLaunching {
	[[self.statusBarView animator] setAlphaValue:1.0];
    
	[self.launchableTypePicker setSelectedSegment:0];
	self.launchableArrayController.content = self.setupModel.normalAppArray;
    
	if (self.appController.gestureRecognitionController.recognitionModel.gestureDetector.loadedGestures.count < 1) {
		[self toggleSetupWindow:nil];
	}
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(repositionSetupWindow:) name:NSWindowDidMoveNotification object:self.statusBarView.window];
    
	[self updateSetupControls];
    
	[self hideSetupWindow];
}

#pragma mark -

#pragma mark -
#pragma mark Tableview Management
- (NSMutableArray *)currentLaunchableArray {
	return (NSMutableArray *)self.launchableArrayController.content;
}

- (NSTableView *)currentLaunchableTableView {
	return self.launchableTableView;
}

- (IBAction)launchableTypeChanged:(id)sender {
	switch (self.launchableTypePicker.selectedSegment) {
		case 0:
			[self.setupModel fetchNormalAppArray];
			self.launchableArrayController.content = self.setupModel.normalAppArray;
			break;
            
		case 1:
			[self.setupModel fetchWebPageArray];
			self.launchableArrayController.content = self.setupModel.webPageArray;
			break;
            
		case 2:
			[self.setupModel fetchUtilitiesAppArray];
			self.launchableArrayController.content = self.setupModel.utilitiesAppArray;
			break;
            
		case 3:
			[self.setupModel fetchSystemAppArray];
			self.launchableArrayController.content = self.setupModel.systemAppArray;
			break;
            
		default:
			break;
	}
    
	[self.showGestureButton setEnabled:NO];
	[self.assignGestureButton setEnabled:NO];
	[self.clearGestureButton setEnabled:NO];
}

- (void)tableViewFocus:(BOOL)lost {
	if (lost) {
		[self.showGestureButton setEnabled:NO];
		[self.assignGestureButton setEnabled:NO];
		[self.clearGestureButton setEnabled:NO];
	}
	else {
		[self updateSetupControls];
	}
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
	[self.setupView finishDetectingGesture:YES];
    
	[self updateSetupControls];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
	return [self currentLaunchableArray].count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	NSTableCellView *result = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
	Launchable *launchable = [self currentLaunchableArray][row];
	result.imageView.image = launchable.icon;
	result.textField.stringValue = launchable.displayName;
    
	return result;
}

#pragma mark -

#pragma mark -
#pragma mark Interface Control
- (void)updateSetupControls {
	[self.setupView resetAll];
    
	[self.setupWindow makeFirstResponder:[self currentLaunchableTableView]];
    
	self.launchableSelectedIndex = (int)([[self currentLaunchableTableView] selectedRow]);
    
	if (self.launchableSelectedIndex >= 0) {
		BOOL gestureExistsForSelectedApp = NO;
        
		gestureExistsForSelectedApp = ([self.appController.gestureRecognitionController.recognitionModel getGestureWithIdentity:((Launchable *)[self currentLaunchableArray][self.launchableSelectedIndex]).launchId] != nil);
        
		if (gestureExistsForSelectedApp) {
			[self.showGestureButton setEnabled:YES];
			[self.assignGestureButton setEnabled:YES];
			[self.clearGestureButton setEnabled:YES];
		}
		else {
			[self.showGestureButton setEnabled:NO];
			[self.assignGestureButton setEnabled:YES];
			[self.clearGestureButton setEnabled:NO];
		}
	}
    
	if (![MultitouchManager systemIsMultitouchCapable]) {
		self.multitouchOptionField.alphaValue = 0.5;
		[self.multitouchOptionField setEnabled:NO];
		self.multitouchRecognitionLabel.alphaValue = 0.5;
        
		if (self.setupModel.multitouchOption) {
			[self.setupModel saveMultitouchOption:NO];
		}
	}
	else {
		self.multitouchOptionField.alphaValue = 1.0;
		[self.multitouchOptionField setEnabled:YES];
		self.multitouchRecognitionLabel.alphaValue = 1.0;
	}
    
	self.minimumRecognitionScoreField.stringValue = [NSString stringWithFormat:@"%i", self.setupModel.minimumRecognitionScore];
	self.readingDelayTimeField.stringValue = [NSString stringWithFormat:@"%i", self.setupModel.readingDelayTime];
	self.multitouchOptionField.state = self.setupModel.multitouchOption;
	self.fullscreenOptionField.state = self.setupModel.fullscreenOption;
	self.loginStartOptionField.state = self.setupModel.loginStartOption;
}

- (void)showDrawNotification:(BOOL)show {
	if (self.setupModel.multitouchOption) {
		self.drawNotificationText.stringValue = @"Draw now!";
	}
	else {
		self.drawNotificationText.stringValue = @"Draw here!";
	}
    
	if (show) {
		self.drawNotificationText.alphaValue = 1.0;
	}
	else {
		self.drawNotificationText.alphaValue = 0.0;
	}
}

#pragma mark -

#pragma mark -
#pragma mark Setup Utilities
- (void)saveGestureWithStrokes:(NSMutableArray *)gestureStrokes {
	Launchable *gestureToSaveLaunchable = [self currentLaunchableArray][self.launchableSelectedIndex];
    
	[self.appController.gestureRecognitionController.recognitionModel saveGestureWithStrokes:gestureStrokes andIdentity:gestureToSaveLaunchable.launchId];
    
	[self updateSetupControls];
}

#pragma mark -

#pragma mark -
#pragma mark Setup Actions
- (IBAction)assignSelectedGesture:(id)sender {
	[self.setupView startDetectingGesture];
}

- (IBAction)showSelectedGesture:(id)sender {
	if (self.showGestureThread) {
		[self.showGestureThread cancel];
		self.showGestureThread = nil;
	}
    
	if (self.launchableSelectedIndex >= 0) {
		@try {
			Gesture *gestureToShow = [self.appController.gestureRecognitionController.recognitionModel getGestureWithIdentity:((Launchable *)[self currentLaunchableArray][self.launchableSelectedIndex]).launchId];
			self.showGestureThread = [[NSThread alloc] initWithTarget:self.setupView selector:@selector(showGesture:) object:gestureToShow];
			[self.showGestureThread start];
		}
		@catch (NSException *exception)
		{
		}
	}
}

- (IBAction)clearSelectedGesture:(id)sender {
	if (self.launchableSelectedIndex >= 0) {
		[self.appController.gestureRecognitionController.recognitionModel deleteGestureWithName:((Launchable *)[self currentLaunchableArray][self.launchableSelectedIndex]).launchId];
	}
    
	[self updateSetupControls];
}

#pragma mark -

#pragma mark -
#pragma mark Window Methods
- (void)positionSetupWindow {
	NSRect menuBarFrame = [[[self.statusBarItem view] window] frame];
	NSPoint pt = NSMakePoint(NSMidX(menuBarFrame), NSMidY(menuBarFrame));
    
	pt.y -= menuBarFrame.size.height / 2;
	pt.y -= self.setupWindow.frame.size.height;
	pt.x -= self.setupWindow.frame.size.width / 2;
    
	[self.setupWindow setFrameOrigin:pt];
}

- (IBAction)toggleSetupWindow:(id)sender {
	[self positionSetupWindow];
    
	if (self.setupWindow.alphaValue <= 0) {
		if (!self.appController.gestureRecognitionController.recognitionView.detectingInput) {
			[self launchableTypeChanged:nil];
            
			[self.setupWindow orderFrontRegardless];
            
			[NSAnimationContext beginGrouping];
			[[NSAnimationContext currentContext] setDuration:0.16];
			[[NSAnimationContext currentContext] setCompletionHandler: ^{
			    [self.setupWindow makeKeyWindow];
			}];
			[self.setupWindow.animator setAlphaValue:1.0];
			[NSAnimationContext endGrouping];
		}
	}
	else {
		[NSAnimationContext beginGrouping];
		[[NSAnimationContext currentContext] setDuration:0.16];
		[[NSAnimationContext currentContext] setCompletionHandler: ^{
		    [self hideSetupWindow];
		}];
		[self.setupWindow.animator setAlphaValue:0.0];
		[NSAnimationContext endGrouping];
	}
    
	[self updateSetupControls];
}

- (void)hideSetupWindow {
	self.setupWindow.alphaValue = 0.0;
	[self.setupWindow orderOut:self];
	[self.setupWindow setFrameOrigin:NSMakePoint(-10000, -10000)];
}

- (void)windowDidResignKey:(NSNotification *)notification {
	if (self.setupWindow.alphaValue > 0) {
		if (self.setupView.detectingInput) {
			[self.setupView finishDetectingGesture:YES];
		}
        
		[self toggleSetupWindow:nil];
	}
}

- (void)repositionSetupWindow:(NSNotification *)notification {
	if (self.setupWindow.alphaValue > 0) {
		[self positionSetupWindow];
	}
}

#pragma mark -

#pragma mark -
#pragma mark Recognition Options
- (IBAction)minimumRecognitionScoreChanged:(id)sender {
	[self.setupView finishDetectingGesture:YES];
    
	int newScore = [self.minimumRecognitionScoreField intValue];
	if (newScore >= 70 && newScore <= 100) {
		[self.setupModel saveMinimumRecognitionScore:newScore];
	}
    
	[self updateSetupControls];
}

- (IBAction)readingDelayTimeChanged:(id)sender {
	[self.setupView finishDetectingGesture:YES];
    
	int newTime = [self.readingDelayTimeField intValue];
	if (newTime >= 1 && newTime <= 1000) {
		[self.setupModel saveReadingDelayTime:newTime];
	}
    
	[self updateSetupControls];
}

- (IBAction)multitouchOptionChanged:(id)sender {
	[self.setupView finishDetectingGesture:YES];
    
	[self.setupModel saveMultitouchOption:self.multitouchOptionField.state];
    
	[self updateSetupControls];
}

- (IBAction)fullscreenOptionChanged:(id)sender {
	[self.setupView finishDetectingGesture:YES];
    
	[self.setupModel saveFullscreenOption:self.fullscreenOptionField.state];
    
	[self updateSetupControls];
}

- (IBAction)loginStartOptionChanged:(id)sender {
	[self.setupView finishDetectingGesture:YES];
    
	[self.setupModel saveLoginStartOption:self.loginStartOptionField.state];
    
	self.loginStartOptionField.state = [self.setupModel fetchLoginStartOption];
    
	[self updateSetupControls];
}

#pragma mark -

@end
