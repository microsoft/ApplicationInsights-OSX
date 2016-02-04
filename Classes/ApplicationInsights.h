#import <Foundation/Foundation.h>

//! Project version number for ApplicationInsights.
FOUNDATION_EXPORT double ApplicationInsightsVersionNumber;

//! Project version string for ApplicationInsights.
FOUNDATION_EXPORT const unsigned char ApplicationInsightsVersionString[];

#import "ApplicationInsightsFeatureConfig.h"
#import "MSAINullability.h"
#import "MSAIApplicationInsights.h"

#if MSAI_FEATURE_TELEMETRY
#import "MSAITelemetryManager.h"
#endif /* MSAI_FEATURE_TELEMETRY */

// Notification message which MSAIApplicationInsights is listening to, to retry requesting updated from the server
#define MSAINetworkDidBecomeReachableNotification @"MSAINetworkDidBecomeReachable"

#define MSAI_SERVER_URL   @"https://dc.services.visualstudio.com/v2/track"
