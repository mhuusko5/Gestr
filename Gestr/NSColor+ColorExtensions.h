#import <Cocoa/Cocoa.h>

@interface NSColor (ColorExtensions)

- (NSColor *)lightenColorByValue:(float)value;
- (NSColor *)darkenColorByValue:(float)value;
- (BOOL)isLightColor;
@end
