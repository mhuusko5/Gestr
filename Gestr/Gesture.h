#import <Foundation/Foundation.h>
#import "GestureUtils.h"
#import "GestureTemplate.h"

@interface Gesture : NSObject <NSCopying, NSCoding>

@property NSString *identity;
@property NSMutableArray *strokes;
@property NSMutableArray *templates;

- (id)initWithIdentity:(NSString *)identity andStrokes:(NSMutableArray *)strokes;
- (void)generateTemplates;
- (void)encodeWithCoder:(NSCoder *)coder;
- (id)initWithCoder:(NSCoder *)coder;
- (id)copyWithZone:(NSZone *)zone;
- (NSString *)description;

@end
