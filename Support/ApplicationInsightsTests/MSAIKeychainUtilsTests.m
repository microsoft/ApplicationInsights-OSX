#import <XCTest/XCTest.h>

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>

#import "ApplicationInsights.h"
#import "MSAIKeychainUtils.h"

@interface MSAIKeychainUtilsTests : XCTestCase {

}
@end


@implementation MSAIKeychainUtilsTests
- (void)setUp {
  [super setUp];
  
  // Set-up code here.
}

- (void)tearDown {
  // Tear-down code here.
  [super tearDown];
}

- (void)testThatMSAIKeychainHelperStoresAndRetrievesPassword {
  [MSAIKeychainUtils deleteItemForUsername:@"Peter" andServiceName:@"Test" error:nil];
  BOOL success =   [MSAIKeychainUtils storeUsername:@"Peter"
                                        andPassword:@"Pan"
                                     forServiceName:@"Test"
                                     updateExisting:YES
                                              error:nil];
  assertThatBool(success, isTrue());
  NSString *pass = [MSAIKeychainUtils getPasswordForUsername:@"Peter"
                                              andServiceName:@"Test"
                                                       error:NULL];
  assertThat(pass, equalTo(@"Pan"));
}

- (void)testThatMSAIKeychainHelperStoresAndRetrievesPasswordThisDeviceOnly {
  // kSecAttrAccessibleAlwaysThisDeviceOnly is only available in 10.9 or later
  CFTypeRef accessibility = 0;
  if (NSAppKitVersionNumber >= NSAppKitVersionNumber10_9) {
    accessibility = kSecAttrAccessibleAlwaysThisDeviceOnly;
  }
  [MSAIKeychainUtils deleteItemForUsername:@"Peter" andServiceName:@"Test" error:nil];
  BOOL success =   [MSAIKeychainUtils storeUsername:@"Peter"
                                        andPassword:@"PanThisDeviceOnly"
                                     forServiceName:@"Test"
                                     updateExisting:YES
                                      accessibility:accessibility
                                              error:nil];
  assertThatBool(success, isTrue());
  NSString *pass = [MSAIKeychainUtils getPasswordForUsername:@"Peter"
                                              andServiceName:@"Test"
                                                       error:NULL];
  assertThat(pass, equalTo(@"PanThisDeviceOnly"));
}

- (void)testThatMSAIKeychainHelperRemovesAStoredPassword {
  [MSAIKeychainUtils deleteItemForUsername:@"Peter" andServiceName:@"Test" error:nil];
  [MSAIKeychainUtils storeUsername:@"Peter"
                       andPassword:@"Pan"
                    forServiceName:@"Test"
                    updateExisting:YES
                             error:nil];
  BOOL success = [MSAIKeychainUtils deleteItemForUsername:@"Peter" andServiceName:@"Test" error:nil];
  assertThatBool(success, isTrue());
  
  NSString *pass = [MSAIKeychainUtils getPasswordForUsername:@"Peter"
                                              andServiceName:@"Test"
                                                       error:NULL];
  assertThat(pass, equalTo(nil));
}

@end
