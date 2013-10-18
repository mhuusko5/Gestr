#import <Cocoa/Cocoa.h>

@interface GestureRecognitionWindow : NSPanel {
}

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag;
- (BOOL)canBecomeKeyWindow;

@end
