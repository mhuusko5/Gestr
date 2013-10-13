#import "ChromePage.h"

@implementation ChromePage

- (void)launch {
    ChromeApplication *application = [SBApplication applicationWithBundleIdentifier:@"com.google.Chrome"];
    ChromeWindow *window = [[[application classForScriptingClass:@"window"] alloc] initWithProperties:nil];
    [application.windows addObject:window];
    window.activeTab.URL = self.launchId;
    [application activate];
}

@end
