#import "AppSegmentedCell.h"

#define AppSegControlGradientBottomColor         [NSColor colorWithDeviceWhite:0.150 alpha:1.000]
#define AppSegControlGradientTopColor            [NSColor colorWithDeviceWhite:0.220 alpha:1.000]
#define AppSegControlSelectedGradientBottomColor [NSColor colorWithDeviceWhite:0.130 alpha:1.000]
#define AppSegControlSelectedGradientTopColor    [NSColor colorWithDeviceWhite:0.120 alpha:1.000]

#define AppSegControlDividerGradientBottomColor  [NSColor colorWithDeviceWhite:0.120 alpha:1.000]
#define AppSegControlDividerGradientTopColor     [NSColor colorWithDeviceWhite:0.160 alpha:1.000]

#define AppSegControlHighlightColor              [NSColor colorWithDeviceWhite:1.000 alpha:0.050]
#define AppSegControlHighlightOverlayColor       [NSColor colorWithDeviceWhite:0.000 alpha:0.300]
#define AppSegControlBorderColor                 [NSColor blackColor]
#define AppSegControlCornerRadius                3.f

#define AppSegControlInnerShadowColor            [NSColor colorWithDeviceWhite:0.000 alpha:1.000]
#define AppSegControlInnerShadowBlurRadius       3.f
#define AppSegControlInnerShadowOffset           NSMakeSize(0.f, -1.f)

#define AppSegControlDropShadowColor             [NSColor colorWithDeviceWhite:1.000 alpha:0.050]
#define AppSegControlDropShadowBlurRadius        1.f
#define AppSegControlDropShadowOffset            NSMakeSize(0.f, -1.f)

#define AppSegControlTextFont                    [NSFont systemFontOfSize:11.f]
#define AppSegControlTextColor                   [NSColor colorWithDeviceWhite:0.700 alpha:1.000]
#define AppSegControlSelectedTextColor           [NSColor whiteColor]
#define AppSegControlSelectedTextShadowOffset    NSMakeSize(0.f, -1.f)
#define AppSegControlTextShadowOffset            NSMakeSize(0.f, 1.f)
#define AppSegControlTextShadowBlurRadius        1.f
#define AppSegControlTextShadowColor             [NSColor blackColor]

#define AppSegControlDisabledAlpha               0.5f

#define AppSegControlXEdgeMargin                 10.f
#define AppSegControlYEdgeMargin                 5.f
#define AppSegControlImageLabelMargin            5.f

// This is a value that is set internally by AppKit, used for layout purposes in this code
// Don't change this
#define AppSegControlDivderWidth 3.f

@interface AppSegmentedCell ()
// Returns the bezier path that the border was drawn in
- (NSBezierPath *)App_drawBackgroundWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;
- (NSRect)App_widthForSegment:(NSInteger)segment;
- (void)App_drawInteriorOfSegment:(NSInteger)segment inFrame:(NSRect)frame inView:(NSView *)controlView;
@end

@implementation AppSegmentedCell

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
	cellFrame.size.height += 5;

	CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
	if (![self isEnabled]) {
		CGContextSetAlpha(ctx, AppSegControlDisabledAlpha);
	}

	// The frame needs to be inset 0.5px to make the border line crisp
	// because NSBezierPath draws the stroke centered on the bounds of the rect
	// This means that 0.5px of the 1px stroke line will be outside the rect and the other half will be inside
	NSInteger segmentCount = [self segmentCount];
	cellFrame = NSInsetRect(cellFrame, 0.5f, 0.5f);
	cellFrame.size.height -= AppSegControlDropShadowBlurRadius; // Make room for the drop shadow
	// OS X seems to add 3px of extra space in the frame per segment for the dividers
	// but we get rid of this
	NSBezierPath *path = [self App_drawBackgroundWithFrame:cellFrame inView:controlView];
	NSRect bounds = [path bounds];
	if (!segmentCount) {
		return;
	}                              // Stop drawing if there are no segments

	[path addClip];
	// Need to improvise a bit here because there is no public API to get the
	// drawing rect of a specific segment
	CGFloat currentOrigin = 0.0;
	for (NSInteger i = 0; i < segmentCount; i++) {
		CGFloat width = [self widthForSegment:i];

		// widthForSegment: returns 0 for autosized segments
		// so we need to divide the width of the cell evenly between all the segments
		// It will still break if one segment is much wider than the others
		if (width == 0) {
			width = (cellFrame.size.width - (AppSegControlDivderWidth * (segmentCount - 1))) / segmentCount;
		}

		if (i != (segmentCount - 1)) {
			width += AppSegControlDivderWidth;
		}

		NSRect frame = NSMakeRect(bounds.origin.x + currentOrigin, bounds.origin.y, width, bounds.size.height);
		[NSGraphicsContext saveGraphicsState];
		if ([self isEnabled] && ![self isEnabledForSegment:i]) {
			CGContextSetAlpha(ctx, AppSegControlDisabledAlpha);
		}

		[self drawSegment:i inFrame:frame withView:controlView];
		[NSGraphicsContext restoreGraphicsState];
		currentOrigin += width;
	}
}

- (NSBezierPath *)App_drawBackgroundWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
	NSBezierPath *borderPath = [NSBezierPath bezierPathWithRoundedRect:cellFrame xRadius:AppSegControlCornerRadius yRadius:AppSegControlCornerRadius];
	NSGradient *gradientFill = [[NSGradient alloc] initWithStartingColor:AppSegControlGradientBottomColor endingColor:AppSegControlGradientTopColor];
	// Draw the gradient fill
	[gradientFill drawInBezierPath:borderPath angle:270.f];
	// Draw the border and drop shadow
	[NSGraphicsContext saveGraphicsState];
	[AppSegControlBorderColor set];
	NSShadow *dropShadow = [NSShadow new];
	[dropShadow setShadowColor:AppSegControlDropShadowColor];
	[dropShadow setShadowBlurRadius:AppSegControlDropShadowBlurRadius];
	[dropShadow setShadowOffset:AppSegControlDropShadowOffset];
	[dropShadow set];
	[borderPath stroke];
	[NSGraphicsContext restoreGraphicsState];
	// Draw the highlight line around the top edge of the pill
	// Outset the width of the rectangle by 0.5px so that the highlight "bleeds" around the rounded corners
	// Outset the height by 1px so that the line is drawn right below the border
	NSRect highlightRect = NSInsetRect(cellFrame, -0.5f, 1.f);
	// Make the height of the highlight rect something bigger than the bounds so that it won't show up on the bottom
	highlightRect.size.height *= 2.f;
	[NSGraphicsContext saveGraphicsState];
	NSBezierPath *highlightPath = [NSBezierPath bezierPathWithRoundedRect:highlightRect xRadius:AppSegControlCornerRadius yRadius:AppSegControlCornerRadius];
	[borderPath addClip];
	[AppSegControlHighlightColor set];
	[highlightPath stroke];
	[NSGraphicsContext restoreGraphicsState];
	return borderPath;
}

- (void)drawSegment:(NSInteger)segment inFrame:(NSRect)frame withView:(NSView *)controlView {
	BOOL selected = [self isSelectedForSegment:segment];
	// Only draw the divider if it's not selected and it isn't the last segment
	BOOL drawDivider = !selected && (segment < ([self segmentCount] - 1)) && ([self selectedSegment] != (segment + 1));
	if (selected) {
		NSGradient *gradientFill = [[NSGradient alloc] initWithStartingColor:AppSegControlSelectedGradientBottomColor endingColor:AppSegControlSelectedGradientTopColor];
		[gradientFill drawInRect:frame angle:270.f];
		NSShadow *innerShadow = [NSShadow new];
		[innerShadow setShadowColor:AppSegControlInnerShadowColor];
		[innerShadow setShadowBlurRadius:AppSegControlInnerShadowBlurRadius];
		[innerShadow setShadowOffset:AppSegControlInnerShadowOffset];
		NSBezierPath *path = [NSBezierPath bezierPathWithRect:frame];
		[path fillWithInnerShadow:innerShadow];
	}

	[self App_drawInteriorOfSegment:segment inFrame:frame inView:controlView];
	NSEvent *currentEvent = [NSApp currentEvent]; // This is probably a dirty way of figuring out whether to highlight
	if (currentEvent.type == NSLeftMouseDown && [self isEnabledForSegment:segment]) {
		NSPoint location = [controlView convertPoint:[currentEvent locationInWindow] fromView:nil];
		if (NSPointInRect(location, frame)) {
			[AppSegControlHighlightOverlayColor set];
			[NSBezierPath fillRect:frame];
		}
	}

	if (drawDivider) {
		NSRect highlightRect = NSMakeRect(round(NSMaxX(frame) - 1.f), frame.origin.y, 1.f, frame.size.height);
		[AppSegControlHighlightColor set];
		[NSBezierPath fillRect:highlightRect];
		NSRect dividerRect = highlightRect;
		dividerRect.origin.x -= 1.f;
		NSGradient *dividerFill = [[NSGradient alloc] initWithStartingColor:AppSegControlDividerGradientBottomColor endingColor:AppSegControlDividerGradientTopColor];
		[dividerFill drawInRect:NSIntegralRect(dividerRect) angle:270.f];
	}
}

- (void)App_drawInteriorOfSegment:(NSInteger)segment inFrame:(NSRect)frame inView:(NSView *)controlView {
	BOOL selected = [self isSelectedForSegment:segment];
	NSString *label = [self labelForSegment:segment];
	NSImage *image = [self imageForSegment:segment];
	NSRect imageRect = NSZeroRect;
	if (image) {
		NSSize imageSize = [image size];
		CGFloat maxImageHeight = frame.size.height - (AppSegControlYEdgeMargin * 2.f);
		CGFloat imageHeight = MIN(maxImageHeight, imageSize.height);
		imageRect = NSMakeRect(round(NSMidX(frame) - (imageSize.width / 2.f)), round(NSMidY(frame) - (imageHeight / 2.f)), imageSize.width, imageHeight);
	}

	if (label) {
		NSShadow *textShadow = [NSShadow new];
		[textShadow setShadowOffset:selected ? AppSegControlSelectedTextShadowOffset:AppSegControlTextShadowOffset];
		[textShadow setShadowColor:AppSegControlTextShadowColor];
		[textShadow setShadowBlurRadius:AppSegControlTextShadowBlurRadius];

		NSColor *textColor;
		if (selected) {
			textColor = myGreenColor;
		}
		else {
			textColor = [myWhiteColor darkenColorByValue:0.1];
		}

		NSDictionary *attributes = @{ NSFontAttributeName : AppSegControlTextFont, NSForegroundColorAttributeName: textColor, NSShadowAttributeName: textShadow };
		NSAttributedString *attrLabel = [[NSAttributedString alloc] initWithString:label attributes:attributes];
		NSSize labelSize = attrLabel.size;
		if (image) {
			CGFloat totalContentWidth = labelSize.width + imageRect.size.width + AppSegControlImageLabelMargin;
			imageRect.origin.x = round(NSMidX(frame) - (totalContentWidth / 2.f));
		}

		NSRect labelRect = NSMakeRect((image == nil) ? (NSMidX(frame) - (labelSize.width / 2.f)) : (NSMaxX(imageRect) + AppSegControlImageLabelMargin), -4 + NSMidY(frame) - (labelSize.height / 2.f), labelSize.width, labelSize.height);
		[attrLabel drawInRect:NSIntegralRect(labelRect)];
	}

	NSImageCell *imageCell = [[NSImageCell alloc] init];
	[imageCell setImage:image];
	[imageCell setImageScaling:[self imageScalingForSegment:segment]];
	[imageCell setHighlighted:[self isHighlighted]];
	[imageCell drawWithFrame:imageRect inView:controlView];
}

- (NSRect)App_widthForSegment:(NSInteger)segment {
	return NSZeroRect;
}

@end
