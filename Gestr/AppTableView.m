#import "AppTableView.h"

@implementation AppTableView

- (BOOL)resignFirstResponder {
	[(GestureSetupController *)self.delegate tableViewFocus : YES];
	return YES;
}

- (BOOL)becomeFirstResponder {
	[(GestureSetupController *)self.delegate tableViewFocus : NO];
	return YES;
}

@end
