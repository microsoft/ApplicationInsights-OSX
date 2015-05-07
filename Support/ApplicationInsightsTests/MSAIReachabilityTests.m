#import <XCTest/XCTest.h>
#import "MSAIReachability.h"
#import "MSAIReachabilityPrivate.h"

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

@interface MSAIReachabilityTests : XCTestCase
@end

NSString *const testHostName = @"www.google.com";

@implementation MSAIReachabilityTests{
  MSAIReachability *_sut;
}

- (void)setUp {
  [super setUp];
  
  _sut = [MSAIReachability sharedInstance];
}

- (void)tearDown {
  _sut = nil;
  
  [super tearDown];
}

- (void)testThatItInstantiates {
  assertThat(_sut, notNilValue());
  assertThat(_sut.networkQueue, notNilValue());
  assertThat(_sut.singletonQueue, notNilValue());
}


- (void)testDescriptionForReachabilityType{
  MSAIReachabilityType type = MSAIReachabilityTypeNone;
  assertThat([_sut descriptionForReachabilityType:type], equalToIgnoringCase(@"none"));
  
  type = MSAIReachabilityTypeWIFI;
  assertThat([_sut descriptionForReachabilityType:type], equalToIgnoringCase(@"wifi"));
  
  type = MSAIReachabilityTypeWWAN;
  assertThat([_sut descriptionForReachabilityType:type], equalToIgnoringCase(@"wwan"));
}

@end
