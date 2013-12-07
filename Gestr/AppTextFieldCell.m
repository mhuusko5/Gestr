#import "AppTextFieldCell.h"

@implementation AppTextFieldCell

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
	cellFrame = NSInsetRect(cellFrame, 0.5f, 0.5f);
	cellFrame.size.height -= AppButtonDropShadowBlurRadius;
	cellFrame.origin.y += AppButtonDropShadowBlurRadius;

	NSBezierPath *__bezelPath = [NSBezierPath bezierPathWithRoundedRect:cellFrame xRadius:AppButtonCornerRadius yRadius:AppButtonCornerRadius];
	NSGradient *gradientFill = [[NSGradient alloc] initWithStartingColor:AppButtonBlackGradientBottomColor endingColor:AppButtonBlackGradientTopColor];

	[gradientFill drawInBezierPath:__bezelPath angle:270.f];

	[NSGraphicsContext saveGraphicsState];
	[AppButtonBorderColor set];
	NSShadow *dropShadow = [NSShadow new];
	[dropShadow setShadowColor:AppButtonDropShadowColor];
	[dropShadow setShadowBlurRadius:AppButtonDropShadowBlurRadius];
	[dropShadow setShadowOffset:AppButtonDropShadowOffset];
	[dropShadow set];
	[__bezelPath stroke];
	[NSGraphicsContext restoreGraphicsState];

	NSRect highlightRect = NSInsetRect(cellFrame, -0.5f, 1.f);

	highlightRect.size.height *= 2.f;
	[NSGraphicsContext saveGraphicsState];
	NSBezierPath *highlightPath = [NSBezierPath bezierPathWithRoundedRect:highlightRect xRadius:AppButtonCornerRadius yRadius:AppButtonCornerRadius];
	[__bezelPath addClip];
	[AppButtonBlackHighlightColor set];
	[highlightPath stroke];
	[NSGraphicsContext restoreGraphicsState];

	NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithAttributedString:[self attributedStringValue]];

	NSShadow *textShadow = [NSShadow new];
	[textShadow setShadowOffset:AppButtonBlackTextShadowOffset];
	[textShadow setShadowColor:AppButtonBlackTextShadowColor];
	[textShadow setShadowBlurRadius:AppButtonBlackTextShadowBlurRadius];

	[attrString addAttribute:NSShadowAttributeName value:textShadow range:(NSRange) {0, [attrString length] }
     ];
	[attrString addAttribute:NSForegroundColorAttributeName value:myGreenColor range:(NSRange) {0, [attrString length] }
     ];

	NSSize labelSize = attrString.size;
	NSRect labelRect = NSMakeRect(NSMidX(cellFrame) - (labelSize.width / 2.f), NSMidY(cellFrame) - (labelSize.height / 2.f), labelSize.width, labelSize.height);
	[attrString drawInRect:NSIntegralRect(labelRect)];
}

@end
