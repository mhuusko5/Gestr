#import <Cocoa/Cocoa.h>

@interface RepeatedImageView : NSImageView {
	NSColor *backgroundColor;
    float roundRadius;
}
@property float roundRadius;
- (void)drawRect:(NSRect)dirtyRect;

@end
