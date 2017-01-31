//
//  OHContactTests.m
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

@interface OHContactTests : XCTestCase

@property (nonatomic) OHContact *contact;

@end

@implementation OHContactTests

- (void)setUp
{
    self.contact = [[OHContact alloc] init];
    self.contact.fullName = @"Full Name";
    self.contact.firstName = @"First";
    self.contact.lastName = @"Last";
    self.contact.organizationName = @"Organization";
    self.contact.jobTitle = @"Job Title";
    self.contact.departmentName = @"Department";
    self.contact.contactFields = NSOrderedSetMake([[OHContactField alloc] initWithType:OHContactFieldTypePhoneNumber label:@"phone" value:@"555" dataProviderIdentifier:@"test"],
                                                  [[OHContactField alloc] initWithType:OHContactFieldTypeEmailAddress label:@"email" value:@"a@b.c" dataProviderIdentifier:@"test"],
                                                  [[OHContactField alloc] initWithType:OHContactFieldTypeURL label:@"url" value:@"http://test.test" dataProviderIdentifier:@"test"]);
    self.contact.postalAddresses = NSOrderedSetMake([[OHContactAddress alloc] initWithLabel:@"address" street:@"test" city:@"test" state:@"test" postalCode:@"test" country:@"country" dataProviderIdentifier:@"test"],
                                                    [[OHContactAddress alloc] initWithLabel:@"address" street:@"test2" city:@"test2" state:@"test2" postalCode:@"test" country:@"country" dataProviderIdentifier:@"test"]);
    self.contact.thumbnailPhoto = [UIImage imageNamed:@"Logo"];

    [self.contact.tags addObject:@"TestTag1"];
    [self.contact.tags addObject:@"TestTag2"];

    [self.contact.customProperties setObject:@"TestProperty1" forKey:@"TestProperty1Key"];
    [self.contact.customProperties setObject:@"TestProperty2" forKey:@"TestProperty2Key"];
}

- (void)testCopy
{
    OHContact *contactCopy = [self.contact copy];
    XCTAssertTrue([contactCopy isEqualToContact:self.contact]);
    XCTAssertTrue([self.contact isEqualToContact:contactCopy]);
}

- (void)testMutableCopy
{
    OHContact *contactCopy = [self.contact copy];
    [contactCopy.tags addObject:@"TestTag3"];
    XCTAssertTrue([contactCopy.tags containsObject:@"TestTag3"]);
    [contactCopy.customProperties setObject:@"TestProperty3" forKey:@"TestProperty3Key"];
    XCTAssertTrue([[contactCopy.customProperties objectForKey:@"TestProperty3Key"] isEqualToString:@"TestProperty3"]);
}

- (void)testEquality
{
    OHContact *testContact = [[OHContact alloc] init];
    testContact.fullName = @"Full Name";
    testContact.firstName = @"First";
    testContact.lastName = @"Last";
    testContact.organizationName = @"Organization";
    testContact.jobTitle = @"Job Title";
    testContact.departmentName = @"Department";
    testContact.contactFields = NSOrderedSetMake([[OHContactField alloc] initWithType:OHContactFieldTypePhoneNumber label:@"phone" value:@"555" dataProviderIdentifier:@"test"],
                                                 [[OHContactField alloc] initWithType:OHContactFieldTypeEmailAddress label:@"email" value:@"a@b.c" dataProviderIdentifier:@"test"],
                                                 [[OHContactField alloc] initWithType:OHContactFieldTypeURL label:@"url" value:@"http://test.test" dataProviderIdentifier:@"test"]);
    testContact.postalAddresses = NSOrderedSetMake([[OHContactAddress alloc] initWithLabel:@"address" street:@"test" city:@"test" state:@"test" postalCode:@"test" country:@"country" dataProviderIdentifier:@"test"],
                                                   [[OHContactAddress alloc] initWithLabel:@"address" street:@"test2" city:@"test2" state:@"test2" postalCode:@"test" country:@"country" dataProviderIdentifier:@"test"]);
    testContact.thumbnailPhoto = [UIImage imageNamed:@"Logo"];

    [testContact.tags addObject:@"TestTag1"];
    [testContact.tags addObject:@"TestTag2"];

    [testContact.customProperties setObject:@"TestProperty1" forKey:@"TestProperty1Key"];
    [testContact.customProperties setObject:@"TestProperty2" forKey:@"TestProperty2Key"];

    XCTAssertTrue([testContact isEqualToContact:self.contact]);
    XCTAssertTrue([self.contact isEqualToContact:testContact]);
}

- (void)testFullNameEquality
{
    OHContact *testContact = [[OHContact alloc] init];
    testContact.fullName = @"Not Full Name";
    testContact.firstName = @"First";
    testContact.lastName = @"Last";
    testContact.organizationName = @"Organization";
    testContact.jobTitle = @"Job Title";
    testContact.departmentName = @"Department";
    testContact.contactFields = NSOrderedSetMake([[OHContactField alloc] initWithType:OHContactFieldTypePhoneNumber label:@"phone" value:@"555" dataProviderIdentifier:@"test"],
                                                 [[OHContactField alloc] initWithType:OHContactFieldTypeEmailAddress label:@"email" value:@"a@b.c" dataProviderIdentifier:@"test"],
                                                 [[OHContactField alloc] initWithType:OHContactFieldTypeURL label:@"url" value:@"http://test.test" dataProviderIdentifier:@"test"]);
    testContact.postalAddresses = NSOrderedSetMake([[OHContactAddress alloc] initWithLabel:@"address" street:@"test" city:@"test" state:@"test" postalCode:@"test" country:@"country" dataProviderIdentifier:@"test"],
                                                   [[OHContactAddress alloc] initWithLabel:@"address" street:@"test2" city:@"test2" state:@"test2" postalCode:@"test" country:@"country" dataProviderIdentifier:@"test"]);
    testContact.thumbnailPhoto = [UIImage imageNamed:@"Logo"];

    [testContact.tags addObject:@"TestTag1"];
    [testContact.tags addObject:@"TestTag2"];

    [testContact.customProperties setObject:@"TestProperty1" forKey:@"TestProperty1Key"];
    [testContact.customProperties setObject:@"TestProperty2" forKey:@"TestProperty2Key"];

    XCTAssertFalse([testContact isEqualToContact:self.contact]);
    XCTAssertFalse([self.contact isEqualToContact:testContact]);
}

- (void)testFirstNameEquality
{
    OHContact *testContact = [[OHContact alloc] init];
    testContact.fullName = @"Full Name";
    testContact.firstName = @"Not First";
    testContact.lastName = @"Last";
    testContact.organizationName = @"Organization";
    testContact.jobTitle = @"Job Title";
    testContact.departmentName = @"Department";
    testContact.contactFields = NSOrderedSetMake([[OHContactField alloc] initWithType:OHContactFieldTypePhoneNumber label:@"phone" value:@"555" dataProviderIdentifier:@"test"],
                                                 [[OHContactField alloc] initWithType:OHContactFieldTypeEmailAddress label:@"email" value:@"a@b.c" dataProviderIdentifier:@"test"],
                                                 [[OHContactField alloc] initWithType:OHContactFieldTypeURL label:@"url" value:@"http://test.test" dataProviderIdentifier:@"test"]);
    testContact.postalAddresses = NSOrderedSetMake([[OHContactAddress alloc] initWithLabel:@"address" street:@"test" city:@"test" state:@"test" postalCode:@"test" country:@"country" dataProviderIdentifier:@"test"],
                                                   [[OHContactAddress alloc] initWithLabel:@"address" street:@"test2" city:@"test2" state:@"test2" postalCode:@"test" country:@"country" dataProviderIdentifier:@"test"]);
    testContact.thumbnailPhoto = [UIImage imageNamed:@"Logo"];

    [testContact.tags addObject:@"TestTag1"];
    [testContact.tags addObject:@"TestTag2"];

    [testContact.customProperties setObject:@"TestProperty1" forKey:@"TestProperty1Key"];
    [testContact.customProperties setObject:@"TestProperty2" forKey:@"TestProperty2Key"];

    XCTAssertFalse([testContact isEqualToContact:self.contact]);
    XCTAssertFalse([self.contact isEqualToContact:testContact]);
}

- (void)testLastNameEquality
{
    OHContact *testContact = [[OHContact alloc] init];
    testContact.fullName = @"Full Name";
    testContact.firstName = @"First";
    testContact.lastName = @"Not Last";
    testContact.organizationName = @"Organization";
    testContact.jobTitle = @"Job Title";
    testContact.departmentName = @"Department";
    testContact.contactFields = NSOrderedSetMake([[OHContactField alloc] initWithType:OHContactFieldTypePhoneNumber label:@"phone" value:@"555" dataProviderIdentifier:@"test"],
                                                 [[OHContactField alloc] initWithType:OHContactFieldTypeEmailAddress label:@"email" value:@"a@b.c" dataProviderIdentifier:@"test"],
                                                 [[OHContactField alloc] initWithType:OHContactFieldTypeURL label:@"url" value:@"http://test.test" dataProviderIdentifier:@"test"]);
    testContact.postalAddresses = NSOrderedSetMake([[OHContactAddress alloc] initWithLabel:@"address" street:@"test" city:@"test" state:@"test" postalCode:@"test" country:@"country" dataProviderIdentifier:@"test"],
                                                   [[OHContactAddress alloc] initWithLabel:@"address" street:@"test2" city:@"test2" state:@"test2" postalCode:@"test" country:@"country" dataProviderIdentifier:@"test"]);
    testContact.thumbnailPhoto = [UIImage imageNamed:@"Logo"];

    [testContact.tags addObject:@"TestTag1"];
    [testContact.tags addObject:@"TestTag2"];

    [testContact.customProperties setObject:@"TestProperty1" forKey:@"TestProperty1Key"];
    [testContact.customProperties setObject:@"TestProperty2" forKey:@"TestProperty2Key"];

    XCTAssertFalse([testContact isEqualToContact:self.contact]);
    XCTAssertFalse([self.contact isEqualToContact:testContact]);
}

- (void)testOrganizationNameEquality
{
    OHContact *testContact = [[OHContact alloc] init];
    testContact.fullName = @"Full Name";
    testContact.firstName = @"First";
    testContact.lastName = @"Last";
    testContact.organizationName = @"Not Organization";
    testContact.jobTitle = @"Job Title";
    testContact.departmentName = @"Department";
    testContact.contactFields = NSOrderedSetMake([[OHContactField alloc] initWithType:OHContactFieldTypePhoneNumber label:@"phone" value:@"555" dataProviderIdentifier:@"test"],
                                                 [[OHContactField alloc] initWithType:OHContactFieldTypeEmailAddress label:@"email" value:@"a@b.c" dataProviderIdentifier:@"test"],
                                                 [[OHContactField alloc] initWithType:OHContactFieldTypeURL label:@"url" value:@"http://test.test" dataProviderIdentifier:@"test"]);
    testContact.postalAddresses = NSOrderedSetMake([[OHContactAddress alloc] initWithLabel:@"address" street:@"test" city:@"test" state:@"test" postalCode:@"test" country:@"country" dataProviderIdentifier:@"test"],
                                                   [[OHContactAddress alloc] initWithLabel:@"address" street:@"test2" city:@"test2" state:@"test2" postalCode:@"test" country:@"country" dataProviderIdentifier:@"test"]);
    testContact.thumbnailPhoto = [UIImage imageNamed:@"Logo"];

    [testContact.tags addObject:@"TestTag1"];
    [testContact.tags addObject:@"TestTag2"];

    [testContact.customProperties setObject:@"TestProperty1" forKey:@"TestProperty1Key"];
    [testContact.customProperties setObject:@"TestProperty2" forKey:@"TestProperty2Key"];

    XCTAssertFalse([testContact isEqualToContact:self.contact]);
    XCTAssertFalse([self.contact isEqualToContact:testContact]);
}

- (void)testJobTitleEquality
{
    OHContact *testContact = [[OHContact alloc] init];
    testContact.fullName = @"Full Name";
    testContact.firstName = @"First";
    testContact.lastName = @"Last";
    testContact.organizationName = @"Organization";
    testContact.jobTitle = @"Not Job Title";
    testContact.departmentName = @"Department";
    testContact.contactFields = NSOrderedSetMake([[OHContactField alloc] initWithType:OHContactFieldTypePhoneNumber label:@"phone" value:@"555" dataProviderIdentifier:@"test"],
                                                 [[OHContactField alloc] initWithType:OHContactFieldTypeEmailAddress label:@"email" value:@"a@b.c" dataProviderIdentifier:@"test"],
                                                 [[OHContactField alloc] initWithType:OHContactFieldTypeURL label:@"url" value:@"http://test.test" dataProviderIdentifier:@"test"]);
    testContact.postalAddresses = NSOrderedSetMake([[OHContactAddress alloc] initWithLabel:@"address" street:@"test" city:@"test" state:@"test" postalCode:@"test" country:@"country" dataProviderIdentifier:@"test"],
                                                   [[OHContactAddress alloc] initWithLabel:@"address" street:@"test2" city:@"test2" state:@"test2" postalCode:@"test" country:@"country" dataProviderIdentifier:@"test"]);
    testContact.thumbnailPhoto = [UIImage imageNamed:@"Logo"];

    [testContact.tags addObject:@"TestTag1"];
    [testContact.tags addObject:@"TestTag2"];

    [testContact.customProperties setObject:@"TestProperty1" forKey:@"TestProperty1Key"];
    [testContact.customProperties setObject:@"TestProperty2" forKey:@"TestProperty2Key"];

    XCTAssertFalse([testContact isEqualToContact:self.contact]);
    XCTAssertFalse([self.contact isEqualToContact:testContact]);
}

- (void)testDepartmentNameEquality
{
    OHContact *testContact = [[OHContact alloc] init];
    testContact.fullName = @"Full Name";
    testContact.firstName = @"First";
    testContact.lastName = @"Last";
    testContact.organizationName = @"Organization";
    testContact.jobTitle = @"Job Title";
    testContact.departmentName = @"Not Department";
    testContact.contactFields = NSOrderedSetMake([[OHContactField alloc] initWithType:OHContactFieldTypePhoneNumber label:@"phone" value:@"555" dataProviderIdentifier:@"test"],
                                                 [[OHContactField alloc] initWithType:OHContactFieldTypeEmailAddress label:@"email" value:@"a@b.c" dataProviderIdentifier:@"test"],
                                                 [[OHContactField alloc] initWithType:OHContactFieldTypeURL label:@"url" value:@"http://test.test" dataProviderIdentifier:@"test"]);
    testContact.postalAddresses = NSOrderedSetMake([[OHContactAddress alloc] initWithLabel:@"address" street:@"test" city:@"test" state:@"test" postalCode:@"test" country:@"country" dataProviderIdentifier:@"test"],
                                                   [[OHContactAddress alloc] initWithLabel:@"address" street:@"test2" city:@"test2" state:@"test2" postalCode:@"test" country:@"country" dataProviderIdentifier:@"test"]);
    testContact.thumbnailPhoto = [UIImage imageNamed:@"Logo"];

    [testContact.tags addObject:@"TestTag1"];
    [testContact.tags addObject:@"TestTag2"];

    [testContact.customProperties setObject:@"TestProperty1" forKey:@"TestProperty1Key"];
    [testContact.customProperties setObject:@"TestProperty2" forKey:@"TestProperty2Key"];

    XCTAssertFalse([testContact isEqualToContact:self.contact]);
    XCTAssertFalse([self.contact isEqualToContact:testContact]);
}

- (void)testContactFieldsDeepEquality
{
    OHContact *testContact = [[OHContact alloc] init];
    testContact.fullName = @"Full Name";
    testContact.firstName = @"First";
    testContact.lastName = @"Last";
    testContact.organizationName = @"Organization";
    testContact.jobTitle = @"Job Title";
    testContact.departmentName = @"Department";
    testContact.contactFields = NSOrderedSetMake([[OHContactField alloc] initWithType:OHContactFieldTypePhoneNumber label:@"phone" value:@"not 555" dataProviderIdentifier:@"test"],
                                                 [[OHContactField alloc] initWithType:OHContactFieldTypeEmailAddress label:@"email" value:@"a@b.c" dataProviderIdentifier:@"test"],
                                                 [[OHContactField alloc] initWithType:OHContactFieldTypeURL label:@"url" value:@"http://test.test" dataProviderIdentifier:@"test"]);
    testContact.postalAddresses = NSOrderedSetMake([[OHContactAddress alloc] initWithLabel:@"address" street:@"test" city:@"test" state:@"test" postalCode:@"test" country:@"country" dataProviderIdentifier:@"test"],
                                                   [[OHContactAddress alloc] initWithLabel:@"address" street:@"test2" city:@"test2" state:@"test2" postalCode:@"test" country:@"country" dataProviderIdentifier:@"test"]);
    testContact.thumbnailPhoto = [UIImage imageNamed:@"Logo"];

    [testContact.tags addObject:@"TestTag1"];
    [testContact.tags addObject:@"TestTag2"];

    [testContact.customProperties setObject:@"TestProperty1" forKey:@"TestProperty1Key"];
    [testContact.customProperties setObject:@"TestProperty2" forKey:@"TestProperty2Key"];

    XCTAssertFalse([testContact isEqualToContact:self.contact]);
    XCTAssertFalse([self.contact isEqualToContact:testContact]);
}

- (void)testContactFieldsOrderEquality
{
    OHContact *testContact = [[OHContact alloc] init];
    testContact.fullName = @"Full Name";
    testContact.firstName = @"First";
    testContact.lastName = @"Last";
    testContact.organizationName = @"Organization";
    testContact.jobTitle = @"Job Title";
    testContact.departmentName = @"Department";
    testContact.contactFields = NSOrderedSetMake([[OHContactField alloc] initWithType:OHContactFieldTypeEmailAddress label:@"email" value:@"a@b.c" dataProviderIdentifier:@"test"],
                                                 [[OHContactField alloc] initWithType:OHContactFieldTypePhoneNumber label:@"phone" value:@"555" dataProviderIdentifier:@"test"],
                                                 [[OHContactField alloc] initWithType:OHContactFieldTypeURL label:@"url" value:@"http://test.test" dataProviderIdentifier:@"test"]);
    testContact.postalAddresses = NSOrderedSetMake([[OHContactAddress alloc] initWithLabel:@"address" street:@"test" city:@"test" state:@"test" postalCode:@"test" country:@"country" dataProviderIdentifier:@"test"],
                                                   [[OHContactAddress alloc] initWithLabel:@"address" street:@"test2" city:@"test2" state:@"test2" postalCode:@"test" country:@"country" dataProviderIdentifier:@"test"]);
    testContact.thumbnailPhoto = [UIImage imageNamed:@"Logo"];

    [testContact.tags addObject:@"TestTag1"];
    [testContact.tags addObject:@"TestTag2"];

    [testContact.customProperties setObject:@"TestProperty1" forKey:@"TestProperty1Key"];
    [testContact.customProperties setObject:@"TestProperty2" forKey:@"TestProperty2Key"];

    XCTAssertFalse([testContact isEqualToContact:self.contact]);
    XCTAssertFalse([self.contact isEqualToContact:testContact]);
}

- (void)testPostalAddressesDeepEquality
{
    OHContact *testContact = [[OHContact alloc] init];
    testContact.fullName = @"Full Name";
    testContact.firstName = @"First";
    testContact.lastName = @"Last";
    testContact.organizationName = @"Organization";
    testContact.jobTitle = @"Job Title";
    testContact.departmentName = @"Department";
    testContact.contactFields = NSOrderedSetMake([[OHContactField alloc] initWithType:OHContactFieldTypePhoneNumber label:@"phone" value:@"555" dataProviderIdentifier:@"test"],
                                                 [[OHContactField alloc] initWithType:OHContactFieldTypeEmailAddress label:@"email" value:@"a@b.c" dataProviderIdentifier:@"test"],
                                                 [[OHContactField alloc] initWithType:OHContactFieldTypeURL label:@"url" value:@"http://test.test" dataProviderIdentifier:@"test"]);
    testContact.postalAddresses = NSOrderedSetMake([[OHContactAddress alloc] initWithLabel:@"address" street:@"test" city:@"test" state:@"test" postalCode:@"test" country:@"country" dataProviderIdentifier:@"test"],
                                                   [[OHContactAddress alloc] initWithLabel:@"not address" street:@"test2" city:@"test2" state:@"test2" postalCode:@"test" country:@"country" dataProviderIdentifier:@"test"]);
    testContact.thumbnailPhoto = [UIImage imageNamed:@"Logo"];

    [testContact.tags addObject:@"TestTag1"];
    [testContact.tags addObject:@"TestTag2"];

    [testContact.customProperties setObject:@"TestProperty1" forKey:@"TestProperty1Key"];
    [testContact.customProperties setObject:@"TestProperty2" forKey:@"TestProperty2Key"];

    XCTAssertFalse([testContact isEqualToContact:self.contact]);
    XCTAssertFalse([self.contact isEqualToContact:testContact]);
}

- (void)testPostalAddressesOrderEquality
{
    OHContact *testContact = [[OHContact alloc] init];
    testContact.fullName = @"Full Name";
    testContact.firstName = @"First";
    testContact.lastName = @"Last";
    testContact.organizationName = @"Organization";
    testContact.jobTitle = @"Job Title";
    testContact.departmentName = @"Department";
    testContact.contactFields = NSOrderedSetMake([[OHContactField alloc] initWithType:OHContactFieldTypePhoneNumber label:@"phone" value:@"555" dataProviderIdentifier:@"test"],
                                                 [[OHContactField alloc] initWithType:OHContactFieldTypeEmailAddress label:@"email" value:@"a@b.c" dataProviderIdentifier:@"test"],
                                                 [[OHContactField alloc] initWithType:OHContactFieldTypeURL label:@"url" value:@"http://test.test" dataProviderIdentifier:@"test"]);
    testContact.postalAddresses = NSOrderedSetMake([[OHContactAddress alloc] initWithLabel:@"address" street:@"test2" city:@"test2" state:@"test2" postalCode:@"test" country:@"country" dataProviderIdentifier:@"test"],
                                                   [[OHContactAddress alloc] initWithLabel:@"address" street:@"test" city:@"test" state:@"test" postalCode:@"test" country:@"country" dataProviderIdentifier:@"test"]);
    testContact.thumbnailPhoto = [UIImage imageNamed:@"Logo"];

    [testContact.tags addObject:@"TestTag1"];
    [testContact.tags addObject:@"TestTag2"];

    [testContact.customProperties setObject:@"TestProperty1" forKey:@"TestProperty1Key"];
    [testContact.customProperties setObject:@"TestProperty2" forKey:@"TestProperty2Key"];

    XCTAssertFalse([testContact isEqualToContact:self.contact]);
    XCTAssertFalse([self.contact isEqualToContact:testContact]);
}

- (void)testThumbnailPhotoEquality
{
    OHContact *testContact = [[OHContact alloc] init];
    testContact.fullName = @"Full Name";
    testContact.firstName = @"First";
    testContact.lastName = @"Last";
    testContact.organizationName = @"Organization";
    testContact.jobTitle = @"Job Title";
    testContact.departmentName = @"Department";
    testContact.contactFields = NSOrderedSetMake([[OHContactField alloc] initWithType:OHContactFieldTypePhoneNumber label:@"phone" value:@"555" dataProviderIdentifier:@"test"],
                                                 [[OHContactField alloc] initWithType:OHContactFieldTypeEmailAddress label:@"email" value:@"a@b.c" dataProviderIdentifier:@"test"],
                                                 [[OHContactField alloc] initWithType:OHContactFieldTypeURL label:@"url" value:@"http://test.test" dataProviderIdentifier:@"test"]);
    testContact.postalAddresses = NSOrderedSetMake([[OHContactAddress alloc] initWithLabel:@"address" street:@"test" city:@"test" state:@"test" postalCode:@"test" country:@"country" dataProviderIdentifier:@"test"],
                                                   [[OHContactAddress alloc] initWithLabel:@"address" street:@"test2" city:@"test2" state:@"test2" postalCode:@"test" country:@"country" dataProviderIdentifier:@"test"]);
    testContact.thumbnailPhoto = [UIImage imageNamed:@"LogoClear"];

    [testContact.tags addObject:@"TestTag1"];
    [testContact.tags addObject:@"TestTag2"];

    [testContact.customProperties setObject:@"TestProperty1" forKey:@"TestProperty1Key"];
    [testContact.customProperties setObject:@"TestProperty2" forKey:@"TestProperty2Key"];

    XCTAssertFalse([testContact isEqualToContact:self.contact]);
    XCTAssertFalse([self.contact isEqualToContact:testContact]);
}

- (void)testTagEquality
{
    OHContact *testContact = [[OHContact alloc] init];
    testContact.fullName = @"Full Name";
    testContact.firstName = @"First";
    testContact.lastName = @"Last";
    testContact.organizationName = @"Organization";
    testContact.jobTitle = @"Job Title";
    testContact.departmentName = @"Department";
    testContact.contactFields = NSOrderedSetMake([[OHContactField alloc] initWithType:OHContactFieldTypePhoneNumber label:@"phone" value:@"555" dataProviderIdentifier:@"test"],
                                                 [[OHContactField alloc] initWithType:OHContactFieldTypeEmailAddress label:@"email" value:@"a@b.c" dataProviderIdentifier:@"test"],
                                                 [[OHContactField alloc] initWithType:OHContactFieldTypeURL label:@"url" value:@"http://test.test" dataProviderIdentifier:@"test"]);
    testContact.postalAddresses = NSOrderedSetMake([[OHContactAddress alloc] initWithLabel:@"address" street:@"test" city:@"test" state:@"test" postalCode:@"test" country:@"country" dataProviderIdentifier:@"test"],
                                                   [[OHContactAddress alloc] initWithLabel:@"address" street:@"test2" city:@"test2" state:@"test2" postalCode:@"test" country:@"country" dataProviderIdentifier:@"test"]);
    testContact.thumbnailPhoto = [UIImage imageNamed:@"Logo"];

    [testContact.tags addObject:@"TestTag1"];
    [testContact.tags addObject:@"not TestTag2"];

    [testContact.customProperties setObject:@"TestProperty1" forKey:@"TestProperty1Key"];
    [testContact.customProperties setObject:@"TestProperty2" forKey:@"TestProperty2Key"];

    XCTAssertFalse([testContact isEqualToContact:self.contact]);
    XCTAssertFalse([self.contact isEqualToContact:testContact]);
}

- (void)testCustomPropertyEquality
{
    OHContact *testContact = [[OHContact alloc] init];
    testContact.fullName = @"Full Name";
    testContact.firstName = @"First";
    testContact.lastName = @"Last";
    testContact.organizationName = @"Organization";
    testContact.jobTitle = @"Job Title";
    testContact.departmentName = @"Department";
    testContact.contactFields = NSOrderedSetMake([[OHContactField alloc] initWithType:OHContactFieldTypePhoneNumber label:@"phone" value:@"555" dataProviderIdentifier:@"test"],
                                                 [[OHContactField alloc] initWithType:OHContactFieldTypeEmailAddress label:@"email" value:@"a@b.c" dataProviderIdentifier:@"test"],
                                                 [[OHContactField alloc] initWithType:OHContactFieldTypeURL label:@"url" value:@"http://test.test" dataProviderIdentifier:@"test"]);
    testContact.postalAddresses = NSOrderedSetMake([[OHContactAddress alloc] initWithLabel:@"address" street:@"test" city:@"test" state:@"test" postalCode:@"test" country:@"country" dataProviderIdentifier:@"test"],
                                                   [[OHContactAddress alloc] initWithLabel:@"address" street:@"test2" city:@"test2" state:@"test2" postalCode:@"test" country:@"country" dataProviderIdentifier:@"test"]);
    testContact.thumbnailPhoto = [UIImage imageNamed:@"Logo"];

    [testContact.tags addObject:@"TestTag1"];
    [testContact.tags addObject:@"TestTag2"];

    [testContact.customProperties setObject:@"TestProperty1" forKey:@"TestProperty1Key"];
    [testContact.customProperties setObject:@"not TestProperty2" forKey:@"TestProperty2Key"];

    XCTAssertFalse([testContact isEqualToContact:self.contact]);
    XCTAssertFalse([self.contact isEqualToContact:testContact]);
}

@end
