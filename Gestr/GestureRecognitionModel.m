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

	_gestureDetector = [[GestureRecognizer alloc] init];

	@try {
		for (id plistGestureKey in _gestureDictionary) {
			Gesture *plistGesture = [self getGestureWithIdentity:plistGestureKey];
			if (plistGesture) {
				[_gestureDetector addGesture:plistGesture];
			}
			else {
				@throw [NSException exceptionWithName:@"InvalidGesture" reason:@"Corrupted gesture data." userInfo:nil];
			}
		}
	}
	@catch (NSException *exception)
	{
		_gestureDictionary = [NSMutableDictionary dictionary];
		[self saveGestureDictionary];

		_gestureDetector = [[GestureRecognizer alloc] init];
	}
}

- (BOOL)fetchGestureDictionary {
	NSMutableDictionary *gestures;
	@try {
		NSData *gestureData;
		if ((gestureData = [_storage objectForKey:@"Gestures"])) {
			gestures = [((NSDictionary *)[NSKeyedUnarchiver unarchiveObjectWithData:gestureData])mutableCopy];
		}
		else {
			gestures = [NSMutableDictionary dictionary];
		}
	}
	@catch (NSException *exception)
	{
		gestures = [NSMutableDictionary dictionary];
	}

	_gestureDictionary = gestures;
}

- (void)saveGestureDictionary {
	[_storage setObject:[NSKeyedArchiver archivedDataWithRootObject:_gestureDictionary] forKey:@"Gestures"];
	[_storage synchronize];
}

#pragma mark -

#pragma mark -
#pragma mark Setup Utilities
- (void)saveGestureWithStrokes:(NSMutableArray *)gestureStrokes andIdentity:(NSString *)identity {
	int inputPointCount = 0;
	for (GestureStroke *stroke in gestureStrokes) {
		inputPointCount += stroke.pointCount;
	}
	if (inputPointCount > GUMinimumPointCount) {
		Gesture *gestureToSave = [[Gesture alloc] initWithIdentity:identity andStrokes:gestureStrokes];

		_gestureDictionary[identity] = gestureToSave;
		[self saveGestureDictionary];

		[_gestureDetector addGesture:gestureToSave];
	}
}

- (Gesture *)getGestureWithIdentity:(NSString *)identity {
	Gesture *gesture = _gestureDictionary[identity];
	if (gesture && gesture.identity && gesture.strokes && gesture.strokes.count > 0) {
		return gesture;
	}
	else {
		return nil;
	}
}

- (void)deleteGestureWithName:(NSString *)identity {
	[_gestureDictionary removeObjectForKey:identity];
	[self saveGestureDictionary];

	[_gestureDetector removeGestureWithIdentity:identity];
}

#pragma mark -

@end
