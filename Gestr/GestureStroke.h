#import <Foundation/Foundation.h>
#import "GesturePoint.h"

@interface GestureStroke : NSObject <NSCopying, NSCoding> {
	NSMutableArray *points;
}
@property NSMutableArray *points;

- (id)init;
- (id)initWithPoints:(NSMutableArray *)_points;
- (void)addPoint:(GesturePoint *)point;
- (int)pointCount;
- (void)insertPoint:(GesturePoint *)point AtIndex:(int)index;
- (GesturePoint *)pointAtIndex:(int)i;
- (void)encodeWithCoder:(NSCoder *)coder;
- (id)initWithCoder:(NSCoder *)coder;
- (id)copyWithZone:(NSZone *)zone;
- (NSString *)description;

@end
