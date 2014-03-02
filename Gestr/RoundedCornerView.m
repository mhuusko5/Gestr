#import "RoundedCornerView.h"

@implementation RoundedCornerView

- (void)drawRect:(NSRect)dirtyRect {
	[[NSColor colorWithCalibratedWhite:0.05 alpha:1] setFill];

	if (_roundRadius > 0) {
		NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:dirtyRect xRadius:_roundRadius yRadius:_roundRadius];
		[path fill];
	}
	else {
		NSRectFill(dirtyRect);
	}
}

@end
