#import <Foundation/Foundation.h>
#import "MultitouchEvent.h"

@interface MultitouchListener : NSObject {
	id target;
	SEL callback;
	NSThread *thread;
}
@property id target;
@property SEL callback;
@property NSThread *thread;

- (id)initWithTarget:(id)_target callback:(SEL)_callback andThread:(NSThread *)_thread;
- (void)sendMultitouchEvent:(MultitouchEvent *)event;

@end
