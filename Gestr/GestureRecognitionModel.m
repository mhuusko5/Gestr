#import "GestureRecognitionModel.h"

@implementation GestureRecognitionModel

@synthesize gestureDetector;

- (id)init {
	self = [super init];
    
	userDefaults = [NSUserDefaults standardUserDefaults];
    
	[self fetchAndLoadGestures];
    
	return self;
}

#pragma mark -
#pragma mark Gesture Data
- (void)fetchAndLoadGestures {
	[self fetchGestureDictionary];
    
	gestureDetector = [[GestureRecognizer alloc] init];
    
	@try {
		for (id plistGestureKey in gestureDictionary) {
			Gesture *plistGesture = [self getGestureWithIdentity:plistGestureKey];
			if (plistGesture) {
				[gestureDetector addGesture:plistGesture];
			}
			else {
				@throw [NSException exceptionWithName:@"InvalidGesture" reason:@"Corrupted gesture data." userInfo:nil];
			}
		}
	}
	@catch (NSException *exception)
	{
		gestureDictionary = [NSMutableDictionary dictionary];
		[self saveGestureDictionary];
        
		gestureDetector = [[GestureRecognizer alloc] init];
	}
}

- (BOOL)fetchGestureDictionary {
	NSMutableDictionary *gestures;
	@try {
		NSData *gestureData;
		if ((gestureData = [userDefaults objectForKey:@"Gestures"])) {
			gestures = [NSMutableDictionary dictionaryWithDictionary:[NSKeyedUnarchiver unarchiveObjectWithData:gestureData]];
		}
		else {
			gestures = [NSMutableDictionary dictionary];
		}
	}
	@catch (NSException *exception)
	{
		gestures = [NSMutableDictionary dictionary];
	}
    
	gestureDictionary = gestures;
    
	[self saveGestureDictionary];
}

- (void)saveGestureDictionary {
	[userDefaults setObject:[NSKeyedArchiver archivedDataWithRootObject:gestureDictionary] forKey:@"Gestures"];
	[userDefaults synchronize];
}

#pragma mark -

#pragma mark -
#pragma mark Setup Utilities
- (void)saveGestureWithStrokes:(NSMutableArray *)gestureStrokes andIdentity:(NSString *)identity {
    int inputPointCount = 0;
	for (GestureStroke *stroke in gestureStrokes) {
		inputPointCount += [stroke pointCount];
	}
	if (inputPointCount > GUMinimumPointCount) {
		Gesture *gestureToSave = [[Gesture alloc] initWithIdentity:identity andStrokes:gestureStrokes];
        
        [gestureDictionary setObject:gestureToSave forKey:identity];
        [self saveGestureDictionary];
        
        [gestureDetector addGesture:gestureToSave];
	}
}

- (Gesture *)getGestureWithIdentity:(NSString *)identity {
	Gesture *gesture = [gestureDictionary objectForKey:identity];
	if (gesture && gesture.identity && gesture.strokes && gesture.strokes.count > 0) {
		return gesture;
	}
	else {
		return nil;
	}
}

- (void)deleteGestureWithName:(NSString *)identity {
	[gestureDictionary removeObjectForKey:identity];
	[self saveGestureDictionary];
    
	[gestureDetector removeGestureWithIdentity:identity];
}

#pragma mark -

@end
