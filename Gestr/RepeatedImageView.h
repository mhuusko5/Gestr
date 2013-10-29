#import <Cocoa/Cocoa.h>
#import "AppController.h"
#import "GestureSetupWindow.h"

@interface RepeatedImageView : NSImageView {
	NSColor *backgroundColor;
	float roundRadius;
}
@property float roundRadius;
- (void)drawRect:(NSRect)dirtyRect;
- (void)mouseDown:(NSEvent *)theEvent;

@end
