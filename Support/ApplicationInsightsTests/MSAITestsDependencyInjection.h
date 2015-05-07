#import <XCTest/XCTest.h>

#import <OCMock/OCMock.h>

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>

@interface MSAITestsDependencyInjection : XCTestCase

- (void)setMockNotificationCenter:(id)mockNotificationCenter;
- (id)mockNotificationCenter;

- (void)setMockUserDefaults:(NSUserDefaults *)userDefaults;
- (NSUserDefaults *)mockUserDefaults;

@end
