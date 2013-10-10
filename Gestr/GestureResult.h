#import <Foundation/Foundation.h>

@interface GestureResult : NSObject {
	NSString *gestureId;
	int score;
}
@property NSString *gestureId;
@property int score;

@end
