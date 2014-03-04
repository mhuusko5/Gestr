#import "GestureSetupModel.h"
#import "AppController.h"
#import "GestureSetupWindow.h"
#import "GestureSetupView.h"
#import "Launchable.h"
#import "MultitouchManager.h"
#import "NSStatusItemPrioritizer.h"
@class GestureSetupView, AppController;

@interface GestureSetupController : NSObject

@property GestureSetupModel *setupModel;
@property AppController *appController;
@property IBOutlet GestureSetupWindow *setupWindow;
@property IBOutlet GestureSetupView *setupView;

#pragma mark -
#pragma mark Initialization
- (void)awakeFromNib;
- (void)applicationDidFinishLaunching;
#pragma mark -

#pragma mark -
#pragma mark Tableview Management
- (NSMutableArray *)currentLaunchableArray;
- (NSTableView *)currentLaunchableTableView;
- (IBAction)launchableTypeChanged:(id)sender;
- (void)tableViewFocus:(BOOL)lost;
- (void)tableViewSelectionDidChange:(NSNotification *)aNotification;
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView;
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
#pragma mark -

#pragma mark -
#pragma mark Interface Control
- (void)updateSetupControls;
- (void)showDrawNotification:(BOOL)show;
#pragma mark -

#pragma mark -
#pragma mark Setup Utilities
- (void)saveGestureWithStrokes:(NSMutableArray *)gestureStrokes;
#pragma mark -

#pragma mark -
#pragma mark Setup Actions
- (IBAction)assignSelectedGesture:(id)sender;
- (IBAction)showSelectedGesture:(id)sender;
- (IBAction)clearSelectedGesture:(id)sender;
#pragma mark -

#pragma mark -
#pragma mark Window Methods
- (void)positionSetupWindow;
- (IBAction)toggleSetupWindow:(id)sender;
- (void)hideSetupWindow;
- (void)windowDidResignKey:(NSNotification *)notification;
- (void)repositionSetupWindow:(NSNotification *)notification;
#pragma mark -

#pragma mark -
#pragma mark Recognition Options
- (IBAction)minimumRecognitionScoreChanged:(id)sender;
- (IBAction)readingDelayTimeChanged:(id)sender;
- (IBAction)multitouchOptionChanged:(id)sender;
- (IBAction)fullscreenOptionChanged:(id)sender;
- (IBAction)loginStartOptionChanged:(id)sender;
- (IBAction)quickdrawOptionChanged:(id)sender;
#pragma mark -

@end
