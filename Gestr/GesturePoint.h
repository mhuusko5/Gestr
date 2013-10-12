#import <Foundation/Foundation.h>

@interface GesturePoint : NSObject <NSCopying, NSCoding> {
	NSValue *point;
	int strokeId;
}
@property int strokeId;

- (id)initWithX:(float)_x andY:(float)_y andStrokeId:(int)_strokeId;
#if (TARGET_OS_IPHONE || TARGET_OS_IPAD || TARGET_IPHONE_SIMULATOR)
- (id)initWithPoint:(CGPoint)_point andStrokeId:(int)_strokeId;
#else
- (id)initWithPoint:(NSPoint)_point andStrokeId:(int)_strokeId;
#endif
- (id)initWithValue:(NSValue *)_value andStrokeId:(int)_strokeId;
- (void)setX:(float)_x;
- (void)setY:(float)_y;
- (float)getX;
- (float)getY;
- (void)encodeWithCoder:(NSCoder *)coder;
- (id)initWithCoder:(NSCoder *)coder;
- (id)copyWithZone:(NSZone *)zone;
- (NSString *)description;

@end
