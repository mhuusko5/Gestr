#import <Foundation/Foundation.h>
#import "MultitouchTouch.h"

@interface MultitouchEvent : NSObject

@property NSNumber *deviceIdentifier;
@property NSNumber *frameIdentifier;
@property double timestamp;
@property NSArray *touches;

- (id)initWithDeviceIdentifier:(int)deviceId frameIdentifier:(int)frameId andTimestamp:(double)timestamp;

@end
