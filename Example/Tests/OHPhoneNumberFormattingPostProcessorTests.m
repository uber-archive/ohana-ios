//
//  OHPhoneNumberFormattingPostProcessorTests.m
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

@interface OHPhoneNumberFormattingPostProcessor ()

- (NSString *)_countryCode;

@end

@interface OHPhoneNumberFormattingPostProcessorTests : XCTestCase

@end

@implementation OHPhoneNumberFormattingPostProcessorTests

- (void)setUp
{
    [super setUp];


}

- (void)testFormatting
{
    OHContact *contact = [[OHContact alloc] init];
    contact.contactFields = NSOrderedSetMake([[OHContactField alloc] initWithType:OHContactFieldTypePhoneNumber
                                                                             label:@"test"
                                                                             value:@"555-5555555"
                                                            dataProviderIdentifier:@"test"]);

    id postProcessor = OCMPartialMock([[OHPhoneNumberFormattingPostProcessor alloc] initWithFormats:OHPhoneNumberFormatE164|OHPhoneNumberFormatInternational|OHPhoneNumberFormatNational|OHPhoneNumberFormatRFC3966]);
    OCMStub([postProcessor _countryCode]).andReturn(@"US");
    [postProcessor processContacts:NSOrderedSetMake(contact)];

    id formattedE164 = [[contact.contactFields objectAtIndex:0].customProperties objectForKey:kOHFormattedPhoneNumberE164];
    XCTAssertNotNil(formattedE164);
    XCTAssert([formattedE164 isKindOfClass:[NSString class]]);
    XCTAssert([formattedE164 isEqualToString:@"+15555555555"]);

    id formattedInternational = [[contact.contactFields objectAtIndex:0].customProperties objectForKey:kOHFormattedPhoneNumberInternational];
    XCTAssertNotNil(formattedInternational);
    XCTAssert([formattedInternational isKindOfClass:[NSString class]]);
    XCTAssert([formattedInternational isEqualToString:@"+1 555-555-5555"]);

    id formattedNational = [[contact.contactFields objectAtIndex:0].customProperties objectForKey:kOHFormattedPhoneNumberNational];
    XCTAssertNotNil(formattedNational);
    XCTAssert([formattedNational isKindOfClass:[NSString class]]);
    XCTAssert([formattedNational isEqualToString:@"(555) 555-5555"]);

    id formattedRFC3966 = [[contact.contactFields objectAtIndex:0].customProperties objectForKey:kOHFormattedPhoneNumberRFC3966];
    XCTAssertNotNil(formattedRFC3966);
    XCTAssert([formattedRFC3966 isKindOfClass:[NSString class]]);
    XCTAssert([formattedRFC3966 isEqualToString:@"tel:+1-555-555-5555"]);
}

- (void)testFormattingLimited
{
    OHContact *contact = [[OHContact alloc] init];
    contact.contactFields = NSOrderedSetMake([[OHContactField alloc] initWithType:OHContactFieldTypePhoneNumber
                                                                            label:@"test"
                                                                            value:@"555-5555555"
                                                           dataProviderIdentifier:@"test"]);

    id postProcessor = OCMPartialMock([[OHPhoneNumberFormattingPostProcessor alloc] initWithFormats:OHPhoneNumberFormatE164|OHPhoneNumberFormatNational]);
    OCMStub([postProcessor _countryCode]).andReturn(@"US");
    [postProcessor processContacts:NSOrderedSetMake(contact)];

    id formattedE164 = [[contact.contactFields objectAtIndex:0].customProperties objectForKey:kOHFormattedPhoneNumberE164];
    XCTAssertNotNil(formattedE164);

    id formattedInternational = [[contact.contactFields objectAtIndex:0].customProperties objectForKey:kOHFormattedPhoneNumberInternational];
    XCTAssertNil(formattedInternational);

    id formattedNational = [[contact.contactFields objectAtIndex:0].customProperties objectForKey:kOHFormattedPhoneNumberNational];
    XCTAssertNotNil(formattedNational);

    id formattedRFC3966 = [[contact.contactFields objectAtIndex:0].customProperties objectForKey:kOHFormattedPhoneNumberRFC3966];
    XCTAssertNil(formattedRFC3966);
}

@end
