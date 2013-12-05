#import "GestureRecognitionModel.h"

@interface GestureRecognitionModel ()

@property NSUserDefaults *storage;

@property NSMutableDictionary *gestureDictionary;

@end

@implementation GestureRecognitionModel

- (id)init {
	self = [super init];
    
	_storage = [NSUserDefaults standardUserDefaults];
    
	return self;
}

#pragma mark -
#pragma mark Setup
- (void)setup {
    [self fetchAndLoadGestures];
}

#pragma mark -

#pragma mark -
#pragma mark Gesture Data
- (void)fetchAndLoadGestures {
	[self fetchGestureDictionary];
    
	self.gestureDetector = [[GestureRecognizer alloc] init];
    
	@try {
		for (id plistGestureKey in self.gestureDictionary) {
			Gesture *plistGesture = [self getGestureWithIdentity:plistGestureKey];
			if (plistGesture) {
				[self.gestureDetector addGesture:plistGesture];
			}
			else {
				@throw [NSException exceptionWithName:@"InvalidGesture" reason:@"Corrupted gesture data." userInfo:nil];
			}
		}
	}
	@catch (NSException *exception)
	{
		self.gestureDictionary = [NSMutableDictionary dictionary];
		[self saveGestureDictionary];
        
		self.gestureDetector = [[GestureRecognizer alloc] init];
	}
}

- (BOOL)fetchGestureDictionary {
	NSMutableDictionary *gestures;
	@try {
		NSData *gestureData;
		if ((gestureData = [self.storage objectForKey:@"Gestures"])) {
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
    
	self.gestureDictionary = gestures;
}

- (void)saveGestureDictionary {
	[self.storage setObject:[NSKeyedArchiver archivedDataWithRootObject:self.gestureDictionary] forKey:@"Gestures"];
	[self.storage synchronize];
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
        
        (self.gestureDictionary)[identity] = gestureToSave;
        [self saveGestureDictionary];
        
        [self.gestureDetector addGesture:gestureToSave];
	}
}

- (Gesture *)getGestureWithIdentity:(NSString *)identity {
	Gesture *gesture = (self.gestureDictionary)[identity];
	if (gesture && gesture.identity && gesture.strokes && gesture.strokes.count > 0) {
		return gesture;
	}
	else {
		return nil;
	}
}

- (void)deleteGestureWithName:(NSString *)identity {
	[self.gestureDictionary removeObjectForKey:identity];
	[self saveGestureDictionary];
    
	[self.gestureDetector removeGestureWithIdentity:identity];
}

#pragma mark -

@end
