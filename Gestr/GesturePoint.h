#import <Foundation/Foundation.h>

@interface GesturePoint : NSObject <NSCopying, NSCoding>

@property float x, y;
@property int strokeId;

- (id)initWithX:(float)x andY:(float)y andStrokeId:(int)strokeId;
- (void)encodeWithCoder:(NSCoder *)coder;
- (id)initWithCoder:(NSCoder *)coder;
- (id)copyWithZone:(NSZone *)zone;
- (NSString *)description;

@end
