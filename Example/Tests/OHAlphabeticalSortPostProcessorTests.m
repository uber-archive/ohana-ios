//
//  OHAlphabeticalSortPostProcessorTests.m
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

@interface OHAlphabeticalSortPostProcessorTests : XCTestCase

@property (nonatomic) OHContact *contactA;
@property (nonatomic) OHContact *contactB;
@property (nonatomic) OHContact *contactC;
@property (nonatomic) OHContact *contactD;

@property (nonatomic) OHContact *contactAA;
@property (nonatomic) OHContact *contactAB;
@property (nonatomic) OHContact *contactAC;
@property (nonatomic) OHContact *contactBA;
@property (nonatomic) OHContact *contactCA;

@end

@implementation OHAlphabeticalSortPostProcessorTests

- (void)setUp
{
    [super setUp];
    
    self.contactA = [[OHContact alloc] init];
    self.contactA.fullName = @"A";
    self.contactA.firstName = @"B";
    self.contactA.lastName = @"C";

    self.contactB = [[OHContact alloc] init];
    self.contactB.fullName = @"B";
    self.contactB.firstName = @"C";
    self.contactB.lastName = @"A";

    self.contactC = [[OHContact alloc] init];
    self.contactC.fullName = @"C";
    self.contactC.firstName = @"A";
    self.contactC.lastName = @"B";

    self.contactD = [[OHContact alloc] init];
    
    self.contactAA = [[OHContact alloc] init];
    self.contactAA.firstName = @"A";
    self.contactAA.lastName = @"A";
    
    self.contactAB = [[OHContact alloc] init];
    self.contactAB.firstName = @"A";
    self.contactAB.lastName = @"B";
    
    self.contactAC = [[OHContact alloc] init];
    self.contactAC.firstName = @"A";
    self.contactAC.lastName = @"C";
    
    self.contactBA = [[OHContact alloc] init];
    self.contactBA.firstName = @"B";
    self.contactBA.lastName = @"A";
    
    self.contactCA = [[OHContact alloc] init];
    self.contactCA.firstName = @"C";
    self.contactCA.lastName = @"A";
}

- (void)testSortContactsByFullName
{
    OHAlphabeticalSortPostProcessor *postProcessor = [[OHAlphabeticalSortPostProcessor alloc] initWithSortMode:OHAlphabeticalSortPostProcessorSortModeFullName];
    NSOrderedSet<OHContact *> *result = [postProcessor processContacts:NSOrderedSetMake(self.contactD, self.contactB, self.contactA, self.contactC)];
    NSOrderedSet<OHContact *> *expectedResult = NSOrderedSetMake(self.contactA, self.contactB, self.contactC, self.contactD);
    XCTAssert([result isEqualToOrderedSet:expectedResult]);
}

- (void)testSortContactsByFirstName
{
    OHAlphabeticalSortPostProcessor *postProcessor = [[OHAlphabeticalSortPostProcessor alloc] initWithSortMode:OHAlphabeticalSortPostProcessorSortModeFirstName];
    NSOrderedSet<OHContact *> *result = [postProcessor processContacts:NSOrderedSetMake(self.contactD, self.contactB, self.contactA, self.contactC)];
    NSOrderedSet<OHContact *> *expectedResult = NSOrderedSetMake(self.contactC, self.contactA, self.contactB, self.contactD);
    XCTAssert([result isEqualToOrderedSet:expectedResult]);
}

- (void)testSortContactsByLastName
{
    OHAlphabeticalSortPostProcessor *postProcessor = [[OHAlphabeticalSortPostProcessor alloc] initWithSortMode:OHAlphabeticalSortPostProcessorSortModeLastName];
    NSOrderedSet<OHContact *> *result = [postProcessor processContacts:NSOrderedSetMake(self.contactD, self.contactB, self.contactA, self.contactC)];
    NSOrderedSet<OHContact *> *expectedResult = NSOrderedSetMake(self.contactB, self.contactC, self.contactA, self.contactD);
    XCTAssert([result isEqualToOrderedSet:expectedResult]);
}

- (void)testSortContactsByFirstNameSecondarySort
{
    OHAlphabeticalSortPostProcessor *postProcessor = [[OHAlphabeticalSortPostProcessor alloc] initWithSortMode:OHAlphabeticalSortPostProcessorSortModeFirstName];
    NSOrderedSet<OHContact *> *result = [postProcessor processContacts:NSOrderedSetMake(self.contactAC, self.contactAA, self.contactAB)];
    NSOrderedSet<OHContact *> *expectedResult = NSOrderedSetMake(self.contactAA, self.contactAB, self.contactAC);
    XCTAssert([result isEqualToOrderedSet:expectedResult]);
}

- (void)testSortContactsByLastNameSecondarySort
{
    OHAlphabeticalSortPostProcessor *postProcessor = [[OHAlphabeticalSortPostProcessor alloc] initWithSortMode:OHAlphabeticalSortPostProcessorSortModeLastName];
    NSOrderedSet<OHContact *> *result = [postProcessor processContacts:NSOrderedSetMake(self.contactCA, self.contactAA, self.contactBA)];
    NSOrderedSet<OHContact *> *expectedResult = NSOrderedSetMake(self.contactAA, self.contactBA, self.contactCA);
    XCTAssert([result isEqualToOrderedSet:expectedResult]);
}

- (void)testSignalFire
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Post processor should fire finished signal"];
    OHAlphabeticalSortPostProcessor *postProcessor = [[OHAlphabeticalSortPostProcessor alloc] initWithSortMode:OHAlphabeticalSortPostProcessorSortModeFullName];
    [postProcessor.onContactsPostProcessorFinishedSignal addObserver:self callback:^(typeof(self) self, NSOrderedSet<OHContact *> * _Nonnull processedContacts, id<OHContactsPostProcessorProtocol>  _Nonnull postProcessor) {
        [expectation fulfill];
    }];

    [postProcessor processContacts:[NSOrderedSet orderedSet]];

    [self waitForExpectationsWithTimeout:0.1 handler:nil];
}

@end
