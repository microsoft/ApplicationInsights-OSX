#import "MSAICrashExceptionApplication.h"

#import <sys/sysctl.h>

#import "MSAIHelper.h"
#import "MSAICrashManagerPrivate.h"

@implementation MSAICrashExceptionApplication

/*
 * Solution for Scenario 2
 *
 * Catch all exceptions that are being logged to the console and send them
 */
- (void)reportException:(NSException *)exception {
  [super reportException: exception];
  
  // Don't send the exception if we are currently debugging this app!
  if (!msai_isDebuggerAttached() && exception) {
    NSUncaughtExceptionHandler *exceptionHandler = [[MSAICrashManager sharedManager] exceptionHandler];
    if (exceptionHandler && exception) {
      exceptionHandler(exception);
    }
  }
}

/*
 * Solution for Scenario 3
 *
 * Exceptions that happen inside an IBAction implementation do not trigger a call to
 * [NSApp reportException:] and it does not trigger a registered UncaughtExceptionHandler
 * Hence we need to catch these ourselves, e.g. by overwriting sendEvent: as done right here
 *
 * On 64bit systems the @try @catch block doesn't even cost any performance.
 */
- (void)sendEvent:(NSEvent *)theEvent {
  @try {
    [super sendEvent:theEvent];
  } @catch (NSException *exception) {
    [self reportException:exception];
  }
}

@end
