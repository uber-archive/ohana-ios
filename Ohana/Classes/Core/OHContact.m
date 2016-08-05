//
//  OHContact.m
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

#import "OHContact.h"

@interface OHContact ()

@property (nonatomic, readwrite) NSMutableSet<NSString *> *tags;
@property (nonatomic, readwrite) NSMutableDictionary<NSString *, id> *customProperties;

@end

@implementation OHContact

- (NSMutableSet<NSString *> *)tags
{
    if (!_tags) {
        _tags = [[NSMutableSet<NSString *> alloc] init];
    }
    return _tags;
}

- (NSMutableDictionary<NSString *, id> *)customProperties
{
    if (!_customProperties) {
        _customProperties = [[NSMutableDictionary<NSString *, id> alloc] init];
    }
    return _customProperties;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    OHContact *copy = [[OHContact alloc] init];
    copy.fullName = [self.fullName copy];
    copy.firstName = [self.firstName copy];
    copy.lastName = [self.lastName copy];
    copy.organizationName = [self.organizationName copy];
    copy.jobTitle = [self.jobTitle copy];
    copy.departmentName = [self.departmentName copy];
    copy.contactFields = [self.contactFields copy];
    copy.postalAddresses = [self.postalAddresses copy];
    copy.thumbnailPhoto = [self.thumbnailPhoto copy];
    copy.tags = [self.tags copy];
    copy.customProperties = [self.customProperties copy];
    return copy;
}

#pragma mark - Equality

- (BOOL)isEqualToContact:(OHContact *)contact
{
    return  ((!self.fullName && !contact.fullName) || [self.fullName isEqualToString:contact.fullName]) &&
            ((!self.firstName && !contact.firstName) || [self.firstName isEqualToString:contact.firstName]) &&
            ((!self.lastName && !contact.lastName) || [self.lastName isEqualToString:contact.lastName]) &&
            ((!self.organizationName && !contact.organizationName) || [self.organizationName isEqualToString:contact.organizationName]) &&
            ((!self.jobTitle && !contact.jobTitle) || [self.jobTitle isEqualToString:contact.jobTitle]) &&
            ((!self.departmentName && !contact.departmentName) || [self.departmentName isEqualToString:contact.departmentName]) &&
            [self _contactFieldsIsEqualToContactFields:contact.contactFields] &&
            [self _postalAddressesIsEqualToPostalAddresses:contact.postalAddresses] &&
            [self _thumbnailImageIsEqualToThumbnailImage:contact.thumbnailPhoto] &&
            [self.tags isEqualToSet:contact.tags] &&
            [self.customProperties isEqualToDictionary:contact.customProperties];
}

- (BOOL)_contactFieldsIsEqualToContactFields:(NSOrderedSet<OHContactField *> *)contactFields
{
    if (!self.contactFields && !contactFields) {
        return YES;
    }
    if (self.contactFields.count != contactFields.count) {
        return NO;
    }
    for (NSUInteger i = 0 ; i < self.contactFields.count ; i++) {
        if (![[self.contactFields objectAtIndex:i] isEqualToContactField:[contactFields objectAtIndex:i]]) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)_postalAddressesIsEqualToPostalAddresses:(NSOrderedSet<OHContactAddress *> *)postalAddresses
{
    if (!self.postalAddresses && !postalAddresses) {
        return YES;
    }
    if (self.postalAddresses.count != postalAddresses.count) {
        return NO;
    }
    for (NSUInteger i = 0 ; i < self.postalAddresses.count ; i++) {
        if (![[self.postalAddresses objectAtIndex:i] isEqualToContactAddress:[postalAddresses objectAtIndex:i]]) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)_thumbnailImageIsEqualToThumbnailImage:(UIImage *)thumbnailPhoto
{
    if (self.thumbnailPhoto && thumbnailPhoto) {
        NSData *selfData = UIImagePNGRepresentation(self.thumbnailPhoto);
        NSData *otherData = UIImagePNGRepresentation(thumbnailPhoto);

        return [selfData isEqualToData:otherData];
    }
    return self.thumbnailPhoto == nil && thumbnailPhoto == nil;
}

@end