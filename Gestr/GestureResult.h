#import <Foundation/Foundation.h>

@interface GestureResult : NSObject {
	NSString *gestureIdentity;
	int score;
}
@property NSString *gestureIdentity;
@property int score;

@end
