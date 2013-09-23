#import "RepeatedImageView.h"

@implementation RepeatedImageView

- (void)drawRect:(NSRect)dirtyRect {
	[[NSColor colorWithPatternImage:self.image] set];
	[NSBezierPath fillRect:[self bounds]];
}

@end
