#import <Foundation/Foundation.h>
#import "GestureUtils.h"
#import "GestureTemplate.h"

@interface Gesture : NSObject <NSCopying, NSCoding> {
	NSMutableArray *strokes;
	NSMutableArray *templates;
	NSString *identity;
}
@property NSString *identity;
@property NSMutableArray *strokes;
@property NSMutableArray *templates;

- (id)initWithIdentity:(NSString *)_identity andStrokes:(NSMutableArray *)_strokes;
- (void)generateTemplates;
- (void)encodeWithCoder:(NSCoder *)coder;
- (id)initWithCoder:(NSCoder *)coder;
- (id)copyWithZone:(NSZone *)zone;
- (NSString *)description;

@end
