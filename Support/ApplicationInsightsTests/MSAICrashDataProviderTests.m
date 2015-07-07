#import <XCTest/XCTest.h>
#import "MSAICrashDataProvider.h"

@interface MSAICrashDataProviderTests : XCTestCase

@end

@implementation MSAICrashDataProviderTests

- (void)setUp {
  [super setUp];
}

- (void)tearDown {
  [super tearDown];
}

- (void)testOSXImages {
  NSString *processPath = nil;
  NSString *appBundlePath = nil;
  
  appBundlePath = @"/Applications/MyTestApp.App";
  
  // Test with default OS X app path
  processPath = [appBundlePath stringByAppendingString:@"/Contents/MacOS/MyApp"];
  [self testOSXNonAppSpecificImagesForProcessPath:processPath];
  [self testAppBinaryWithImagePath:processPath processPath:processPath];
  
  // Test with OS X LoginItems app helper path
  processPath = [appBundlePath stringByAppendingString:@"/Contents/Library/LoginItems/net.hockeyapp.helper.app/Contents/MacOS/Helper"];
  [self testOSXNonAppSpecificImagesForProcessPath:processPath];
  [self testAppBinaryWithImagePath:processPath processPath:processPath];
  
  // Test with OS X app in Resources folder
  processPath = @"/Applications/MyTestApp.App/Contents/Resources/Helper";
  [self testOSXNonAppSpecificImagesForProcessPath:processPath];
  [self testAppBinaryWithImagePath:processPath processPath:processPath];  
}

#pragma mark - Test Helper

- (void)testAppBinaryWithImagePath:(NSString *)imagePath processPath:(NSString *)processPath {
  MSAIBinaryImageType imageType = [MSAICrashDataProvider imageTypeForImagePath:imagePath
                                                                            processPath:processPath];
  XCTAssert((imageType == MSAIBinaryImageTypeAppBinary), @"Test app %@ with process %@", imagePath, processPath);
}

#pragma mark - OS X Test Helper

- (void)testOSXAppFrameworkAtProcessPath:(NSString *)processPath appBundlePath:(NSString *)appBundlePath {
  NSString *frameworkPath = [appBundlePath stringByAppendingString:@"/Contents/Frameworks/MyFrameworkLib.framework/Versions/A/MyFrameworkLib"];
  MSAIBinaryImageType imageType = [MSAICrashDataProvider imageTypeForImagePath:frameworkPath
                                                                   processPath:processPath];
  XCTAssert((imageType == MSAIBinaryImageTypeAppFramework), @"Test framework %@ with process %@", frameworkPath, processPath);
  
  frameworkPath = [appBundlePath stringByAppendingString:@"/Contents/Frameworks/libSwiftMyLib.framework/Versions/A/libSwiftMyLib"];
  imageType = [MSAICrashDataProvider imageTypeForImagePath:frameworkPath
                                               processPath:processPath];
  XCTAssert((imageType == MSAIBinaryImageTypeAppFramework), @"Test framework %@ with process %@", frameworkPath, processPath);
  
  NSMutableArray *swiftFrameworkPaths = [NSMutableArray new];
  [swiftFrameworkPaths addObject:[appBundlePath stringByAppendingString:@"/Contents/Frameworks/libswiftCore.dylib"]];
  [swiftFrameworkPaths addObject:[appBundlePath stringByAppendingString:@"/Contents/Frameworks/libswiftDarwin.dylib"]];
  [swiftFrameworkPaths addObject:[appBundlePath stringByAppendingString:@"/Contents/Frameworks/libswiftDispatch.dylib"]];
  [swiftFrameworkPaths addObject:[appBundlePath stringByAppendingString:@"/Contents/Frameworks/libswiftFoundation.dylib"]];
  [swiftFrameworkPaths addObject:[appBundlePath stringByAppendingString:@"/Contents/Frameworks/libswiftObjectiveC.dylib"]];
  [swiftFrameworkPaths addObject:[appBundlePath stringByAppendingString:@"/Contents/Frameworks/libswiftSecurity.dylib"]];
  [swiftFrameworkPaths addObject:[appBundlePath stringByAppendingString:@"/Contents/Frameworks/libswiftCoreGraphics.dylib"]];
  
  for (NSString *imagePath in swiftFrameworkPaths) {
    MSAIBinaryImageType imageType = [MSAICrashDataProvider imageTypeForImagePath:imagePath
                                                                     processPath:processPath];
    XCTAssert((imageType == MSAIBinaryImageTypeOther), @"Test swift image %@ with process %@", imagePath, processPath);
  }
}

- (void)testOSXNonAppSpecificImagesForProcessPath:(NSString *)processPath {
  // system test paths
  NSMutableArray *nonAppSpecificImagePaths = [NSMutableArray new];
  
  // OS X frameworks
  [nonAppSpecificImagePaths addObject:@"cl_kernels"];
  [nonAppSpecificImagePaths addObject:@""];
  [nonAppSpecificImagePaths addObject:@"???"];
  [nonAppSpecificImagePaths addObject:@"/System/Library/Frameworks/CFNetwork.framework/Versions/A/CFNetwork"];
  [nonAppSpecificImagePaths addObject:@"/usr/lib/system/libsystem_platform.dylib"];
  [nonAppSpecificImagePaths addObject:@"/System/Library/Frameworks/Accelerate.framework/Versions/A/Frameworks/vecLib.framework/Versions/A/vecLib"];
  [nonAppSpecificImagePaths addObject:@"/System/Library/PrivateFrameworks/Sharing.framework/Versions/A/Sharing"];
  [nonAppSpecificImagePaths addObject:@"/usr/lib/libbsm.0.dylib"];
  
  for (NSString *imagePath in nonAppSpecificImagePaths) {
    MSAIBinaryImageType imageType = [MSAICrashDataProvider imageTypeForImagePath:imagePath
                                                                     processPath:processPath];
    XCTAssert((imageType == MSAIBinaryImageTypeOther), @"Test other image %@ with process %@", imagePath, processPath);
  }
}

@end
