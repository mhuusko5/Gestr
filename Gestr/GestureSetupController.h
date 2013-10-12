#import <Foundation/Foundation.h>
#import <Carbon/Carbon.h>
#import "GestureSetupModel.h"
#import "AppController.h"
#import "GestureSetupWindow.h"
#import "GestureSetupView.h"
#import "NSColor+ColorExtensions.h"
#import "Launchable.h"
#import "MultitouchManager.h"

@class GestureSetupView, AppController;

@interface GestureSetupController : NSObject {
	BOOL awakedFromNib;
    
	GestureSetupModel *setupModel;
    
	AppController *appController;
    
	NSStatusItem *statusBarItem;
    IBOutlet NSView *statusBarView;
    
	BOOL checkedForUpdate;
	NSThread *showGestureThread;
    
	IBOutlet GestureSetupWindow *setupWindow;
	IBOutlet GestureSetupView *setupView;
    
	IBOutlet NSTextField *drawNowText;
    
    int launchableSelectedIndex;
	IBOutlet NSSegmentedControl *launchableTypePicker;
	IBOutlet NSView *launchableParentView;
	IBOutlet NSView *launchableView;
	IBOutlet NSTableView *launchableTableView;
	IBOutlet NSArrayController *launchableArrayController;
    
	IBOutlet NSButton *showGestureButton, *assignGestureButton, *deleteGestureButton;
    
	IBOutlet NSTextField *successfulRecognitionScoreTextField, *readingDelayTextField;
	IBOutlet NSTextField *multitouchRecognitionLabel;
	IBOutlet NSButton *multitouchCheckbox, *fullscreenCheckbox;
	IBOutlet NSButton *hideDockIconCheckbox, *startAtLaunchCheckbox;
}
@property (retain) GestureSetupModel *setupModel;
@property (retain) AppController *appController;
@property (retain) GestureSetupWindow *setupWindow;
@property (retain) GestureSetupView *setupView;

#pragma mark -
#pragma mark Initialization
- (void)awakeFromNib;
- (void)applicationDidFinishLaunching;
#pragma mark -

#pragma mark -
#pragma mark Launchable Management
- (Launchable *)launchableWithId:(NSString *)identity;
- (NSMutableArray *)currentLaunchableArray;
- (NSTableView *)currentLaunchableTableView;
- (IBAction)launchableTypeChanged:(id)sender;
#pragma mark -

#pragma mark -
#pragma mark Tableview Control
- (void)tableViewFocus:(BOOL)lost;
- (void)tableViewSelectionDidChange:(NSNotification *)aNotification;
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView;
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
#pragma mark -

#pragma mark -
#pragma mark Interface Control
- (void)updateSetupControls;
- (void)showDrawNowText:(BOOL)show;
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
- (void)showUpdateAlert:(NSString *)version;
- (IBAction)toggleSetupWindow:(id)sender;
- (void)hideSetupWindow;
#pragma mark -

#pragma mark -
#pragma mark Recognition Options
- (IBAction)successfulRecognitionScoreSelected:(id)sender;
- (IBAction)readingDelayNumberSelected:(id)sender;
- (IBAction)multitouchRecognitionSelected:(id)sender;
- (IBAction)fullscreenRecognitionSelected:(id)sender;
- (IBAction)hideDockIconSelected:(id)sender;
- (IBAction)startAtLaunchSelected:(id)sender;
#pragma mark -

@end
