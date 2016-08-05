//
//  OHContactField.h
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

typedef NS_ENUM(NSInteger, OHContactFieldType) {
    OHContactFieldTypePhoneNumber = 0,
    OHContactFieldTypeEmailAddress,
    OHContactFieldTypeURL,
    OHContactFieldTypeOther
};

NS_ASSUME_NONNULL_BEGIN

@interface OHContactField : NSObject <NSCopying>

/**
 *  Creates the contact field object
 */
- (instancetype)initWithType:(OHContactFieldType)type label:(NSString *)label value:(NSString *)value dataProviderIdentifier:(NSString *)dataProviderIdentifier NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

/**
 *  Type of contact field (see enum above for options)
 */
@property (nonatomic, readonly) OHContactFieldType type;

/**
 *  Label (i.e. "home", "work")
 */
@property (nonatomic, readonly) NSString *label;

/**
 *  Value
 */
@property (nonatomic, readonly) NSString *value;

/**
 *  Set of custom tags (may be added by data providers, post processors, etc.)
 */
@property (nonatomic, readonly) NSMutableSet<NSString *> *tags;

/**
 *  Set of custom properties (may be added by data providers, post processors, etc.)
 */
@property (nonatomic, readonly) NSMutableDictionary<NSString *, id> *customProperties;

/**
 *  Identifier of the data provider that created the contact field
 */
@property (nonatomic, readonly) NSString *dataProviderIdentifier;

- (BOOL)isEqualToContactField:(OHContactField *)contactField;

@end

NS_ASSUME_NONNULL_END
