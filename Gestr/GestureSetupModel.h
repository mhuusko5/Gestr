#import <Foundation/Foundation.h>
#import "MultitouchManager.h"
#import "Launchable.h"

@interface GestureSetupModel : NSObject {
	NSUserDefaults *userDefaults;
    
    NSMutableArray *normalAppArray, *utilitiesAppArray, *systemAppArray;
    
	int readingDelayNumber, successfulRecognitionScore;
	BOOL multitouchRecognition, fullscreenRecognition, hideDockIcon, startAtLaunch;
}
@property NSMutableArray *normalAppArray, *utilitiesAppArray, *systemAppArray;
@property int readingDelayNumber, successfulRecognitionScore;
@property BOOL multitouchRecognition, fullscreenRecognition, hideDockIcon, startAtLaunch;

#pragma mark -
#pragma mark Applications Arrays
- (NSMutableArray *)fetchNormalAppArray;
- (NSMutableArray *)fetchUtilitiesAppArray;
- (NSMutableArray *)fetchSystemAppArray;
- (NSMutableArray *)addApplicationsAtPath:(NSString *)path toArray:(NSMutableArray *)arr depth:(int)depth;
#pragma mark -

#pragma mark -
#pragma mark Recognition Options
- (int)fetchSuccessfulRecognitionScore;
- (void)saveSuccessfulRecognitionScore:(int)newScore;
- (int)fetchReadingDelayNumber;
- (void)saveReadingDelayNumber:(int)newNum;
- (BOOL)fetchMultitouchRecognition;
- (void)saveMultitouchRecognition:(BOOL)newValue;
- (BOOL)fetchFullscreenRecognition;
- (void)saveFullscreenRecognition:(BOOL)newValue;
- (BOOL)fetchHideDockIcon;
- (void)saveHideDockIcon:(BOOL)newValue;
- (BOOL)fetchStartAtLaunch;
- (void)saveStartAtLaunch:(BOOL)newValue;
#pragma mark -

@end
