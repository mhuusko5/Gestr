#import <Foundation/Foundation.h>
#import "MultitouchEvent.h"

@interface MultitouchListener : NSObject

@property id target;
@property SEL callback;
@property NSThread *thread;

- (id)initWithTarget:(id)target callback:(SEL)callback andThread:(NSThread *)thread;
- (void)sendMultitouchEvent:(MultitouchEvent *)event;

@end
