#import "NSStatusItemPrioritizer.h"
#import <CoreServices/CoreServices.h>

static const int NSStatusItemPriority = 8001;

@interface NSStatusBar (_NSStatusBar)
- (id)_statusItemWithLength:(float)l withPriority:(int)p;
- (id)_insertStatusItem:(NSStatusItem *)i withPriority:(int)p;
@end

@implementation NSStatusItemPrioritizer

+ (void)restartSystemUIServer {
    NSTask *killSystemUITask = [[[NSTask alloc] init] autorelease];
    NSMutableArray *args = [NSMutableArray array];
    [args addObject:@"SystemUIServer"];
    [args addObject:@"-HUP"];
    [killSystemUITask setLaunchPath:@"/usr/bin/killall"];
    [killSystemUITask setArguments:args];
    [killSystemUITask launch];
}

+ (NSStatusItem *)prioritizedStatusItem {
	NSStatusItem *prioritizedStatusItem = nil;
    
	if ([[NSStatusBar systemStatusBar] respondsToSelector:@selector(_statusItemWithLength:withPriority:)]) {
		if (!prioritizedStatusItem) {
			prioritizedStatusItem = [[NSStatusBar systemStatusBar] _statusItemWithLength:0 withPriority:NSStatusItemPriority];
		}
		[prioritizedStatusItem setLength:NSVariableStatusItemLength];
	}
    
	if (!prioritizedStatusItem) {
		prioritizedStatusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
	}else {
        [[NSNotificationCenter defaultCenter] addObserver:[self class] selector:@selector(restartSystemUIServer) name:NSApplicationWillTerminateNotification object:nil];
    }
    
	return prioritizedStatusItem;
}

@end
