#import <Foundation/Foundation.h>
#import <Carbon/Carbon.h>
#import "AppController.h"
#import "GestureSetupWindow.h"
#import "GestureSetupView.h"
#import "NSColor+ColorExtensions.h"
#import "App.h"
#import "MultitouchManager.h"

@class GestureSetupView, AppController;

@interface GestureSetupController : NSObject {
	IBOutlet GestureSetupWindow *setupWindow;
	IBOutlet GestureSetupView *setupView;
    
	IBOutlet NSTextField *drawNowText;
    
	IBOutlet NSSegmentedControl *appTypePicker;
    
	IBOutlet NSView *parentAppView;
	IBOutlet NSView *appView;
	IBOutlet NSTableView *appTableView;
    
	IBOutlet NSArrayController *appArrayController;
	NSMutableArray *appArray;
	NSMutableArray *utilitiesArray;
	NSMutableArray *systemArray;
    
	IBOutlet NSTextField *successfulRecognitionScoreTextField, *readingDelayTextField;
    
	IBOutlet NSButton *showGestureButton, *assignGestureButton, *deleteGestureButton;
    
	IBOutlet NSButton *multitouchCheckbox, *fullscreenCheckbox;
    
	IBOutlet NSButton *hideDockIconCheckbox, *startAtLaunchCheckbox;
    
    IBOutlet NSTextField *multitouchRecognitionLabel;
    
	int successfulRecognitionScore, readingDelayNumber;
    
	BOOL multitouchRecognition, fullscreenRecognition;
    
	BOOL hideDockIcon, startAtLaunch;
    
	NSStatusItem *statusBarItem;
	IBOutlet NSView *statusBarView;
    
	AppController *appController;
    
	NSThread *showGestureThread;
    
	int selectedIndex;
    
	BOOL checkedForUpdate;
}
@property BOOL multitouchRecognition;
@property BOOL fullscreenRecognition;
@property int successfulRecognitionScore;
@property int readingDelayNumber;
@property (retain) GestureSetupWindow *setupWindow;
@property (retain) GestureSetupView *setupView;
@property (retain) AppController *appController;
@property (retain) NSTextField *drawNowText;

- (id)init;
- (void)loadApps;
- (void)addAppsAtPath:(NSString *)path toArray:(NSMutableArray *)arr levels:(int)l;
- (void)awakeFromNib;
- (void)delayedAwake;
- (void)showUpdateAlert:(NSString *)version;
- (void)checkForUpdate:(BOOL)async;
- (void)saveGestureWithStrokes:(NSMutableArray *)gestureStrokes;
- (void)deleteGestureWithName:(NSString *)bundleName;
- (App *)appWithBundleName:(NSString *)bundleName;
- (NSMutableArray *)currentAppArray;
- (NSTableView *)currentTableView;
- (IBAction)successfulRecognitionScoreChanged:(id)sender;
- (IBAction)useMultitouchOptionChanged:(id)sender;
- (IBAction)fullscreenOptionChanged:(id)sender;
- (void)updateHideDockIcon;
- (void)updateStartAtLaunch;
- (BOOL)willStartAtLaunch;
- (IBAction)hideIconOptionChanged:(id)sender;
- (IBAction)loginStartOptionChanged:(id)sender;
- (IBAction)readingDelayNumberChanged:(id)sender;
- (IBAction)deleteSelectedGesture:(id)sender;
- (IBAction)showSelectedGesture:(id)sender;
- (IBAction)assignSelectedGesture:(id)sender;
- (void)tableViewFocus:(BOOL)lost;
- (IBAction)appTypeChanged:(id)sender;
- (void)updateSetupControls;
- (void)tableViewSelectionDidChange:(NSNotification *)aNotification;
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView;
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
- (IBAction)toggleGestureSetupWindow:(id)sender;

@end
