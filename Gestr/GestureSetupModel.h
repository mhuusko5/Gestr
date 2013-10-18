#import <Foundation/Foundation.h>
#import "MultitouchManager.h"
#import "Application.h"
#import "ChromePage.h"
#import "SafariPage.h"

@interface GestureSetupModel : NSObject {
	NSUserDefaults *userDefaults;
    
	NSMutableArray *webPageArray;
	NSMutableArray *normalAppArray, *utilitiesAppArray, *systemAppArray;
    
	int readingDelayTime, minimumRecognitionScore;
	BOOL multitouchOption, fullscreenOption, loginStartOption;
}
@property NSMutableArray *webPageArray;
@property NSMutableArray *normalAppArray, *utilitiesAppArray, *systemAppArray;
@property int readingDelayTime, minimumRecognitionScore;
@property BOOL multitouchOption, fullscreenOption, loginStartOption;

#pragma mark -
#pragma mark Launchable Management
- (Launchable *)findLaunchableWithId:(NSString *)identity;
#pragma mark -

#pragma mark -
#pragma mark Web Page Management
- (NSMutableArray *)fetchWebPageArray;
- (NSMutableArray *)fetchChromePages;
- (NSMutableArray *)fetchSafariPages;
#pragma mark -

#pragma mark -
#pragma mark Applications Management
- (NSMutableArray *)fetchNormalAppArray;
- (NSMutableArray *)fetchUtilitiesAppArray;
- (NSMutableArray *)fetchSystemAppArray;
- (NSMutableArray *)addApplicationsAtPath:(NSString *)path toArray:(NSMutableArray *)arr depth:(int)depth;
#pragma mark -

#pragma mark -
#pragma mark Recognition Options
- (int)fetchMinimumRecognitionScore;
- (void)saveMinimumRecognitionScore:(int)newScore;
- (int)fetchReadingDelayTime;
- (void)saveReadingDelayTime:(int)newTime;
- (BOOL)fetchMultitouchOption;
- (void)saveMultitouchOption:(BOOL)newChoice;
- (BOOL)fetchFullscreenOption;
- (void)saveFullscreenOption:(BOOL)newChoice;
- (BOOL)fetchLoginStartOption;
- (void)saveLoginStartOption:(BOOL)newChoice;
#pragma mark -

@end
