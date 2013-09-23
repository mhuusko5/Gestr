#import "AppButtonCell.h"

static NSString *const AppButtonReturnKeyEquivalent = @"\r";

@interface AppButtonCell ()
- (BOOL)App_shouldDrawBlueButton;
- (void)App_drawButtonBezelWithFrame:(NSRect)frame inView:(NSView *)controlView;
- (void)App_drawCheckboxBezelWithFrame:(NSRect)frame inView:(NSView *)controlView;
- (NSRect)App_drawButtonTitle:(NSAttributedString *)title withFrame:(NSRect)frame inView:(NSView *)controlView;
- (NSRect)App_drawCheckboxTitle:(NSAttributedString *)title withFrame:(NSRect)frame inView:(NSView *)controlView;
- (NSBezierPath *)App_checkmarkPathForRect:(NSRect)rect mixed:(BOOL)mixed;
@end

@implementation AppButtonCell

- (id)initWithCoder:(NSCoder *)aDecoder {
	if ((self = [super initWithCoder:aDecoder])) {
		__buttonType = (NSButtonType)[[self valueForKey:@"buttonType"] unsignedIntegerValue];
	}
    
	return self;
}

- (void)setButtonType:(NSButtonType)aType {
	__buttonType = aType;
	[super setButtonType:aType];
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
	if (![self isEnabled]) {
		CGContextSetAlpha([[NSGraphicsContext currentContext] graphicsPort], AppButtonDisabledAlpha);
	}
    
	[super drawWithFrame:cellFrame inView:controlView];
	if (__bezelPath && [self isHighlighted]) {
		[AppButtonHighlightOverlayColor set];
		[__bezelPath fill];
	}
}

- (void)drawBezelWithFrame:(NSRect)frame inView:(NSView *)controlView {
	[self App_drawButtonBezelWithFrame:frame inView:controlView];
}

- (NSRect)drawTitle:(NSAttributedString *)title withFrame:(NSRect)frame inView:(NSView *)controlView {
	switch (__buttonType) {
		case NSSwitchButton:
			return [self App_drawCheckboxTitle:title withFrame:frame inView:controlView];
			break;
            
		default:
			return [self App_drawButtonTitle:title withFrame:frame inView:controlView];
			break;
	}
}

- (void)drawImage:(NSImage *)image withFrame:(NSRect)frame inView:(NSView *)controlView {
	if (__buttonType == NSSwitchButton) {
		[self App_drawCheckboxBezelWithFrame:frame inView:controlView];
	}
}

- (void)App_drawButtonBezelWithFrame:(NSRect)frame inView:(NSView *)controlView {
	frame = NSInsetRect(frame, 0.5f, 0.5f);
	frame.size.height -= AppButtonDropShadowBlurRadius;
	BOOL blue = [self App_shouldDrawBlueButton];
	__bezelPath = [NSBezierPath bezierPathWithRoundedRect:frame xRadius:AppButtonCornerRadius yRadius:AppButtonCornerRadius];
	NSGradient *gradientFill = [[NSGradient alloc] initWithStartingColor:blue ? AppButtonBlueGradientBottomColor:AppButtonBlackGradientBottomColor endingColor:blue ? AppButtonBlueGradientTopColor:AppButtonBlackGradientTopColor];
    
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
    
	NSRect highlightRect = NSInsetRect(frame, -0.5f, 1.f);
    
	highlightRect.size.height *= 2.f;
	[NSGraphicsContext saveGraphicsState];
	NSBezierPath *highlightPath = [NSBezierPath bezierPathWithRoundedRect:highlightRect xRadius:AppButtonCornerRadius yRadius:AppButtonCornerRadius];
	[__bezelPath addClip];
	[blue ? AppButtonBlueHighlightColor:AppButtonBlackHighlightColor set];
	[highlightPath stroke];
	[NSGraphicsContext restoreGraphicsState];
}

- (void)App_drawCheckboxBezelWithFrame:(NSRect)frame inView:(NSView *)controlView {
	frame.size.width -= 2.f;
	frame.size.height -= 1.f;
	[self App_drawButtonBezelWithFrame:frame inView:controlView];
    
	if ([self state] == NSOffState) {
		return;
	}
    
	NSBezierPath *path = [self App_checkmarkPathForRect:frame mixed:[self state] == NSMixedState];
	[path setLineWidth:AppButtonCheckboxCheckmarkLineWidth];
	[myGreenColor set];
	NSShadow *shadow = [NSShadow new];
	[shadow setShadowColor:AppButtonCheckboxCheckmarkShadowColor];
	[shadow setShadowBlurRadius:AppButtonCheckboxCheckmarkShadowBlurRadius];
	[shadow setShadowOffset:AppButtonCheckboxCheckmarkShadowOffset];
	[NSGraphicsContext saveGraphicsState];
	[shadow set];
	[path stroke];
	[NSGraphicsContext restoreGraphicsState];
}

- (NSBezierPath *)App_checkmarkPathForRect:(NSRect)rect mixed:(BOOL)mixed {
	NSBezierPath *path = [NSBezierPath bezierPath];
	if (mixed) {
		NSPoint left = NSMakePoint(rect.origin.x + AppButtonCheckboxCheckmarkLeftOffset, round(NSMidY(rect)));
		NSPoint right = NSMakePoint(NSMaxX(rect) - AppButtonCheckboxCheckmarkLeftOffset, left.y);
		[path moveToPoint:left];
		[path lineToPoint:right];
	}
	else {
		NSPoint top = NSMakePoint(NSMaxX(rect), rect.origin.y);
		NSPoint bottom = NSMakePoint(round(NSMidX(rect)), round(NSMidY(rect)) + AppButtonCheckboxCheckmarkTopOffset);
		NSPoint left = NSMakePoint(rect.origin.x + AppButtonCheckboxCheckmarkLeftOffset, round(bottom.y / 2.f));
		[path moveToPoint:top];
		[path lineToPoint:bottom];
		[path lineToPoint:left];
	}
    
	return path;
}

- (NSRect)App_drawButtonTitle:(NSAttributedString *)title withFrame:(NSRect)frame inView:(NSView *)controlView {
	BOOL blue = [self App_shouldDrawBlueButton];
	NSString *label = [title string];
	NSShadow *textShadow = [NSShadow new];
	[textShadow setShadowOffset:blue ? AppButtonBlueTextShadowOffset:AppButtonBlackTextShadowOffset];
	[textShadow setShadowColor:blue ? AppButtonBlueTextShadowColor:AppButtonBlackTextShadowColor];
	[textShadow setShadowBlurRadius:blue ? AppButtonBlueTextShadowBlurRadius:AppButtonBlackTextShadowBlurRadius];
	NSColor *textColor;
	if ([self isEnabled]) {
		textColor = myGreenColor;
	}
	else {
		textColor = [myWhiteColor lightenColorByValue:0.6];
	}
    
	NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:AppButtonTextFont, NSFontAttributeName, textColor, NSForegroundColorAttributeName, textShadow, NSShadowAttributeName, nil];
	NSAttributedString *attrLabel = [[NSAttributedString alloc] initWithString:label attributes:attributes];
	NSSize labelSize = attrLabel.size;
	NSRect labelRect = NSMakeRect(NSMidX(frame) - (labelSize.width / 2.f), 1 + NSMidY(frame) - (labelSize.height / 2.f), labelSize.width, labelSize.height);
	[attrLabel drawInRect:NSIntegralRect(labelRect)];
	return labelRect;
}

- (NSRect)App_drawCheckboxTitle:(NSAttributedString *)title withFrame:(NSRect)frame inView:(NSView *)controlView {
	NSString *label = [title string];
	NSShadow *textShadow = [NSShadow new];
	[textShadow setShadowOffset:AppButtonBlackTextShadowOffset];
	[textShadow setShadowColor:AppButtonBlackTextShadowColor];
	[textShadow setShadowBlurRadius:AppButtonBlackTextShadowBlurRadius];
	NSColor *textColor;
	if ([self isEnabled]) {
		textColor = myGreenColor;
	}
	else {
		textColor = [myWhiteColor lightenColorByValue:0.6];
	}
    
	NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:AppButtonTextFont, NSFontAttributeName, textColor, NSForegroundColorAttributeName, textShadow, NSShadowAttributeName, nil];
	NSAttributedString *attrLabel = [[NSAttributedString alloc] initWithString:label attributes:attributes];
	NSSize labelSize = attrLabel.size;
	NSRect labelRect = NSMakeRect(frame.origin.x + AppButtonCheckboxTextOffset, NSMidY(frame) - (labelSize.height / 2.f), labelSize.width, labelSize.height);
	[attrLabel drawInRect:NSIntegralRect(labelRect)];
	return labelRect;
}

#pragma mark - Private

- (BOOL)App_shouldDrawBlueButton {
	return [[self keyEquivalent] isEqualToString:AppButtonReturnKeyEquivalent] && (__buttonType != NSSwitchButton);
}

@end
