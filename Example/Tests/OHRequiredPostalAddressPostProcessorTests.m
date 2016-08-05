//
//  OHRequiredPostalAddressPostProcessorTests.m
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

@interface OHRequiredPostalAddressPostProcessorTests : XCTestCase

@end

@implementation OHRequiredPostalAddressPostProcessorTests

- (void)testRequiredPostalAddress
{
    OHContact *contactA = [[OHContact alloc] init];
    contactA.postalAddresses = NSOrderedSetMake([[OHContactAddress alloc] initWithLabel:@"home" street:@"" city:@"" state:@"" postalCode:@"" country:@"" dataProviderIdentifier:@"test"]);

    OHContact *contactB = [[OHContact alloc] init];
    contactB.postalAddresses = [NSOrderedSet orderedSet];

    OHContact *contactC = [[OHContact alloc] init];

    NSOrderedSet *inputContacts = NSOrderedSetMake(contactA, contactB, contactC);

    OHRequiredPostalAddressPostProcessor *addressRequiredProcessor = [[OHRequiredPostalAddressPostProcessor alloc] init];
    NSOrderedSet<OHContact *> *result = [addressRequiredProcessor processContacts:inputContacts];
    XCTAssertTrue([result containsObject:contactA]);
    XCTAssertFalse([result containsObject:contactB]);
    XCTAssertFalse([result containsObject:contactC]);
}

@end