#import <Foundation/Foundation.h>

@interface GestureSetupWindow : NSPanel {
}
- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag;
- (BOOL)canBecomeKeyWindow;

@end
