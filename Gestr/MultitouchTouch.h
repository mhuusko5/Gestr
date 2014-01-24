#import <Foundation/Foundation.h>
#import "MultitouchSupport.h"
@class MultitouchEvent;

@interface MultitouchTouch : NSObject

@property NSNumber *identifier;
@property int state;
@property float x;
@property float y;
@property float minorAxis;
@property float majorAxis;
@property float angle;
@property float size;
@property float velX;
@property float velY;

- (id)initWithMTTouch:(MTTouch *)touch;

@end
