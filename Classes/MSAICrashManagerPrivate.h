#import "ApplicationInsights.h"

#if MSAI_FEATURE_CRASH_REPORTER

#import "CrashReporter.h"

@class MSAIAppClient;
@class MSAIEnvelope;

NS_ASSUME_NONNULL_BEGIN
@interface MSAICrashManager ()

///-----------------------------------------------------------------------------
/// @name Properties
///-----------------------------------------------------------------------------

/**
Sets the optional `MSAICrashManagerDelegate` delegate.

The delegate is automatically set by using `[MSAIManager setDelegate:]`. You
should not need to set this delegate individually.

@see `[MSAIManager setDelegate:]`
*/
@property (nonatomic, weak) id delegate; //TODO Will be removed eventually

/*
Optional callbacks that will be called when PLCrashReporter finds a crash. Hopefully users know what they do if they use
this.
 */
@property (nonatomic, assign) PLCrashReporterCallbacks *crashCallBacks;

/*
The crashReporter instance.
 */
@property (nonatomic, strong) MSAIPLCrashReporter *plCrashReporter;


/**
* The exceptionhandler that is used for crash reporting.
*/
@property (nonatomic, assign) NSUncaughtExceptionHandler *exceptionHandler;

/**
*  This method is used to setup the CrashManager-Module of the Application Insights SDK.
*  This method is called by MSAIManager during it's initialization, so calling this by hand
*  shouldn't be necessary in most cases. It won't do anything if MSAICrashManager has been disabled.*
*/

- (void)startManager;

/**
* Checks if the crashreporting module of ApplicationInsights has been disabled
*/
- (void)checkCrashManagerDisabled;


/**
* The method that's responsible to read crash data created by from MSAIPLCrashReporter and collects additional info
* about the last crash (@see lastSessionCrashDetails)
*/
- (void)readCrashReportAndStartProcessing;

/**
* Format and create the ApplicationInsights crash report data and forward it to `MSAIChannel´for persistence and sending
*/
- (void)createCrashReportWithCrashData:(NSData*)crashData;

/**
* by default, just logs the message
*
* can be overridden by subclasses to do their own error handling,
* e.g. to show UI
*
* @param error NSError
*/
- (void)reportError:(NSError *)error;

/**
 *  Because we can't access any Objective-C code from our default signal handler callback, we need to have all necessary data and pointers already in place once it runs.
 *  This method sets permanent references to [MSAIChannel sharedChannel] and file path to which our data is written in case of a crash.
 */
- (void)configDefaultCallback;

/**
 *  This function is used as our default callback in PLCrashReporter's signal handler.
 *  It tries to write to disk the string kept by MSAIChannel as a backup.
 *
 */
void msai_save_events_callback(siginfo_t *info, ucontext_t *uap, void *context);

@end
NS_ASSUME_NONNULL_END

#endif /* MSAI_FEATURE_CRASH_REPORTER */
