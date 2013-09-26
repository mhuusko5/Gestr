#import <Cocoa/Cocoa.h>

@interface RepeatedImageView : NSImageView {
    NSColor *backgroundColor;
}
@property float roundRadius;
- (void)drawRect:(NSRect)dirtyRect;

@end
