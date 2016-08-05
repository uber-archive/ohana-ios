//
//  OHPhoneNumberFormattingPostProcessor.h
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

typedef NS_OPTIONS (NSInteger, OHPhoneNumberFormat) {
    OHPhoneNumberFormatE164             = 1 << 0,
    OHPhoneNumberFormatInternational    = 1 << 1,
    OHPhoneNumberFormatNational         = 1 << 2,
    OHPhoneNumberFormatRFC3966          = 1 << 3,
};

@interface OHPhoneNumberFormattingPostProcessor : NSObject <OHContactsPostProcessorProtocol>

extern NSString *_Nonnull kOHFormattedPhoneNumberE164;          // Phone number in E164 format (NSString *)
extern NSString *_Nonnull kOHFormattedPhoneNumberInternational; // Phone number in International format (NSString *)
extern NSString *_Nonnull kOHFormattedPhoneNumberNational;      // Phone number in National format (NSString *)
extern NSString *_Nonnull kOHFormattedPhoneNumberRFC3966;       // Phone number in RFC3966 format (NSString *)

/**
 *  Bit mask of formats to use
 */
@property (nonatomic) OHPhoneNumberFormat formats;

- (instancetype)initWithFormats:(OHPhoneNumberFormat)formats;

@end

NS_ASSUME_NONNULL_END
