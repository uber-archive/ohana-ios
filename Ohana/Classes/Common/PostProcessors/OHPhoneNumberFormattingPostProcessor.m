//
//  OHPhoneNumberFormattingPostProcessor.m
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

#import "OHPhoneNumberFormattingPostProcessor.h"

// This imports libPhoneNumber-iOS if using libraries
#if __has_include(<libPhoneNumber-iOS/NBPhoneNumberUtil.h>)
#import <libPhoneNumber-iOS/NBPhoneNumberUtil.h>
#elif __has_include(<libPhoneNumber_iOS/NBPhoneNumberUtil.h>)
#import <libPhoneNumber_iOS/NBPhoneNumberUtil.h>
#endif

@interface OHPhoneNumberFormattingPostProcessor ()

@property (nonatomic) NBPhoneNumberUtil *phoneNumberUtil;

@end

@implementation OHPhoneNumberFormattingPostProcessor

@synthesize onContactsPostProcessorFinishedSignal = _onContactsPostProcessorFinishedSignal;

const NSString *kOHFormattedPhoneNumberE164 = @"kOHFormattedPhoneNumberE164";
const NSString *kOHFormattedPhoneNumberInternational = @"kOHFormattedPhoneNumberInternational";
const NSString *kOHFormattedPhoneNumberNational = @"kOHFormattedPhoneNumberNational";
const NSString *kOHFormattedPhoneNumberRFC3966 = @"kOHFormattedPhoneNumberRFC3966";

- (instancetype)initWithFormats:(OHPhoneNumberFormat)formats
{
    if (self = [super init]) {
        _onContactsPostProcessorFinishedSignal = [[OHContactsPostProcessorFinishedSignal alloc] init];
        _formats = formats;
    }
    return self;
}

#pragma mark - OHContactsPostProcessorProtocol

- (NSOrderedSet<OHContact *> *)processContacts:(NSOrderedSet<OHContact *> *)preProcessedContacts
{
    for (OHContact *contact in preProcessedContacts) {
        for (OHContactField *contactField in contact.contactFields) {
            if (contactField.type == OHContactFieldTypePhoneNumber) {
                NSError *error;
                NBPhoneNumber *phoneNumber = [self.phoneNumberUtil parse:contactField.value defaultRegion:[self _countryCode] error:&error];
                if (!error) {
                    if (self.formats & OHPhoneNumberFormatE164) {
                        NSError *formattingError;
                        NSString *formattedPhoneNumber = [self.phoneNumberUtil format:phoneNumber numberFormat:NBEPhoneNumberFormatE164 error:&formattingError];
                        if (!formattingError) {
                            [contactField.customProperties setObject:formattedPhoneNumber forKey:kOHFormattedPhoneNumberE164];
                        }
                    }
                    if (self.formats & OHPhoneNumberFormatInternational) {
                        NSError *formattingError;
                        NSString *formattedPhoneNumber = [self.phoneNumberUtil format:phoneNumber numberFormat:NBEPhoneNumberFormatINTERNATIONAL error:&formattingError];
                        if (!formattingError) {
                            [contactField.customProperties setObject:formattedPhoneNumber forKey:kOHFormattedPhoneNumberInternational];
                        }
                    }
                    if (self.formats & OHPhoneNumberFormatNational) {
                        NSError *formattingError;
                        NSString *formattedPhoneNumber = [self.phoneNumberUtil format:phoneNumber numberFormat:NBEPhoneNumberFormatNATIONAL error:&formattingError];
                        if (!formattingError) {
                            [contactField.customProperties setObject:formattedPhoneNumber forKey:kOHFormattedPhoneNumberNational];
                        }
                    }
                    if (self.formats & OHPhoneNumberFormatRFC3966) {
                        NSError *formattingError;
                        NSString *formattedPhoneNumber = [self.phoneNumberUtil format:phoneNumber numberFormat:NBEPhoneNumberFormatRFC3966 error:&formattingError];
                        if (!formattingError) {
                            [contactField.customProperties setObject:formattedPhoneNumber forKey:kOHFormattedPhoneNumberRFC3966];
                        }
                    }
                }
            }
        }
    }
    self.onContactsPostProcessorFinishedSignal.fire(preProcessedContacts, self);
    return preProcessedContacts;
}

#pragma mark - Private

- (NBPhoneNumberUtil *)phoneNumberUtil
{
    if (!_phoneNumberUtil) {
        _phoneNumberUtil = [[NBPhoneNumberUtil alloc] init];
    }
    return _phoneNumberUtil;
}

- (NSString *)_countryCode
{
    return [[[NSLocale currentLocale] objectForKey:NSLocaleCountryCode] uppercaseString];
}

@end
