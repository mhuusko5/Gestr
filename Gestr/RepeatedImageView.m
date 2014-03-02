#import "RepeatedImageView.h"

@interface RepeatedImageView ()

@property NSColor *backgroundColor;

@end

@implementation RepeatedImageView

- (void)drawRect:(NSRect)dirtyRect {
	if (!_backgroundColor) {
		if (self.image) {
			_backgroundColor = [NSColor colorWithPatternImage:self.image];
		}
		else {
			_backgroundColor = [NSColor blackColor];
		}
	}

	if (_roundRadius > 0) {
		NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:dirtyRect xRadius:_roundRadius yRadius:_roundRadius];
		[path addClip];
	}

	[_backgroundColor set];
	NSRectFill(dirtyRect);
}

- (void)mouseDown:(NSEvent *)theEvent {
	if ([self.window isKindOfClass:[GestureSetupWindow class]]) {
		[((AppController *)[NSApp delegate]).gestureSetupController updateSetupControls];
	}
}

@end
