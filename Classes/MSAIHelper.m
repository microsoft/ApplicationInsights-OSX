#import "MSAIHelper.h"
#import "MSAIKeychainUtils.h"
#import "ApplicationInsights.h"
#import "ApplicationInsightsPrivate.h"
#import <QuartzCore/QuartzCore.h>

#import <sys/sysctl.h>
#import <AppKit/AppKit.h>


static NSString *const kMSAIUtcDateFormatter = @"utcDateFormatter";

typedef struct {
  uint8_t       info_version;
  const char    msai_version[16];
  const char    msai_build[16];
} msai_info_t;

msai_info_t applicationinsights_library_info __attribute__((section("__TEXT,__msai_ios,regular,no_dead_strip"))) = {
  .info_version = 1,
  .msai_version = MSAI_C_VERSION,
  .msai_build = MSAI_C_BUILD
};

#pragma mark NSString helpers

NSString *msai_URLEncodedString(NSString *inputString) {
  return CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                   (__bridge CFStringRef)inputString,
                                                                   NULL,
                                                                   CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                   kCFStringEncodingUTF8)
                           );
}

NSString *msai_URLDecodedString(NSString *inputString) {
  return CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
                                                                                   (__bridge CFStringRef)inputString,
                                                                                   CFSTR(""),
                                                                                   kCFStringEncodingUTF8)
                           );
}

// Return ISO 8601 string representation of the date
NSString *msai_utcDateString(NSDate *date){
  static NSDateFormatter *dateFormatter;
  
  static dispatch_once_t dateFormatterToken;
  dispatch_once(&dateFormatterToken, ^{
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormatter = [NSDateFormatter new];
    dateFormatter.locale = enUSPOSIXLocale;
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
    dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
  });
  
  NSString *dateString = [dateFormatter stringFromDate:date];
  
  return dateString;
}

NSString *msai_base64String(NSData * data, unsigned long length) {
  SEL base64EncodingSelector = NSSelectorFromString(@"base64EncodedStringWithOptions:");
  if ([data respondsToSelector:base64EncodingSelector]) {
    return [data base64EncodedStringWithOptions:0];
  } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return [data base64Encoding];
#pragma clang diagnostic pop
  }
}

NSString *msai_settingsDir(void) {
  static NSString *settingsDir = nil;
  static dispatch_once_t predSettingsDir;
  
  dispatch_once(&predSettingsDir, ^{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    // temporary directory for crashes grabbed from PLCrashReporter
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    settingsDir = [paths[0] stringByAppendingPathComponent:kMSAIIdentifier];
    
    if (![fileManager fileExistsAtPath:settingsDir]) {
      NSDictionary *attributes = @{NSFilePosixPermissions : @0755};
      NSError *theError = NULL;
      
      [fileManager createDirectoryAtPath:settingsDir withIntermediateDirectories: YES attributes: attributes error: &theError];
    }
  });
  
  return settingsDir;
}


NSString *msai_keychainMSAIServiceName(void) {
  static NSString *serviceName = nil;
  static dispatch_once_t predServiceName;
  
  dispatch_once(&predServiceName, ^{
    serviceName = [NSString stringWithFormat:@"%@.MSAI", msai_mainBundleIdentifier()];
  });
  
  return serviceName;
}

NSString *msai_mainBundleIdentifier(void) {
  return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
}

NSString *msai_encodeInstrumentationKey(NSString *inputString) {
  return (inputString ? msai_URLEncodedString(inputString) : msai_URLEncodedString(msai_mainBundleIdentifier()));
}

NSString *msai_osVersionBuild(void) {
  void *result = NULL;
  size_t result_len = 0;
  int ret;
  
  /* If our buffer is too small after allocation, loop until it succeeds -- the requested destination size
   * may change after each iteration. */
  do {
    /* Fetch the expected length */
    if ((ret = sysctlbyname("kern.osversion", NULL, &result_len, NULL, 0)) == -1) {
      break;
    }
    
    /* Allocate the destination buffer */
    if (result != NULL) {
      free(result);
    }
    result = malloc(result_len);
    
    /* Fetch the value */
    ret = sysctlbyname("kern.osversion", result, &result_len, NULL, 0);
  } while (ret == -1 && errno == ENOMEM);
  
  /* Handle failure */
  if (ret == -1) {
    int saved_errno = errno;
    
    if (result != NULL) {
      free(result);
    }
    
    errno = saved_errno;
    return NULL;
  }
  
  NSString *osBuild = [NSString stringWithCString:result encoding:NSUTF8StringEncoding];
  free(result);
  
  NSString* osVersion = nil;

  if ([[NSProcessInfo processInfo] respondsToSelector:@selector(operatingSystemVersion)]) {
    NSOperatingSystemVersion osSystemVersion = [[NSProcessInfo processInfo] operatingSystemVersion];
    osVersion = [NSString stringWithFormat:@"%ld.%ld.%ld", (long)osSystemVersion.majorVersion, (long)osSystemVersion.minorVersion, (long)osSystemVersion.patchVersion];
  } else {
    SInt32 major, minor, bugfix;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
    OSErr err1 = Gestalt(gestaltSystemVersionMajor, &major);
    OSErr err2 = Gestalt(gestaltSystemVersionMinor, &minor);
    OSErr err3 = Gestalt(gestaltSystemVersionBugFix, &bugfix);
    if ((!err1) && (!err2) && (!err3)) {
      osVersion = [NSString stringWithFormat:@"%ld.%ld.%ld", (long)major, (long)minor, (long)bugfix];
    }
  }
  
  return [NSString stringWithFormat:@"%@(%@)", osVersion, osBuild];
}

NSString *msai_osName(void){
  // TODO: get os Name
  return @"OS X";
}

NSString *msai_appVersion(void){
  NSString *build = [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"];
  NSString *version = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
  
  if(version){
    return [NSString stringWithFormat:@"%@ (%@)", version, build];
  }else{
    return build;
  }
}

NSString *msai_deviceType(void){
  // TODO: get device type, like "Tablet", "Phone", ...

  return @"Unknown";
}

NSString *msai_screenSize(void){
  NSScreen *focusScreen = [NSScreen mainScreen];
  CGFloat scale = focusScreen.backingScaleFactor;
  CGSize screenSize = [focusScreen frame].size;
  
  return [NSString stringWithFormat:@"%dx%d",(int)(screenSize.width * scale),(int)(screenSize.height * scale)];
}

NSString *msai_sdkVersion(void){
  return [NSString stringWithFormat:@"mac:%@", [NSString stringWithUTF8String:applicationinsights_library_info.msai_version]];
}

NSString *msai_sdkBuild(void) {
  return [NSString stringWithUTF8String:applicationinsights_library_info.msai_build];
}

NSString *msai_devicePlatform(void) {
  NSString *model = nil;
  
  int error = 0;
  int value = 0;
  size_t length = sizeof(value);
  
  error = sysctlbyname("hw.model", NULL, &length, NULL, 0);
  if (error == 0) {
    char *cpuModel = (char *)malloc(sizeof(char) * length);
    if (cpuModel != NULL) {
      error = sysctlbyname("hw.model", cpuModel, &length, NULL, 0);
      if (error == 0) {
        model = @(cpuModel);
      }
      free(cpuModel);
    }
  }
  
  return model;
}

NSString *msai_deviceLanguage(void) {
  return [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
}

NSString *msai_deviceLocale(void) {
  NSLocale *locale = [NSLocale currentLocale];
  return [locale objectForKey:NSLocaleIdentifier];
}

NSString *msai_UUID(void) {
  NSString *resultUUID = [[NSUUID UUID] UUIDString];
  
  return resultUUID;
}

NSString *msai_appAnonID(void) {
  static NSString *appAnonID = nil;
  static dispatch_once_t predAppAnonID;
  
  dispatch_once(&predAppAnonID, ^{
    // first check if we already have an install string in the keychain
    NSString *appAnonIDKey = @"appAnonID";
    
    __block NSError *error = nil;
    appAnonID = [MSAIKeychainUtils getPasswordForUsername:appAnonIDKey andServiceName:msai_keychainMSAIServiceName() error:&error];
    
    if (!appAnonID) {
      appAnonID = msai_UUID();
      // store this UUID in the keychain (on this device only) so we can be sure to always have the same ID upon app startups
      if (appAnonID) {
        // add to keychain in a background thread, since we got reports that storing to the keychain may take several seconds sometimes and cause the app to be killed
        // and we don't care about the result anyway
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
          [MSAIKeychainUtils storeUsername:appAnonIDKey
                               andPassword:appAnonID
                            forServiceName:msai_keychainMSAIServiceName()
                            updateExisting:YES
                             accessibility:kSecAttrAccessibleAlwaysThisDeviceOnly
                                     error:&error];
        });
      }
    }
  });
  
  return appAnonID;
}


BOOL msai_isRunningInAppExtension(void) {
  static BOOL isRunningInAppExtension = NO;
  static dispatch_once_t checkAppExtension;
  
  dispatch_once(&checkAppExtension, ^{
    isRunningInAppExtension = ([[[NSBundle mainBundle] executablePath] rangeOfString:@".appex/"].location != NSNotFound);
  });
  
  return isRunningInAppExtension;
}

/**
 * Check if the debugger is attached
 *
 * Taken from https://github.com/plausiblelabs/plcrashreporter/blob/2dd862ce049e6f43feb355308dfc710f3af54c4d/Source/Crash%20Demo/main.m#L96
 *
 * @return `YES` if the debugger is attached to the current process, `NO` otherwise
 */
BOOL msai_isDebuggerAttached(void) {
  static BOOL debuggerIsAttached = NO;
  
  static dispatch_once_t debuggerPredicate;
  dispatch_once(&debuggerPredicate, ^{
    struct kinfo_proc info;
    size_t info_size = sizeof(info);
    int name[4];
    
    name[0] = CTL_KERN;
    name[1] = KERN_PROC;
    name[2] = KERN_PROC_PID;
    name[3] = getpid();
    
    if(sysctl(name, 4, &info, &info_size, NULL, 0) == -1) {
      NSLog(@"[ApplicationInsights] ERROR: Checking for a running debugger via sysctl() failed: %s", strerror(errno));
      debuggerIsAttached = false;
    }
    
    if(!debuggerIsAttached && (info.kp_proc.p_flag & P_TRACED) != 0)
      debuggerIsAttached = true;
  });
  
  return debuggerIsAttached;
}

