#import "RepeatedImageView.h"

@implementation RepeatedImageView

@synthesize roundRadius;

- (void)drawRect:(NSRect)dirtyRect {
	if (!backgroundColor) {
		backgroundColor = [NSColor colorWithPatternImage:self.image];
	}
    
	if (self.roundRadius > 0) {
		NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:dirtyRect xRadius:self.roundRadius yRadius:self.roundRadius];
		[path addClip];
	}
    
	[backgroundColor set];
	NSRectFill(dirtyRect);
}

@end
