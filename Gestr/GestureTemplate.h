#import <Foundation/Foundation.h>
#import "GestureUtils.h"
#import "GestureStroke.h"

@interface GestureTemplate : NSObject <NSCopying, NSCoding>

@property GestureStroke *stroke;
@property GestureStroke *originalStroke;
@property GesturePoint *startUnitVector;

- (id)initWithPoints:(GestureStroke *)points;
- (void)encodeWithCoder:(NSCoder *)coder;
- (id)initWithCoder:(NSCoder *)coder;
- (id)copyWithZone:(NSZone *)zone;
- (NSString *)description;

@end
