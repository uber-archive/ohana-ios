//
//  OHFuzzyMatchingUtilityTests.m
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

#import "NSOrderedSetMake+Internal.h"

@interface OHFuzzyMatchingUtilityTests : XCTestCase

@property (nonatomic) NSOrderedSet<OHContact *> *testContacts;

@end

@implementation OHFuzzyMatchingUtilityTests

- (void)setUp {
    [super setUp];

    OHContact *contactA = [[OHContact alloc] init];
    contactA.fullName = @"Test Contact";
    contactA.contactFields = NSOrderedSetMake([[OHContactField alloc] initWithType:OHContactFieldTypePhoneNumber label:@"mobile" value:@"+1 (555) 123-4567" dataProviderIdentifier:@"test"]);

    OHContact *contactB = [[OHContact alloc] init];
    contactB.fullName = @"Another Test Contact";

    OHContact *contactC = [[OHContact alloc] init];
    contactC.fullName = @"Third Test Contact";

    OHContact *contactD = [[OHContact alloc] init];
    contactD.contactFields = NSOrderedSetMake([[OHContactField alloc] initWithType:OHContactFieldTypeEmailAddress label:@"test" value:@"Low Score Test" dataProviderIdentifier:@"test"],
                                              [[OHContactField alloc] initWithType:OHContactFieldTypeEmailAddress label:@"test" value:@"High Score Test" dataProviderIdentifier:@"test"],
                                              [[OHContactField alloc] initWithType:OHContactFieldTypeEmailAddress label:@"test" value:@"Med Score Test" dataProviderIdentifier:@"test"]);

    self.testContacts = NSOrderedSetMake(contactA, contactB, contactC, contactD);
}

- (void)testFuzzyMatch {
    OHFuzzyMatchingUtility *fuzzyMatchingUtility = [[OHFuzzyMatchingUtility alloc] initWithContacts:self.testContacts];

    NSOrderedSet<OHContact *> *results = [fuzzyMatchingUtility contactsMatchingQuery:@"contact"];
    NSOrderedSet<OHContact *> *expectedResults = NSOrderedSetMake(self.testContacts[0], self.testContacts[1], self.testContacts[2]);

    XCTAssert([results isEqualToOrderedSet:expectedResults]);
}

- (void)testFuzzyMatchBlank {
    OHFuzzyMatchingUtility *fuzzyMatchingUtility = [[OHFuzzyMatchingUtility alloc] initWithContacts:self.testContacts];

    NSOrderedSet<OHContact *> *results = [fuzzyMatchingUtility contactsMatchingQuery:@""];

    XCTAssertEqual(results.count, 0);
}

- (void)testFuzzyMatchPhoneNumber
{
    OHFuzzyMatchingUtility *fuzzyMatchingUtility = [[OHFuzzyMatchingUtility alloc] initWithContacts:self.testContacts];

    NSOrderedSet<OHContact *> *results = [fuzzyMatchingUtility contactsMatchingQuery:@"5551357"];
    NSOrderedSet<OHContact *> *expectedResults = NSOrderedSetMake(self.testContacts[0]);

    XCTAssert([results isEqualToOrderedSet:expectedResults]);
}

- (void)testFuzzyMatchScoring
{
    OHFuzzyMatchingUtility *fuzzyMatchingUtility = [[OHFuzzyMatchingUtility alloc] initWithContacts:self.testContacts];

    NSString *queryString = @"test";

    fuzzyMatchingUtility.scoringBlock = ^NSInteger (NSString *query, NSString *nominee) {
        XCTAssert([query isEqualToString:queryString]);

        if ([nominee isEqualToString:@"Test Contact"]) {
            return 3;
        } else if ([nominee isEqualToString:@"+1 (555) 123-4567"]) {
            // This doesn't match the query string
            XCTAssert(NO);
        } else if ([nominee isEqualToString:@"Another Test Contact"]) {
            return 0;
        } else if ([nominee isEqualToString:@"Third Test Contact"]) {
            return 50;
        } else if ([nominee isEqualToString:@"Low Score Test"]) {
            return -10;
        } else if ([nominee isEqualToString:@"Med Score Test"]) {
            return 20;
        } else if ([nominee isEqualToString:@"High Score Test"]) {
            return 75;
        } else {
            // An invalid nominee string was passed
            XCTAssert(NO);
        }
    };

    NSOrderedSet<OHContact *> *results = [fuzzyMatchingUtility contactsMatchingQuery:queryString];
    NSOrderedSet<OHContact *> *expectedResults = NSOrderedSetMake(self.testContacts[3], self.testContacts[2], self.testContacts[0], self.testContacts[1]);

    XCTAssert([results isEqualToOrderedSet:expectedResults]);
}

@end
