#import <Foundation/Foundation.h>

@interface GesturePoint : NSObject <NSCopying, NSCoding>

@property int strokeId;

- (id)initWithX:(float)x andY:(float)y andStrokeId:(int)strokeId;
#if (TARGET_OS_IPHONE || TARGET_OS_IPAD || TARGET_IPHONE_SIMULATOR)
- (id)initWithPoint:(CGPoint)point andStrokeId:(int)strokeId;
#else
- (id)initWithPoint:(NSPoint)point andStrokeId:(int)strokeId;
#endif
- (id)initWithValue:(NSValue *)value andStrokeId:(int)strokeId;
- (void)setX:(float)x;
- (void)setY:(float)y;
- (float)getX;
- (float)getY;
- (void)encodeWithCoder:(NSCoder *)coder;
- (id)initWithCoder:(NSCoder *)coder;
- (id)copyWithZone:(NSZone *)zone;
- (NSString *)description;

@end
