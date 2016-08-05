//
//  OHCNContactsDataProviderTests.m
//  Ohana
//
//  Copyright (c) 2016 Uber Technologies, Inc.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import <XCTest/XCTest.h>
#import <Ohana/Ohana.h>
#import <OCMock/OCMock.h>

@interface OHCNContactsDataProvider ()

typedef void (^OHCNContactsFetchCompletionBlock)(NSOrderedSet<OHContact *> *contacts);
typedef void (^OHCNContactsFetchFailedBlock)(NSError *error);

- (CNAuthorizationStatus)_authorizationStatus;
- (void)_fetchContactsWithSuccess:(OHCNContactsFetchCompletionBlock)success failure:(OHCNContactsFetchFailedBlock)failure;

@end

@interface OHCNContactsDataProviderTests : XCTestCase <OHCNContactsDataProviderDelegate>

@property (nonatomic) id dataProviderMock;
@property (nonatomic) XCTestExpectation *authenticationRequestExpectation;

@end

@implementation OHCNContactsDataProviderTests

- (void)setUp
{
    [super setUp];

    OHCNContactsDataProvider *dataProvider = [[OHCNContactsDataProvider alloc] initWithDelegate:self];
    self.dataProviderMock = OCMPartialMock(dataProvider);
}

- (void)testInitialState
{
    XCTAssertNotNil([self.dataProviderMock onContactsDataProviderFinishedLoadingSignal]);
    XCTAssertNotNil([self.dataProviderMock onContactsDataProviderErrorSignal]);
    XCTAssertEqual([self.dataProviderMock status], OHContactsDataProviderStatusInitialized);
}

- (void)testProviderIdentifier
{
    XCTAssertTrue([[OHCNContactsDataProvider providerIdentifier] isEqualToString:NSStringFromClass([OHCNContactsDataProvider class])]);
}

- (void)testLoadContactsAuthChallenge
{
    self.authenticationRequestExpectation = [self expectationWithDescription:@"Data provider should fire the auth challenge signal"];
    OCMStub([self.dataProviderMock _authorizationStatus]).andReturn(CNAuthorizationStatusNotDetermined);

    [self.dataProviderMock loadContacts];

    [self waitForExpectationsWithTimeout:0.1 handler:nil];
    XCTAssertEqual([self.dataProviderMock status], OHContactsDataProviderStatusInitialized);
}

- (void)testLoadContactsSuccess
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Data provider should fire the loaded data signal"];
    OCMStub([self.dataProviderMock _authorizationStatus]).andReturn(CNAuthorizationStatusAuthorized);
    OCMStub([self.dataProviderMock _fetchContactsWithSuccess:[OCMArg any] failure:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void (^completion)(OHCNContactsFetchCompletionBlock);
        [invocation getArgument:&completion atIndex:2];
        completion(nil);
    });

    [[self.dataProviderMock onContactsDataProviderFinishedLoadingSignal] addObserver:self callback:^(typeof(self) self, id<OHContactsDataProviderProtocol> dataProvider) {
        XCTAssertEqual(dataProvider.status, OHContactsDataProviderStatusLoaded);
        [expectation fulfill];
    }];

    [self.dataProviderMock loadContacts];

    [self waitForExpectationsWithTimeout:0.1 handler:nil];
    XCTAssertEqual([self.dataProviderMock status], OHContactsDataProviderStatusLoaded);
}

- (void)testLoadContactsFailure
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Data provider should fire the error signal"];
    OCMStub([self.dataProviderMock _authorizationStatus]).andReturn(CNAuthorizationStatusDenied);
    OCMStub([self.dataProviderMock _fetchContactsWithSuccess:[OCMArg any] failure:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void (^failure)(OHCNContactsFetchFailedBlock);
        [invocation getArgument:&failure atIndex:3];
        failure(nil);
    });

    [[self.dataProviderMock onContactsDataProviderErrorSignal] addObserver:self callback:^(typeof(self) self, NSError *error, id<OHContactsDataProviderProtocol> dataProvider) {
        XCTAssertEqual(dataProvider.status, OHContactsDataProviderStatusError);
        [expectation fulfill];
    }];

    [self.dataProviderMock loadContacts];

    [self waitForExpectationsWithTimeout:0.1 handler:nil];
    XCTAssertEqual([self.dataProviderMock status], OHContactsDataProviderStatusError);
}

#pragma mark - UBCLCNContactsDataProvider

- (void)dataProviderDidHitContactsAuthenticationChallenge:(OHCNContactsDataProvider *)dataProvider
{
    [self.authenticationRequestExpectation fulfill];
}

@end
