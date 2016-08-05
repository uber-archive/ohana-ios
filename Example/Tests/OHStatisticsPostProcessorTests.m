//
//  OHStatisticsPostProcessorTests.m
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

@interface OHStatisticsPostProcessorTests : XCTestCase

@end

@implementation OHStatisticsPostProcessorTests

- (void)testStatisticsGeneration
{
    OHContact *contactA = [[OHContact alloc] init];
    contactA.contactFields = NSOrderedSetMake([[OHContactField alloc] initWithType:OHContactFieldTypePhoneNumber label:@"home" value:@"" dataProviderIdentifier:@"test"],
                                              [[OHContactField alloc] initWithType:OHContactFieldTypeEmailAddress label:@"home" value:@"" dataProviderIdentifier:@"test"],
                                              [[OHContactField alloc] initWithType:OHContactFieldTypePhoneNumber label:@"other" value:@"" dataProviderIdentifier:@"test"]);

    OHContact *contactB = [[OHContact alloc] init];
    contactB.contactFields = NSOrderedSetMake([[OHContactField alloc] initWithType:OHContactFieldTypePhoneNumber label:@"mobile" value:@"" dataProviderIdentifier:@"test"]);

    id<OHContactsDataProviderProtocol> mockDataProvider = [self _createDataProviderMock];
    NSOrderedSet<OHContact *> *contacts = NSOrderedSetMake(contactA, contactB);
    OCMStub([mockDataProvider contacts]).andReturn(contacts);

    OHStatisticsPostProcessor *postProcessor = [[OHStatisticsPostProcessor alloc] init];

    OHContactsDataSource *dataSource = [[OHContactsDataSource alloc] initWithDataProviders:NSOrderedSetMake(mockDataProvider) postProcessors:NSOrderedSetMake(postProcessor)];
    [dataSource loadContacts];

    XCTAssert([[contactA.customProperties objectForKey:kOHStatisticsNumberOfContactFields] isEqualToNumber:@(3)]);
    XCTAssert([[contactA.customProperties objectForKey:kOHStatisticsNumberOfPhoneNumbers] isEqualToNumber:@(2)]);
    XCTAssert([[contactA.customProperties objectForKey:kOHStatisticsNumberOfEmailAddresses] isEqualToNumber:@(1)]);
    XCTAssert([[contactA.customProperties objectForKey:kOHStatisticsHasMobilePhoneNumber] isEqualToNumber:@(NO)]);

    XCTAssert([[contactB.customProperties objectForKey:kOHStatisticsNumberOfContactFields] isEqualToNumber:@(1)]);
    XCTAssert([[contactB.customProperties objectForKey:kOHStatisticsNumberOfPhoneNumbers] isEqualToNumber:@(1)]);
    XCTAssert([[contactB.customProperties objectForKey:kOHStatisticsNumberOfEmailAddresses] isEqualToNumber:@(0)]);
    XCTAssert([[contactB.customProperties objectForKey:kOHStatisticsHasMobilePhoneNumber] isEqualToNumber:@(YES)]);
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
