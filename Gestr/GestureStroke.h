#import <Foundation/Foundation.h>
#import "GesturePoint.h"

@interface GestureStroke : NSObject <NSCopying, NSCoding> {
	NSMutableArray *points;
}
@property NSMutableArray *points;

- (id)init;
- (id)initWithPoints:(NSMutableArray *)_points;
- (void)addPoint:(GesturePoint *)_point;
- (int)pointCount;
- (void)insertPoint:(GesturePoint *)_point AtIndex:(int)index;
- (GesturePoint *)pointAtIndex:(int)i;
- (void)encodeWithCoder:(NSCoder *)coder;
- (id)initWithCoder:(NSCoder *)coder;
- (id)copyWithZone:(NSZone *)zone;
- (NSString *)description;

@end
