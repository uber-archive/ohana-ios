//
//  OHSplitOnFieldTypePostProcessorTests.m
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

@interface OHSplitOnFieldTypePostProcessorTests : XCTestCase

@property (nonatomic) NSOrderedSet<OHContact *> *testContacts;

@end

@implementation OHSplitOnFieldTypePostProcessorTests

- (void)setUp
{
    [super setUp];

    OHContact *emailPhoneContact = [[OHContact alloc] init];
    emailPhoneContact.fullName = @"email and phone contact";
    emailPhoneContact.contactFields = NSOrderedSetMake([[OHContactField alloc] initWithType:OHContactFieldTypePhoneNumber label:@"phone 1" value:@"1234" dataProviderIdentifier:@"test"],
                                                       [[OHContactField alloc] initWithType:OHContactFieldTypePhoneNumber label:@"phone 2" value:@"5678" dataProviderIdentifier:@"test"],
                                                       [[OHContactField alloc] initWithType:OHContactFieldTypeEmailAddress label:@"email 1" value:@"a@b.com" dataProviderIdentifier:@"test"],
                                                       [[OHContactField alloc] initWithType:OHContactFieldTypeEmailAddress label:@"email 2" value:@"c@d.com" dataProviderIdentifier:@"test"]);


    OHContact *emailContact = [[OHContact alloc] init];
    emailContact.fullName = @"email contact";
    emailContact.contactFields = NSOrderedSetMake([[OHContactField alloc] initWithType:OHContactFieldTypeEmailAddress label:@"email 3" value:@"e@f.com" dataProviderIdentifier:@"test"],
                                                  [[OHContactField alloc] initWithType:OHContactFieldTypeEmailAddress label:@"email 4" value:@"g@h.com" dataProviderIdentifier:@"test"]);

    OHContact *phoneContact = [[OHContact alloc] init];
    phoneContact.fullName = @"phone contact";
    phoneContact.contactFields = NSOrderedSetMake([[OHContactField alloc] initWithType:OHContactFieldTypePhoneNumber label:@"phone 2" value:@"9101112" dataProviderIdentifier:@"test"],
                                                  [[OHContactField alloc] initWithType:OHContactFieldTypePhoneNumber label:@"phone 3" value:@"13141516" dataProviderIdentifier:@"test"]);

    self.testContacts = NSOrderedSetMake(emailPhoneContact, emailContact, phoneContact);
}

- (void)testPhoneSplit
{
    OHSplitOnFieldTypePostProcessor *postProcessor = [[OHSplitOnFieldTypePostProcessor alloc] initWithFieldType:OHContactFieldTypePhoneNumber];
    NSOrderedSet<OHContact *> *results = [postProcessor processContacts:self.testContacts];
    XCTAssertEqual(results.count, (NSUInteger)4);

    XCTAssertEqual(results[0].fullName, self.testContacts[0].fullName);
    XCTAssertEqual(results[0].contactFields[0], self.testContacts[0].contactFields[0]);

    XCTAssertEqual(results[1].fullName, self.testContacts[0].fullName);
    XCTAssertEqual(results[1].contactFields[0], self.testContacts[0].contactFields[1]);

    XCTAssertEqual(results[2].fullName, self.testContacts[2].fullName);
    XCTAssertEqual(results[2].contactFields[0], self.testContacts[2].contactFields[0]);

    XCTAssertEqual(results[3].fullName, self.testContacts[2].fullName);
    XCTAssertEqual(results[3].contactFields[0], self.testContacts[2].contactFields[1]);
}

- (void)testEmailSplit
{
    OHSplitOnFieldTypePostProcessor *postProcessor = [[OHSplitOnFieldTypePostProcessor alloc] initWithFieldType:OHContactFieldTypeEmailAddress];
    NSOrderedSet<OHContact *> *results = [postProcessor processContacts:self.testContacts];
    XCTAssertEqual(results.count, (NSUInteger)4);

    XCTAssertEqual(results[0].fullName, self.testContacts[0].fullName);
    XCTAssertEqual(results[0].contactFields[0], self.testContacts[0].contactFields[2]);

    XCTAssertEqual(results[1].fullName, self.testContacts[0].fullName);
    XCTAssertEqual(results[1].contactFields[0], self.testContacts[0].contactFields[3]);

    XCTAssertEqual(results[2].fullName, self.testContacts[1].fullName);
    XCTAssertEqual(results[2].contactFields[0], self.testContacts[1].contactFields[0]);

    XCTAssertEqual(results[3].fullName, self.testContacts[1].fullName);
    XCTAssertEqual(results[3].contactFields[0], self.testContacts[1].contactFields[1]);
}

- (void)testNoSplit
{
    OHSplitOnFieldTypePostProcessor *postProcessor = [[OHSplitOnFieldTypePostProcessor alloc] initWithFieldType:OHContactFieldTypeOther];
    NSOrderedSet<OHContact *> *results = [postProcessor processContacts:self.testContacts];
    XCTAssertEqual(results.count, (NSUInteger)0);
}

@end
