#import <AppKit/AppKit.h>
#import "NSColor+ColorExtensions.h"

#define AppButtonBlackGradientBottomColor         [NSColor colorWithDeviceWhite:0.150 alpha:1.000]
#define AppButtonBlackGradientTopColor            [NSColor colorWithDeviceWhite:0.220 alpha:1.000]
#define AppButtonBlackHighlightColor              [NSColor colorWithDeviceWhite:1.000 alpha:0.050]
#define AppButtonBlueGradientBottomColor          [NSColor colorWithDeviceRed:0.000 green:0.310 blue:0.780 alpha:1.000]
#define AppButtonBlueGradientTopColor             [NSColor colorWithDeviceRed:0.000 green:0.530 blue:0.870 alpha:1.000]
#define AppButtonBlueHighlightColor               [NSColor colorWithDeviceWhite:1.000 alpha:0.250]

#define AppButtonTextFont                         [NSFont systemFontOfSize:12.f]
#define AppButtonBlackTextShadowOffset            NSMakeSize(0.f, 1.f)
#define AppButtonBlackTextShadowBlurRadius        1.f
#define AppButtonBlackTextShadowColor             [NSColor blackColor]
#define AppButtonBlueTextShadowOffset             NSMakeSize(0.f, -1.f)
#define AppButtonBlueTextShadowBlurRadius         2.f
#define AppButtonBlueTextShadowColor              [NSColor colorWithDeviceWhite:0.000 alpha:0.600]

#define AppButtonDisabledAlpha                    0.7f
#define AppButtonCornerRadius                     3.f
#define AppButtonDropShadowColor                  [NSColor colorWithDeviceWhite:1.000 alpha:0.050]
#define AppButtonDropShadowBlurRadius             1.f
#define AppButtonDropShadowOffset                 NSMakeSize(0.f, -1.f)
#define AppButtonBorderColor                      [NSColor blackColor]
#define AppButtonHighlightOverlayColor            [NSColor colorWithDeviceWhite:0.000 alpha:0.300]

#define AppButtonCheckboxTextOffset               3.f
#define AppButtonCheckboxCheckmarkColor           [NSColor colorWithDeviceWhite:0.780 alpha:1.000]
#define AppButtonCheckboxCheckmarkLeftOffset      4.f
#define AppButtonCheckboxCheckmarkTopOffset       1.f
#define AppButtonCheckboxCheckmarkShadowOffset    NSMakeSize(0.f, 0.f)
#define AppButtonCheckboxCheckmarkShadowBlurRadius 3.f
#define AppButtonCheckboxCheckmarkShadowColor     [NSColor colorWithDeviceWhite:0.000 alpha:0.750]
#define AppButtonCheckboxCheckmarkLineWidth       2.f

@interface AppButtonCell : NSButtonCell {
	NSBezierPath *__bezelPath;
	NSButtonType __buttonType;
}

@end
