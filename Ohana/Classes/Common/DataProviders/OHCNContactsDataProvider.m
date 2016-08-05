//
//  OHCNContactsDataProvider.m
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

#import "OHCNContactsDataProvider.h"


@interface OHCNContactsDataProvider ()

typedef void (^OHCNContactsDataProviderFetchCompletionBlock)(NSOrderedSet<OHContact *> *contacts);
typedef void (^OHCNContactsDataProviderFetchFailedBlock)(NSError *error);

@property (nonatomic, weak, readonly) id<OHCNContactsDataProviderDelegate> delegate;

@end


@implementation OHCNContactsDataProvider

@synthesize onContactsDataProviderFinishedLoadingSignal = _onContactsDataProviderFinishedLoadingSignal,onContactsDataProviderErrorSignal = _onContactsDataProviderErrorSignal, status = _status, contacts = _contacts;

const NSString *kOHCNContactsDataProviderContactIdentifierKey = @"kOHCNContactsDataProviderContactIdentifierKey";

- (instancetype)initWithDelegate:(id<OHCNContactsDataProviderDelegate>)delegate
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
    if ([self _authorizationStatus] == CNAuthorizationStatusNotDetermined) {
        [self.delegate dataProviderDidHitContactsAuthenticationChallenge:self];
    } else if ([self _authorizationStatus] == CNAuthorizationStatusAuthorized) {
        _status = OHContactsDataProviderStatusProcessing;
        [self _fetchContactsWithSuccess:^(NSOrderedSet<OHContact *> *contacts) {
            _contacts = contacts;
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
    return NSStringFromClass([OHCNContactsDataProvider class]);
}

#pragma mark - Private

- (CNAuthorizationStatus)_authorizationStatus
{
    return [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
}

- (void)_fetchContactsWithSuccess:(OHCNContactsDataProviderFetchCompletionBlock)success failure:(OHCNContactsDataProviderFetchFailedBlock)failure
{
    CNContactStore *contactStore = [[CNContactStore alloc] init];
    NSError *error;

    NSMutableArray *keysToFetch = [NSMutableArray arrayWithObjects:[CNContactFormatter descriptorForRequiredKeysForStyle:CNContactFormatterStyleFullName],
                                                                   CNContactEmailAddressesKey,
                                                                   CNContactPhoneNumbersKey,
                                                                   CNContactUrlAddressesKey,
                                                                   CNContactPostalAddressesKey,
                                                                   CNContactOrganizationNameKey,
                                                                   CNContactJobTitleKey,
                                                                   CNContactDepartmentNameKey,
                                                                   nil];

    if (self.loadThumbnailImage) {
        [keysToFetch addObject:CNContactThumbnailImageDataKey];
    }

    NSArray<CNContainer *> *containters = [contactStore containersMatchingPredicate:nil error:&error];

    if (error) {
        failure(error);
        return;
    }

    NSMutableArray<CNContact *> *cnContacts = [[NSMutableArray alloc] init];
    for (CNContainer *containter in containters) {
        NSArray<CNContact *> *contactsInContainer = [contactStore unifiedContactsMatchingPredicate:[CNContact predicateForContactsInContainerWithIdentifier:containter.identifier]
                                                                                       keysToFetch:keysToFetch
                                                                                             error:&error];

        if (error) {
            failure(error);
            return;
        }

        [cnContacts addObjectsFromArray:contactsInContainer];
    }

    NSMutableOrderedSet<OHContact *> *contacts = [[NSMutableOrderedSet<OHContact *> alloc] initWithCapacity:cnContacts.count];
    for (CNContact *cnContact in cnContacts) {
        [contacts addObject:[self _contactForCNContact:cnContact]];
    }
    success(contacts);
}

- (OHContact *)_contactForCNContact:(CNContact *)cnContact
{
    OHContact *contact = [[OHContact alloc] init];
    [contact.customProperties setObject:cnContact.identifier forKey:kOHCNContactsDataProviderContactIdentifierKey];

    contact.fullName = [CNContactFormatter stringFromContact:cnContact style:CNContactFormatterStyleFullName];
    contact.firstName = cnContact.givenName;
    contact.lastName = cnContact.familyName;
    contact.organizationName = cnContact.organizationName;
    contact.jobTitle = cnContact.jobTitle;
    contact.departmentName = cnContact.departmentName;

    if (self.loadThumbnailImage && cnContact.thumbnailImageData) {
        contact.thumbnailPhoto = [UIImage imageWithData:cnContact.thumbnailImageData];
    }

    NSMutableOrderedSet<OHContactField *> *contactFields = [[NSMutableOrderedSet<OHContactField *> alloc] init];
    for (CNLabeledValue<CNPhoneNumber *> *phoneNumber in cnContact.phoneNumbers) {
        [contactFields addObject:[[OHContactField alloc] initWithType:OHContactFieldTypePhoneNumber
                                                                label:[CNLabeledValue localizedStringForLabel:phoneNumber.label]
                                                                value:phoneNumber.value.stringValue
                                               dataProviderIdentifier:[OHCNContactsDataProvider providerIdentifier]]];
    }
    for (CNLabeledValue<NSString *> *emailAddress in cnContact.emailAddresses) {
        [contactFields addObject:[[OHContactField alloc] initWithType:OHContactFieldTypeEmailAddress
                                                                label:[CNLabeledValue localizedStringForLabel:emailAddress.label]
                                                                value:emailAddress.value
                                               dataProviderIdentifier:[OHCNContactsDataProvider providerIdentifier]]];
    }
    for (CNLabeledValue<NSString *> *url in cnContact.urlAddresses) {
        [contactFields addObject:[[OHContactField alloc] initWithType:OHContactFieldTypeURL
                                                                label:[CNLabeledValue localizedStringForLabel:url.label]
                                                                value:url.value
                                               dataProviderIdentifier:[OHCNContactsDataProvider providerIdentifier]]];
    }
    contact.contactFields = contactFields;

    NSMutableOrderedSet<OHContactAddress *> *postalAddresses = [[NSMutableOrderedSet<OHContactAddress *> alloc] init];
    for (CNLabeledValue<CNPostalAddress *> *postalAddress in cnContact.postalAddresses) {
        [postalAddresses addObject:[[OHContactAddress alloc] initWithLabel:[CNLabeledValue localizedStringForLabel:postalAddress.label]
                                                                    street:postalAddress.value.street
                                                                      city:postalAddress.value.city
                                                                     state:postalAddress.value.state
                                                                postalCode:postalAddress.value.postalCode
                                                                   country:postalAddress.value.country
                                                    dataProviderIdentifier:[OHCNContactsDataProvider providerIdentifier]]];
    }
    contact.postalAddresses = postalAddresses;
    
    return contact;
}

@end
