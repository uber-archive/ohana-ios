//
//  OHContactsDataSourceTests.m
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

@interface OHContactsDataSourceTests : XCTestCase

@property (nonatomic) id dataProviderMock;
@property (nonatomic) OHAlphabeticalSortPostProcessor *alphabeticalSortPostProcessor;
@property (nonatomic) OHRequiredFieldPostProcessor *requiredPhonePostProcessor;

@end

@implementation OHContactsDataSourceTests

- (void)setUp
{
    [super setUp];

    _dataProviderMock = [self _createDataProviderMock];

    _alphabeticalSortPostProcessor = [[OHAlphabeticalSortPostProcessor alloc] initWithSortMode:OHAlphabeticalSortPostProcessorSortModeFullName];
    _requiredPhonePostProcessor = [[OHRequiredFieldPostProcessor alloc] initWithFieldType:OHContactFieldTypePhoneNumber];
}

- (void)testBaseInitialization
{
    OHContactsDataSource *dataSource = [[OHContactsDataSource alloc] initWithDataProviders:NSOrderedSetMake(self.dataProviderMock)
                                                                            postProcessors:NSOrderedSetMake(self.alphabeticalSortPostProcessor, self.requiredPhonePostProcessor)];

    NSOrderedSet *expectedDataProviders = NSOrderedSetMake(self.dataProviderMock);
    XCTAssert([dataSource.dataProviders isEqualToOrderedSet:expectedDataProviders]);

    NSOrderedSet *expectedPostProcessors = NSOrderedSetMake(self.alphabeticalSortPostProcessor, self.requiredPhonePostProcessor);
    XCTAssert([dataSource.postProcessors isEqualToOrderedSet:expectedPostProcessors]);

    XCTAssertNil(dataSource.selectionFilters);

    XCTAssertNotNil(dataSource.onContactsDataSourceLoadedProvidersSignal);
    XCTAssertNotNil(dataSource.onContactsDataSourcePostProcessorsFinishedSignal);
    XCTAssertNotNil(dataSource.onContactsDataSourceReadySignal);
    XCTAssertNotNil(dataSource.onContactsDataSourceSelectedContactsSignal);
    XCTAssertNotNil(dataSource.onContactsDataSourceDeselectedContactsSignal);

    XCTAssertNil(dataSource.contacts);
    XCTAssertEqual(dataSource.selectedContacts.count, 0);
}

- (void)testSelection
{
    OHContactsDataSource *dataSource = [[OHContactsDataSource alloc] initWithDataProviders:NSOrderedSetMake(self.dataProviderMock) postProcessors:nil];

    OHContact *contact = [[OHContact alloc] init];

    XCTestExpectation *signalExpectation = [self expectationWithDescription:@"Selected contacts signal should have fired"];
    [dataSource.onContactsDataSourceSelectedContactsSignal addObserver:self callback:^(typeof(self) self, NSOrderedSet<OHContact *> * _Nonnull selectedContacts) {
        NSOrderedSet *expectedSelectedContacts = NSOrderedSetMake(contact);
        XCTAssert([selectedContacts isEqualToOrderedSet:expectedSelectedContacts]);
        [signalExpectation fulfill];
    }];

    [dataSource selectContacts:NSOrderedSetMake(contact)];

    NSOrderedSet *expectedSelectedContacts = NSOrderedSetMake(contact);
    XCTAssert([dataSource.selectedContacts isEqualToOrderedSet:expectedSelectedContacts]);

    [self waitForExpectationsWithTimeout:0.1 handler:nil];
}

- (void)testRepeatSelection
{
    OHContactsDataSource *dataSource = [[OHContactsDataSource alloc] initWithDataProviders:NSOrderedSetMake(self.dataProviderMock) postProcessors:nil];

    OHContact *contact = [[OHContact alloc] init];
    [dataSource selectContacts:NSOrderedSetMake(contact)];

    [dataSource.onContactsDataSourceSelectedContactsSignal addObserver:self callback:^(typeof(self) self, NSOrderedSet<OHContact *> * _Nonnull selectedContacts) {
        XCTAssert(NO);
    }];

    [dataSource selectContacts:NSOrderedSetMake(contact)];

    NSOrderedSet *expectedSelectedContacts = NSOrderedSetMake(contact);
    XCTAssert([dataSource.selectedContacts isEqualToOrderedSet:expectedSelectedContacts]);
}

- (void)testSelectionWithPositiveFilter
{
    OHContact *contact = [[OHContact alloc] init];

    id selectionFilter = [self _createSelectionFilterMockWithContacts:NSOrderedSetMake(contact)];

    OHContactsDataSource *dataSource = [[OHContactsDataSource alloc] initWithDataProviders:NSOrderedSetMake(self.dataProviderMock)
                                                                            postProcessors:nil
                                                                          selectionFilters:NSOrderedSetMake(selectionFilter)];

    XCTestExpectation *signalExpectation = [self expectationWithDescription:@"Selected contacts signal should have fired"];
    [dataSource.onContactsDataSourceSelectedContactsSignal addObserver:self callback:^(typeof(self) self, NSOrderedSet<OHContact *> * _Nonnull selectedContacts) {
        NSOrderedSet *expectedSelectedContacts = NSOrderedSetMake(contact);
        XCTAssert([selectedContacts isEqualToOrderedSet:expectedSelectedContacts]);
        [signalExpectation fulfill];
    }];

    [dataSource selectContacts:NSOrderedSetMake(contact)];

    NSOrderedSet *expectedSelectedContacts = NSOrderedSetMake(contact);
    XCTAssert([dataSource.selectedContacts isEqualToOrderedSet:expectedSelectedContacts]);

    [self waitForExpectationsWithTimeout:0.1 handler:nil];
}

- (void)testSelectionWithNegativeFilter
{
    OHContact *contact = [[OHContact alloc] init];

    id selectionFilter = [self _createSelectionFilterMockWithContacts:[NSOrderedSet orderedSet]];

    OHContactsDataSource *dataSource = [[OHContactsDataSource alloc] initWithDataProviders:NSOrderedSetMake(self.dataProviderMock)
                                                                            postProcessors:nil
                                                                          selectionFilters:NSOrderedSetMake(selectionFilter)];

    [dataSource.onContactsDataSourceSelectedContactsSignal addObserver:self callback:^(typeof(self) self, NSOrderedSet<OHContact *> * _Nonnull selectedContacts) {
        XCTAssert(NO);
    }];

    [dataSource selectContacts:NSOrderedSetMake(contact)];

    NSOrderedSet *expectedSelectedContacts = [NSOrderedSet orderedSet];
    XCTAssert([dataSource.selectedContacts isEqualToOrderedSet:expectedSelectedContacts]);
}

- (void)testDeselection
{
    OHContactsDataSource *dataSource = [[OHContactsDataSource alloc] initWithDataProviders:NSOrderedSetMake(self.dataProviderMock) postProcessors:nil];

    OHContact *contact = [[OHContact alloc] init];
    [dataSource selectContacts:NSOrderedSetMake(contact)];

    XCTestExpectation *signalExpectation = [self expectationWithDescription:@"Deselected contacts signal should have fired"];
    [dataSource.onContactsDataSourceDeselectedContactsSignal addObserver:self callback:^(typeof(self) self, NSOrderedSet<OHContact *> * _Nonnull deselectedContacts) {
        NSOrderedSet *expectedDeselectedContacts = NSOrderedSetMake(contact);
        XCTAssert([deselectedContacts isEqualToOrderedSet:expectedDeselectedContacts]);
        [signalExpectation fulfill];
    }];

    [dataSource deselectContacts:NSOrderedSetMake(contact)];

    NSOrderedSet *expectedSelectedContacts = [NSOrderedSet orderedSet];
    XCTAssert([dataSource.selectedContacts isEqualToOrderedSet:expectedSelectedContacts]);

    [self waitForExpectationsWithTimeout:0.1 handler:nil];
}

- (void)testUnselectedDeselection
{
    OHContactsDataSource *dataSource = [[OHContactsDataSource alloc] initWithDataProviders:NSOrderedSetMake(self.dataProviderMock) postProcessors:nil];

    OHContact *contact = [[OHContact alloc] init];

    [dataSource.onContactsDataSourceDeselectedContactsSignal addObserver:self callback:^(typeof(self) self, NSOrderedSet<OHContact *> * _Nonnull deselectedContacts) {
        XCTAssert(NO);
    }];

    [dataSource deselectContacts:NSOrderedSetMake(contact)];

    NSOrderedSet *expectedSelectedContacts = [NSOrderedSet orderedSet];
    XCTAssert([dataSource.selectedContacts isEqualToOrderedSet:expectedSelectedContacts]);
}

- (void)testDeselectionWithPositiveFilter
{
    OHContact *contact = [[OHContact alloc] init];

    id selectionFilter = [self _createSelectionFilterMockWithContacts:NSOrderedSetMake(contact)];

    OHContactsDataSource *dataSource = [[OHContactsDataSource alloc] initWithDataProviders:NSOrderedSetMake(self.dataProviderMock)
                                                                            postProcessors:nil
                                                                          selectionFilters:NSOrderedSetMake(selectionFilter)];

    [dataSource selectContacts:NSOrderedSetMake(contact)];

    XCTestExpectation *signalExpectation = [self expectationWithDescription:@"Deselected contacts signal should have fired"];
    [dataSource.onContactsDataSourceDeselectedContactsSignal addObserver:self callback:^(typeof(self) self, NSOrderedSet<OHContact *> * _Nonnull deselectedContacts) {
        NSOrderedSet *expectedDeselectedContacts = NSOrderedSetMake(contact);
        XCTAssert([deselectedContacts isEqualToOrderedSet:expectedDeselectedContacts]);
        [signalExpectation fulfill];
    }];

    [dataSource deselectContacts:NSOrderedSetMake(contact)];

    NSOrderedSet *expectedSelectedContacts = [NSOrderedSet orderedSet];
    XCTAssert([dataSource.selectedContacts isEqualToOrderedSet:expectedSelectedContacts]);

    [self waitForExpectationsWithTimeout:0.1 handler:nil];
}

- (void)testDeselectionWithNegativeFilter
{
    OHContact *contact = [[OHContact alloc] init];

    OHContactsDataSource *dataSource = [[OHContactsDataSource alloc] initWithDataProviders:NSOrderedSetMake(self.dataProviderMock) postProcessors:nil];

    [dataSource selectContacts:NSOrderedSetMake(contact)];

    id selectionFilter = [self _createSelectionFilterMockWithContacts:[NSOrderedSet orderedSet]];
    dataSource.selectionFilters = NSOrderedSetMake(selectionFilter);

    [dataSource.onContactsDataSourceDeselectedContactsSignal addObserver:self callback:^(typeof(self) self, NSOrderedSet<OHContact *> * _Nonnull deselectedContacts) {
        XCTAssert(NO);
    }];

    [dataSource deselectContacts:NSOrderedSetMake(contact)];

    NSOrderedSet *expectedSelectedContacts = NSOrderedSetMake(contact);
    XCTAssert([dataSource.selectedContacts isEqualToOrderedSet:expectedSelectedContacts]);
}

- (void)testLoadContacts
{
    OHContactsDataSource *dataSource = [[OHContactsDataSource alloc] initWithDataProviders:NSOrderedSetMake(self.dataProviderMock) postProcessors:nil];

    NSOrderedSet *contacts = NSOrderedSetMake([[OHContact alloc] init], [[OHContact alloc] init]);
    OCMStub([self.dataProviderMock contacts]).andReturn(contacts);

    XCTestExpectation *onLoadedProvidersExpectation = [self expectationWithDescription:@"Data source loaded providers signal should have fired"];
    [dataSource.onContactsDataSourceLoadedProvidersSignal addObserver:self callback:^(typeof(self) self) {
        [onLoadedProvidersExpectation fulfill];
    }];

    [dataSource.onContactsDataSourcePostProcessorsFinishedSignal addObserver:self callback:^(typeof(self) self) {
        XCTAssert(NO);
    }];

    XCTestExpectation *onReadyExpectation = [self expectationWithDescription:@"Data source ready signal should have fired"];
    [dataSource.onContactsDataSourceReadySignal addObserver:self callback:^(typeof(self) self) {
        XCTAssert([dataSource.contacts isEqualToOrderedSet:contacts]);
        [onReadyExpectation fulfill];
    }];

    [dataSource loadContacts];

    [self waitForExpectationsWithTimeout:0.1 handler:nil];
}

- (void)testLoadContactsWithPostProcessor
{
    NSOrderedSet *contacts = NSOrderedSetMake([[OHContact alloc] init], [[OHContact alloc] init]);
    OCMStub([self.dataProviderMock contacts]).andReturn(contacts);

    id postProcessorMock = [self _createPostProcessorMockWithContacts:contacts];

    XCTestExpectation *postProcessorFinishedExpectation = [self expectationWithDescription:@"Post processor finished signal should have fired"];
    [[postProcessorMock onContactsPostProcessorFinishedSignal] addObserver:self callback:^(typeof(self) self, NSOrderedSet<OHContact *> * _Nonnull processedContacts, id<OHContactsPostProcessorProtocol>  _Nonnull postProcessor) {
        XCTAssert([processedContacts isEqualToOrderedSet:contacts]);
        [postProcessorFinishedExpectation fulfill];
    }];

    OHContactsDataSource *dataSource = [[OHContactsDataSource alloc] initWithDataProviders:NSOrderedSetMake(self.dataProviderMock)
                                                                            postProcessors:NSOrderedSetMake(postProcessorMock)];

    XCTestExpectation *onLoadedProvidersExpectation = [self expectationWithDescription:@"Data source loaded providers signal should have fired"];
    [dataSource.onContactsDataSourceLoadedProvidersSignal addObserver:self callback:^(typeof(self) self) {
        [onLoadedProvidersExpectation fulfill];
    }];

    XCTestExpectation *onPostProcessorsFinishedSignal = [self expectationWithDescription:@"Post processors finished signal should have fired"];
    [dataSource.onContactsDataSourcePostProcessorsFinishedSignal addObserver:self callback:^(typeof(self) self) {
        [onPostProcessorsFinishedSignal fulfill];
    }];

    XCTestExpectation *onReadyExpectation = [self expectationWithDescription:@"Data source ready signal should have fired"];
    [dataSource.onContactsDataSourceReadySignal addObserver:self callback:^(typeof(self) self) {
        XCTAssert([dataSource.contacts isEqualToOrderedSet:contacts]);
        [onReadyExpectation fulfill];
    }];

    [dataSource loadContacts];

    [self waitForExpectationsWithTimeout:0.1 handler:nil];
}

- (void)testContactFiltering
{
    OHContact *contactA = [[OHContact alloc] init];
    OHContact *contactB = [[OHContact alloc] init];
    NSOrderedSet<OHContact *> *contacts = NSOrderedSetMake(contactA, contactB);

    OCMStub([self.dataProviderMock contacts]).andReturn(contacts);

    OHContactsDataSource *dataSource = [[OHContactsDataSource alloc] initWithDataProviders:NSOrderedSetMake(self.dataProviderMock) postProcessors:nil];
    [dataSource loadContacts];

    XCTAssert([[dataSource contactsPassingFilter:^BOOL(OHContact * _Nonnull contact) {
        return YES;
    }] isEqualToOrderedSet:contacts]);

    XCTAssert([[dataSource contactsPassingFilter:^BOOL(OHContact * _Nonnull contact) {
        return NO;
    }] isEqualToOrderedSet:[NSOrderedSet orderedSet]]);

    NSOrderedSet<OHContact *> *expectedContacts = NSOrderedSetMake(contactB);
    XCTAssert([[dataSource contactsPassingFilter:^BOOL(OHContact * _Nonnull contact) {
        return contact == contactB;
    }] isEqualToOrderedSet:expectedContacts]);

}

#pragma mark - Private Helpers

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

- (id)_createPostProcessorMockWithContacts:(NSOrderedSet<OHContact *> *)contacts
{
    id postProcessorMock = OCMStrictProtocolMock(@protocol(OHContactsPostProcessorProtocol));
    OHContactsPostProcessorFinishedSignal *onContactsPostProcessorFinishedSignal = [[OHContactsPostProcessorFinishedSignal alloc] init];
    OCMStub([postProcessorMock onContactsPostProcessorFinishedSignal]).andReturn(onContactsPostProcessorFinishedSignal);
    OCMStub([postProcessorMock processContacts:[OCMArg checkWithBlock:^BOOL(id obj) {
        [postProcessorMock onContactsPostProcessorFinishedSignal].fire(obj, postProcessorMock);
        return YES;
    }]]).andReturn(contacts);
    return postProcessorMock;
}

- (id)_createSelectionFilterMockWithContacts:(NSOrderedSet<OHContact *> *)contacts
{
    id selectionFilterMock = OCMStrictProtocolMock(@protocol(OHContactsSelectionFilterProtocol));
    OCMStub([selectionFilterMock filterContactsForSelection:OCMOCK_ANY]).andReturn(contacts);
    OCMStub([selectionFilterMock filterContactsForDeselection:OCMOCK_ANY]).andReturn(contacts);
    return selectionFilterMock;
}

@end
