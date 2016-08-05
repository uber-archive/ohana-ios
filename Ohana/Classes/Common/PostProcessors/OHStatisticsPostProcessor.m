//
//  OHStatisticsPostProcessor.m
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

#import "OHStatisticsPostProcessor.h"

#import <AddressBook/AddressBook.h>

@implementation OHStatisticsPostProcessor

@synthesize onContactsPostProcessorFinishedSignal = _onContactsPostProcessorFinishedSignal;

const NSString *kOHStatisticsNumberOfContactFields = @"kOHStatisticsNumberOfContactFields";
const NSString *kOHStatisticsNumberOfPhoneNumbers = @"kOHStatisticsNumberOfPhoneNumbers";
const NSString *kOHStatisticsNumberOfEmailAddresses = @"kOHStatisticsNumberOfEmailAddresses";
const NSString *kOHStatisticsHasMobilePhoneNumber = @"kOHStatisticsHasMobilePhoneNumber";

- (instancetype)init
{
    if (self = [super init]) {
        _onContactsPostProcessorFinishedSignal = [[OHContactsPostProcessorFinishedSignal alloc] init];
    }
    return self;
}

#pragma mark - OHContactsPostProcessorProtocol

- (NSOrderedSet<OHContact *> *)processContacts:(NSOrderedSet<OHContact *> *)preProcessedContacts
{
    NSString *mobileLabel = (__bridge_transfer NSString *)ABAddressBookCopyLocalizedLabel(kABPersonPhoneMobileLabel);
    NSString *iphoneLabel = (__bridge_transfer NSString *)ABAddressBookCopyLocalizedLabel(kABPersonPhoneIPhoneLabel);

    for (OHContact *contact in preProcessedContacts) {
        [contact.customProperties setObject:[NSNumber numberWithUnsignedInteger:contact.contactFields.count] forKey:kOHStatisticsNumberOfContactFields];

        NSUInteger phoneNumberCount = 0;
        NSUInteger emailAddressCount = 0;
        BOOL hasMobileNumber = NO;
        for (OHContactField *contactField in contact.contactFields) {
            switch (contactField.type) {
                case OHContactFieldTypePhoneNumber:
                    phoneNumberCount++;
                    if ([contactField.label isEqualToString:mobileLabel] || [contactField.label isEqualToString:iphoneLabel]) {
                        hasMobileNumber = YES;
                    }
                    break;
                case OHContactFieldTypeEmailAddress:
                    emailAddressCount++;
                    break;
                default:
                    break;
            }
        }
        [contact.customProperties setObject:[NSNumber numberWithUnsignedInteger:phoneNumberCount] forKey:kOHStatisticsNumberOfPhoneNumbers];
        [contact.customProperties setObject:[NSNumber numberWithUnsignedInteger:emailAddressCount] forKey:kOHStatisticsNumberOfEmailAddresses];
        [contact.customProperties setObject:[NSNumber numberWithBool:hasMobileNumber] forKey:kOHStatisticsHasMobilePhoneNumber];
    }

    self.onContactsPostProcessorFinishedSignal.fire(preProcessedContacts, self);
    return preProcessedContacts;
}

@end
