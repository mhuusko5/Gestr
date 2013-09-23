#import "AppTableView.h"

@implementation AppTableView

- (BOOL)resignFirstResponder {
	[(GestureSetupController *)self.delegate tableViewFocus : YES];
	return true;
}

- (BOOL)becomeFirstResponder {
	[(GestureSetupController *)self.delegate tableViewFocus : NO];
	return true;
}

@end
