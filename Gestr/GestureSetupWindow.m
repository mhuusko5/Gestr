#import "GestureSetupWindow.h"

@implementation GestureSetupWindow

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag {
	self = [super initWithContentRect:contentRect styleMask:(NSBorderlessWindowMask | NSNonactivatingPanelMask) backing:NSBackingStoreBuffered defer:NO];
    
	[self setLevel:NSPopUpMenuWindowLevel];
	[self setCollectionBehavior:NSWindowCollectionBehaviorCanJoinAllSpaces];
	[self setMovableByWindowBackground:NO];
	[self setAlphaValue:0.0];
	[self setOpaque:NO];
	[self setHasShadow:YES];
	[self setBackgroundColor:[NSColor clearColor]];
    
	return self;
}

- (BOOL)canBecomeKeyWindow {
	return YES;
}

@end
