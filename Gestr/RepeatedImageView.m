#import "RepeatedImageView.h"

@interface RepeatedImageView ()

@property NSColor *backgroundColor;

@end

@implementation RepeatedImageView

- (void)drawRect:(NSRect)dirtyRect {
	if (!self.backgroundColor) {
		self.backgroundColor = [NSColor colorWithPatternImage:self.image];
	}
    
	if (self.roundRadius > 0) {
		NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:dirtyRect xRadius:self.roundRadius yRadius:self.roundRadius];
		[path addClip];
	}
    
	[self.backgroundColor set];
	NSRectFill(dirtyRect);
}

- (void)mouseDown:(NSEvent *)theEvent {
	if ([self.window isKindOfClass:[GestureSetupWindow class]]) {
		[((AppController *)[NSApp delegate]).gestureSetupController updateSetupControls];
	}
}

@end
