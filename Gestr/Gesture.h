#import <Foundation/Foundation.h>
#import "GestureUtils.h"
#import "GestureTemplate.h"

@interface Gesture : NSObject <NSCopying, NSCoding> {
	NSMutableArray *strokes;
	NSMutableArray *templates;
	NSString *identifier;
}
@property NSString *identifier;
@property NSMutableArray *strokes;
@property NSMutableArray *templates;

- (id)initWithId:(NSString *)_id andStrokes:(NSMutableArray *)_strokes;
- (void)generateTemplates;
- (void)encodeWithCoder:(NSCoder *)coder;
- (id)initWithCoder:(NSCoder *)coder;
- (id)copyWithZone:(NSZone *)zone;
- (NSString *)description;

@end
