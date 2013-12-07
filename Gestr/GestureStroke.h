#import <Foundation/Foundation.h>
#import "GesturePoint.h"

@interface GestureStroke : NSObject <NSCopying, NSCoding>

@property NSMutableArray *points;

- (id)init;
- (id)initWithPoints:(NSMutableArray *)points;
- (void)addPoint:(GesturePoint *)point;
- (int)pointCount;
- (GesturePoint *)pointAtIndex:(int)i;
- (void)insertPoint:(GesturePoint *)point atIndex:(int)i;
- (void)encodeWithCoder:(NSCoder *)coder;
- (id)initWithCoder:(NSCoder *)coder;
- (id)copyWithZone:(NSZone *)zone;
- (NSString *)description;

@end
