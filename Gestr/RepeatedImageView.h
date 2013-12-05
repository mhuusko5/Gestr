#import "AppController.h"
#import "GestureSetupWindow.h"

@interface RepeatedImageView : NSImageView

@property float roundRadius;

- (void)drawRect:(NSRect)dirtyRect;
- (void)mouseDown:(NSEvent *)theEvent;

@end
