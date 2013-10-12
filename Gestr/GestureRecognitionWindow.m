#import "GestureRecognitionWindow.h"

@implementation GestureRecognitionWindow

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag {
	self = [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:bufferingType defer:flag];
    
	/*
     NSNormalWindowLevel
     NSFloatingWindowLevel
     NSSubmenuWindowLevel
     NSTornOffMenuWindowLevel
     NSMainMenuWindowLevel
     NSStatusWindowLevel
     NSModalPanelWindowLevel
     NSPopUpMenuWindowLevel
     NSScreenSaverWindowLevel
	 */
    
	[self setLevel:NSStatusWindowLevel];
	[self setCollectionBehavior:NSWindowCollectionBehaviorCanJoinAllSpaces];
	[self setMovableByWindowBackground:NO];
	[self setAlphaValue:0.0];
	[self setOpaque:NO];
	[self setHasShadow:NO];
	[self setBackgroundColor:[NSColor clearColor]];
    
	return self;
}

- (BOOL)canBecomeKeyWindow {
	return YES;
}

- (BOOL)isMainWindow {
	return YES;
}

@end