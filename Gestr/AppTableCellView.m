#import "AppTableCellView.h"

@implementation AppTableCellView

- (void)setBackgroundStyle:(NSBackgroundStyle)backgroundStyle {
	self.textField.textColor = (backgroundStyle == NSBackgroundStyleDark) ? myGreenColor : [myWhiteColor darkenColorByValue:0.1];
    
	[super setBackgroundStyle:backgroundStyle];
}

- (void)drawRect:(NSRect)dirtyRect {
	[super drawRect:dirtyRect];
}

@end
