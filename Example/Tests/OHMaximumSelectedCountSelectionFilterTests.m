//
//  OHMaximumSelectedCountSelectionFilterTests.m
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

#import "NSOrderedSetMake+Internal.h"

@interface OHMaximumSelectedCountSelectionFilterTests : XCTestCase

@property (nonatomic) id contactsDataProvider;

@end

@implementation OHMaximumSelectedCountSelectionFilterTests

- (void)setUp
{
    [super setUp];

    _contactsDataProvider = [self _createDataProviderMock];
}

- (void)testMaximumContactsSignalsHitMax
{
    OHContact *contactA = [[OHContact alloc] init];
    OHContact *contactB = [[OHContact alloc] init];

    OHContactsDataSource *contactsDataSource = [[OHContactsDataSource alloc] initWithDataProviders:NSOrderedSetMake(self.contactsDataProvider) postProcessors:nil];
    OHMaximumSelectedCountSelectionFilter *maximumCountSelectionFilter = [[OHMaximumSelectedCountSelectionFilter alloc] initWithDataSource:contactsDataSource maximumSelectedCount:2];
    contactsDataSource.selectionFilters = NSOrderedSetMake(maximumCountSelectionFilter);

    [contactsDataSource selectContacts:NSOrderedSetMake(contactA)];

    XCTestExpectation *reachedMaximumExpectation = [self expectationWithDescription:@"Data source should have signaled that selected contacts reached maximum count"];
    [maximumCountSelectionFilter.onContactsDataSourceSelectedContactsReachedMaximumCountSignal addObserver:self callback:^(typeof(self) self) {
        [reachedMaximumExpectation fulfill];
    }];

    [maximumCountSelectionFilter.onContactsDataSourceSelectedContactsAttemptedToExceedMaximumCountSignal addObserver:self callback:^(typeof(self) self, NSOrderedSet<OHContact *> *failedContacts) {
        XCTAssert(NO);
    }];

    [maximumCountSelectionFilter.onContactsDataSourceSelectedContactsNoLongerAtMaximumCountSignal addObserver:self callback:^(id _Nonnull self) {
        XCTAssert(NO);
    }];

    [contactsDataSource selectContacts:NSOrderedSetMake(contactB)];

    [self waitForExpectationsWithTimeout:0.5 handler:nil];
}

- (void)testMaximumContactsSignalsExceedMax
{
    OHContact *contactA = [[OHContact alloc] init];
    OHContact *contactB = [[OHContact alloc] init];
    OHContact *contactC = [[OHContact alloc] init];

    OHContactsDataSource *contactsDataSource = [[OHContactsDataSource alloc] initWithDataProviders:NSOrderedSetMake(self.contactsDataProvider) postProcessors:nil];
    OHMaximumSelectedCountSelectionFilter *maximumCountSelectionFilter = [[OHMaximumSelectedCountSelectionFilter alloc] initWithDataSource:contactsDataSource maximumSelectedCount:2];
    contactsDataSource.selectionFilters = NSOrderedSetMake(maximumCountSelectionFilter);

    [contactsDataSource selectContacts:NSOrderedSetMake(contactA)];
    [contactsDataSource selectContacts:NSOrderedSetMake(contactB)];

    [maximumCountSelectionFilter.onContactsDataSourceSelectedContactsReachedMaximumCountSignal addObserver:self callback:^(typeof(self) self) {
        XCTAssert(NO);
    }];

    XCTestExpectation *exceedMaximumExpectation = [self expectationWithDescription:@"Data source should have signaled that an attempt was made to exceed maximum selected contacts count"];
    [maximumCountSelectionFilter.onContactsDataSourceSelectedContactsAttemptedToExceedMaximumCountSignal addObserver:self callback:^(typeof(self) self, NSOrderedSet<OHContact *> *failedContacts) {
        [exceedMaximumExpectation fulfill];
    }];

    [maximumCountSelectionFilter.onContactsDataSourceSelectedContactsNoLongerAtMaximumCountSignal addObserver:self callback:^(id _Nonnull self) {
        XCTAssert(NO);
    }];

    [contactsDataSource selectContacts:NSOrderedSetMake(contactC)];

    [self waitForExpectationsWithTimeout:0.5 handler:nil];
}

- (void)testMaximumContactsSignalsDropFromMax
{
    OHContact *contactA = [[OHContact alloc] init];
    OHContact *contactB = [[OHContact alloc] init];

    OHContactsDataSource *contactsDataSource = [[OHContactsDataSource alloc] initWithDataProviders:NSOrderedSetMake(self.contactsDataProvider) postProcessors:nil];
    OHMaximumSelectedCountSelectionFilter *maximumCountSelectionFilter = [[OHMaximumSelectedCountSelectionFilter alloc] initWithDataSource:contactsDataSource maximumSelectedCount:2];
    contactsDataSource.selectionFilters = NSOrderedSetMake(maximumCountSelectionFilter);

    [contactsDataSource selectContacts:NSOrderedSetMake(contactA)];
    [contactsDataSource selectContacts:NSOrderedSetMake(contactB)];

    [maximumCountSelectionFilter.onContactsDataSourceSelectedContactsReachedMaximumCountSignal addObserver:self callback:^(typeof(self) self) {
        XCTAssert(NO);
    }];

    [maximumCountSelectionFilter.onContactsDataSourceSelectedContactsAttemptedToExceedMaximumCountSignal addObserver:self callback:^(typeof(self) self, NSOrderedSet<OHContact *> *failedContacts) {
        XCTAssert(NO);
    }];

    XCTestExpectation *noLongerMaximumExpectation = [self expectationWithDescription:@"Data source should have signaled that selected contacts is no longer at maximum count"];
    [maximumCountSelectionFilter.onContactsDataSourceSelectedContactsNoLongerAtMaximumCountSignal addObserver:self callback:^(typeof(self) self) {
        [noLongerMaximumExpectation fulfill];
    }];

    [contactsDataSource deselectContacts:NSOrderedSetMake(contactA)];
    
    [self waitForExpectationsWithTimeout:0.5 handler:nil];
}

- (void)testRepeatedContactSelection
{
    OHContact *contactA = [[OHContact alloc] init];
    OHContact *contactB = [[OHContact alloc] init];

    OHContactsDataSource *contactsDataSource = [[OHContactsDataSource alloc] initWithDataProviders:NSOrderedSetMake(self.contactsDataProvider) postProcessors:nil];
    OHMaximumSelectedCountSelectionFilter *maximumCountSelectionFilter = [[OHMaximumSelectedCountSelectionFilter alloc] initWithDataSource:contactsDataSource maximumSelectedCount:2];
    contactsDataSource.selectionFilters = NSOrderedSetMake(maximumCountSelectionFilter);

    [contactsDataSource selectContacts:NSOrderedSetMake(contactA)];
    [contactsDataSource selectContacts:NSOrderedSetMake(contactB)];

    [maximumCountSelectionFilter.onContactsDataSourceSelectedContactsReachedMaximumCountSignal addObserver:self callback:^(typeof(self) self) {
        XCTAssert(NO);
    }];

    [maximumCountSelectionFilter.onContactsDataSourceSelectedContactsAttemptedToExceedMaximumCountSignal addObserver:self callback:^(typeof(self) self, NSOrderedSet<OHContact *> *failedContacts) {
        XCTAssert(NO);
    }];

    [maximumCountSelectionFilter.onContactsDataSourceSelectedContactsNoLongerAtMaximumCountSignal addObserver:self callback:^(typeof(self) self) {
        XCTAssert(NO);
    }];

    [contactsDataSource selectContacts:NSOrderedSetMake(contactA)];
}

- (id)_createDataProviderMock
{
    id dataProviderMock = OCMStrictProtocolMock(@protocol(OHContactsDataProviderProtocol));
    OCMStub([dataProviderMock status]).andReturn(OHContactsDataProviderStatusInitialized);
    OHContactsDataProviderFinishedLoadingSignal *onContactsDataProviderFinishedLoadingSignal = [[OHContactsDataProviderFinishedLoadingSignal alloc] init];
    OCMStub([dataProviderMock onContactsDataProviderFinishedLoadingSignal]).andReturn(onContactsDataProviderFinishedLoadingSignal);
    OHContactsDataProviderErrorSignal *onContactsDataProviderErrorSignal = [[OHContactsDataProviderErrorSignal alloc] init];
    OCMStub([dataProviderMock onContactsDataProviderErrorSignal]).andReturn(onContactsDataProviderErrorSignal);
    OCMStub([dataProviderMock loadContacts]).andDo(^(NSInvocation *invocation) {
        [dataProviderMock onContactsDataProviderFinishedLoadingSignal].fire(dataProviderMock);
    });
    return dataProviderMock;
}

@end
