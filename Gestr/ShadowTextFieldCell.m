#import "ShadowTextFieldCell.h"

@implementation ShadowTextFieldCell

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
	NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithAttributedString:[self attributedStringValue]];
    
	NSShadow *textShadow = [NSShadow new];
	[textShadow setShadowOffset:AppButtonBlackTextShadowOffset];
	[textShadow setShadowColor:AppButtonBlackTextShadowColor];
	[textShadow setShadowBlurRadius:AppButtonBlackTextShadowBlurRadius];
    
	[attrString addAttribute:NSShadowAttributeName value:textShadow range:((NSRange) {0, [attrString length] })];
	[attrString addAttribute:NSForegroundColorAttributeName value:[myWhiteColor darkenColorByValue:0.1] range:((NSRange) {0, [attrString length] })];
    
	[attrString drawInRect:NSIntegralRect(cellFrame)];
}

@end
