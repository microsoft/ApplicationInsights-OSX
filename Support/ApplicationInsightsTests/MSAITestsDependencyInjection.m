#import "MSAITestsDependencyInjection.h"

static NSUserDefaults *mockUserDefaults;
static id testNotificationCenter;
static id mockCenter;

@implementation NSUserDefaults (UnitTests)

+ (instancetype)standardUserDefaults {
  if (!mockUserDefaults) {
    mockUserDefaults = OCMPartialMock([NSUserDefaults new]);
  }
  return mockUserDefaults;
}

@end

@implementation MSAITestsDependencyInjection

- (void)setUp {
  [self setMockNotificationCenter:OCMPartialMock([NSNotificationCenter new])];
}

- (void)tearDown {
  [super tearDown];
  mockUserDefaults = nil;
}

# pragma mark - Helper

- (void)setMockNotificationCenter:(id)mockNotificationCenter {
  mockCenter = OCMClassMock([NSNotificationCenter class]);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wstrict-selector-match"
  OCMStub([mockCenter defaultCenter]).andReturn(mockNotificationCenter);
#pragma clang diagnostic pop
  testNotificationCenter = mockNotificationCenter;
}

- (id)mockNotificationCenter {
  return testNotificationCenter;
}

- (void)setMockUserDefaults:(NSUserDefaults *)userDefaults {
  mockUserDefaults = userDefaults;
}

- (NSUserDefaults *)mockUserDefaults {
  return mockUserDefaults;
}

@end
