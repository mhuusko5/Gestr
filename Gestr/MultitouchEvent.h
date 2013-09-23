#import <Foundation/Foundation.h>
#import "MultitouchTouch.h"

@interface MultitouchEvent : NSObject {
	NSNumber *deviceIdentifier, *frameIdentifier;
	double timestamp;
	NSArray *touches;
}
@property NSNumber *deviceIdentifier;
@property NSNumber *frameIdentifier;
@property double timestamp;
@property NSArray *touches;

- (id)initWithDeviceIdentifier:(int)deviceId frameIdentifier:(int)frameId andTimestamp:(double)_timestamp;

@end
