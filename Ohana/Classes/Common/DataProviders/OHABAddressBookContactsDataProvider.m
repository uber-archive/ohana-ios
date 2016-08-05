//
//  OHABAddressBookContactsDataProvider.m
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

#import "OHABAddressBookContactsDataProvider.h"

@interface OHABAddressBookContactsDataProvider ()

/**
 * Executed when we have loaded the user's contacts list
 *
 * @param records Ordered set of ABRecordRef objects representing the user's contacts list
 */
typedef void (^OHABContactsFetchCompletionBlock)(NSOrderedSet<OHContact *> *records);

/**
 * Executed if there's an issue with loading the contact list
 *
 * @param error An NSError detailing the issue
 */
typedef void (^OHABContactsFetchFailedBlock)(NSError *error);

@property (nonatomic, weak, readonly) id<OHABAddressBookContactsDataProviderDelegate> delegate;

@end

@implementation OHABAddressBookContactsDataProvider

@synthesize onContactsDataProviderFinishedLoadingSignal = _onContactsDataProviderFinishedLoadingSignal, onContactsDataProviderErrorSignal = _onContactsDataProviderErrorSignal, status = _status, contacts = _contacts;

- (instancetype)initWithDelegate:(id<OHABAddressBookContactsDataProviderDelegate>)delegate
{
    if (self = [super init]) {
        _onContactsDataProviderFinishedLoadingSignal = [[OHContactsDataProviderFinishedLoadingSignal alloc] init];
        _onContactsDataProviderErrorSignal = [[OHContactsDataProviderErrorSignal alloc] init];
        _status = OHContactsDataProviderStatusInitialized;
        _delegate = delegate;
    }
    return self;
}

#pragma mark - OHContactsDataProviderProtocol

- (void)loadContacts
{
    if ([self _authorizationStatus] == kABAuthorizationStatusNotDetermined) {
        [self.delegate dataProviderDidHitAddressBookAuthenticationChallenge:self];
    } else if ([self _authorizationStatus] == kABAuthorizationStatusAuthorized) {
        _status = OHContactsDataProviderStatusProcessing;
        [self _fetchContactsWithSuccess:^(NSOrderedSet<OHContact *> *records) {
            _contacts = records;
            _status = OHContactsDataProviderStatusLoaded;
            self.onContactsDataProviderFinishedLoadingSignal.fire(self);
        } failure:^(NSError *error) {
            _status = OHContactsDataProviderStatusError;
            self.onContactsDataProviderErrorSignal.fire(error, self);
        }];
    } else {
        _status = OHContactsDataProviderStatusError;
        self.onContactsDataProviderErrorSignal.fire([NSError errorWithDomain:OHContactsDataProviderErrorDomain code:OHContactsDataProviderErrorCodeAuthenticationError userInfo:nil], self);
    }
}

+ (NSString *)providerIdentifier
{
    return NSStringFromClass([OHABAddressBookContactsDataProvider class]);
}

#pragma mark - Private

- (void)_fetchContactsWithSuccess:(OHABContactsFetchCompletionBlock)success failure:(OHABContactsFetchFailedBlock)failure
{
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    [self _requestAddressBookAccessWithAddressBook:addressBook completion:^(bool granted, CFErrorRef error) {
        if (granted && !error) {
            [self _readAddressBookContacts:addressBook completion:^(NSOrderedSet<OHContact *> *records) {
                success(records);
            }];
        } else {
            _status = OHContactsDataProviderStatusError;
            failure((__bridge NSError *)error);
        }
        if (addressBook) {
            CFRelease(addressBook);
        }
    }];
}

- (void)_readAddressBookContacts:(ABAddressBookRef)addressBook completion:(void (^)(NSOrderedSet<OHContact *> *records))completion
{
    CFArrayRef peopleRecordRefs = [self _copyArrayOfAllPeopleFromAddressBook:addressBook];
    if (peopleRecordRefs) {
        long peopleRecordRefsCount = CFArrayGetCount(peopleRecordRefs);
        NSMutableOrderedSet<OHContact *> *ubContactsArray = [NSMutableOrderedSet orderedSetWithCapacity:(NSUInteger)peopleRecordRefsCount];
        for (long i = 0; i < peopleRecordRefsCount; i++) {
            [ubContactsArray addObject:[self _transformABRecordToOHContactWithRecord:CFArrayGetValueAtIndex(peopleRecordRefs, i)]];
        }
        completion(ubContactsArray);
        CFRelease(peopleRecordRefs);
    } else {
        completion(nil);
    }
}

- (OHContact *)_transformABRecordToOHContactWithRecord:(ABRecordRef)record
{
    OHContact *contact = [[OHContact alloc] init];
    contact.firstName = [self _stringForABPropertyId:kABPersonFirstNameProperty record:record];
    contact.lastName = [self _stringForABPropertyId:kABPersonLastNameProperty record:record];
    contact.fullName = [self _fullNameForRecord:record];
    contact.thumbnailPhoto = [self _thumbnailPictureForRecord:record];

    NSMutableOrderedSet *contactFields = [[NSMutableOrderedSet alloc] init];
    [contactFields addObjectsFromArray:[self _createContactFieldsForPhoneNumbersFromRecord:record]];
    [contactFields addObjectsFromArray:[self _createContactFieldsForEmailsFromRecord:record]];

    contact.contactFields = contactFields;

    return contact;
}

- (NSArray<OHContactField *> *)_createContactFieldsForPhoneNumbersFromRecord:(ABRecordRef)record
{
    ABMultiValueRef multiValue = ABRecordCopyValue(record, kABPersonPhoneProperty);
    NSMutableArray<OHContactField *> *fieldsArray = nil;
    if (multiValue) {
        CFIndex fieldCount = ABMultiValueGetCount(multiValue);
        fieldsArray = [[NSMutableArray alloc] initWithCapacity:(NSUInteger)fieldCount];

        for (CFIndex i = 0; i < fieldCount; i++) {
            NSString *label = @"mobile";
            CFStringRef rawLabel = ABMultiValueCopyLabelAtIndex(multiValue, i);
            if (rawLabel) {
                label = (__bridge_transfer NSString *)ABAddressBookCopyLocalizedLabel(rawLabel);
                CFRelease(rawLabel);
            }
            NSString *value = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(multiValue, i);
            OHContactField *contactField = [[OHContactField alloc] initWithType:OHContactFieldTypePhoneNumber label:label value:value dataProviderIdentifier:[OHABAddressBookContactsDataProvider providerIdentifier]];
            [fieldsArray addObject:contactField];
        }
        CFRelease(multiValue);
    }

    return fieldsArray;
}

- (NSArray<OHContactField *> *)_createContactFieldsForEmailsFromRecord:(ABRecordRef)record
{
    ABMultiValueRef multiValue = ABRecordCopyValue(record, kABPersonEmailProperty);
    NSMutableArray<OHContactField *> *fieldsArray = nil;
    if (multiValue) {
        CFIndex fieldCount = ABMultiValueGetCount(multiValue);
        fieldsArray = [[NSMutableArray alloc] init];

        for (CFIndex i = 0; i < fieldCount; i++) {
            NSString *value = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(multiValue, i);

            NSString *label = @"email";
            CFStringRef rawLabel = ABMultiValueCopyLabelAtIndex(multiValue, i);
            if (rawLabel) {
                label = (__bridge_transfer NSString *)ABAddressBookCopyLocalizedLabel(rawLabel);
                CFRelease(rawLabel);
            }

            OHContactField *contactField = [[OHContactField alloc] initWithType:OHContactFieldTypeEmailAddress label:label value:value dataProviderIdentifier:[OHABAddressBookContactsDataProvider providerIdentifier]];
            [fieldsArray addObject:contactField];
        }
        CFRelease(multiValue);
    }
    
    return fieldsArray;
}

#pragma mark - Private - Address Book Wrappers

- (ABAuthorizationStatus)_authorizationStatus
{
    return ABAddressBookGetAuthorizationStatus();
}

- (void)_requestAddressBookAccessWithAddressBook:(ABAddressBookRef)addressBook completion:(void (^)(bool granted, CFErrorRef error))completion
{
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
        completion(granted, error);
    });
}

- (ABPersonCompositeNameFormat)_getPersonCompositeNameFormatForRecord:(ABRecordRef)record
{
    return ABPersonGetCompositeNameFormatForRecord(record);
}

- (ABPersonSortOrdering)_getPersonSortOrdering
{
    return ABPersonGetSortOrdering();
}

- (CFArrayRef)_copyArrayOfAllPeopleFromAddressBook:(ABAddressBookRef)addressBook
{
    return ABAddressBookCopyArrayOfAllPeople(addressBook);
}

#pragma mark - Private - ABRecordRef Parsing

- (NSString *)_stringForABPropertyId:(ABPropertyID)propertyId record:(ABRecordRef)record
{
    NSString *string = (__bridge_transfer NSString *)ABRecordCopyValue(record, propertyId);
    if (!string.length) {
        return nil;
    }

    return string;
}

- (NSString *)_fullNameForRecord:(ABRecordRef)record
{
    NSString *fullName = nil;
    NSString *firstName = [self _stringForABPropertyId:kABPersonFirstNameProperty record:record];
    NSString *lastName = [self _stringForABPropertyId:kABPersonLastNameProperty record:record];

    if (firstName.length && lastName.length) {
        if ([self _getPersonCompositeNameFormatForRecord:record] == kABPersonCompositeNameFormatFirstNameFirst) {
            fullName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
        } else {
            fullName = [NSString stringWithFormat:@"%@, %@", lastName, firstName];
        }
    } else if (firstName.length) {
        fullName = firstName;
    } else if (lastName.length) {
        fullName = lastName;
    }

    return fullName;
}

- (NSString *)_nameIndexLetterForFirstName:(NSString *)firstName lastName:(NSString *)lastName
{
    NSString *nameIndexLetter = nil;
    if (firstName.length) {
        nameIndexLetter = [firstName substringToIndex:1].uppercaseString;
    } else if (lastName.length) {
        nameIndexLetter = [lastName substringToIndex:1].uppercaseString;
    }

    return nameIndexLetter;
}

- (UIImage *)_thumbnailPictureForRecord:(ABRecordRef)record
{
    UIImage *picture = nil;
    if (ABPersonHasImageData(record)) {
        NSData *imageData = (__bridge_transfer NSData *)ABPersonCopyImageDataWithFormat(record, kABPersonImageFormatThumbnail);
        picture = [UIImage imageWithData:imageData];
    }

    return picture;
}

@end
