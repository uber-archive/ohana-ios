//
//  OHStatisticsPostProcessor.h
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

#import <Foundation/Foundation.h>

#import "OHContactsPostProcessorProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface OHStatisticsPostProcessor : NSObject <OHContactsPostProcessorProtocol>

extern NSString *kOHStatisticsNumberOfContactFields;  // Total number of contact fields (NSNumber)
extern NSString *kOHStatisticsNumberOfPhoneNumbers;   // Number of contact fields of type UBContactFieldTypePhoneNumber (NSNumber *)
extern NSString *kOHStatisticsNumberOfEmailAddresses; // Number of contact fields of type UBContactFieldTypeEmailAddress (NSNumber *)
extern NSString *kOHStatisticsHasMobilePhoneNumber;   // Whether or not contact has a phone number with label of type "mobile" or "iPhone" (NSNumber *)

@end

NS_ASSUME_NONNULL_END
