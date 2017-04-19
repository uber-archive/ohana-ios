//
//  OHContact.h
//	Ohana
//
// 	Copyright (c) 2016 Uber Technologies, Inc.
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//	THE SOFTWARE.
//

#import <UIKit/UIKit.h>

#import "OHContactField.h"
#import "OHContactAddress.h"

NS_ASSUME_NONNULL_BEGIN

@interface OHContact : NSObject <NSCopying>

/**
 *	Contact's identifier
 */
@property (nonatomic) NSString *identifier;

/**
 *	Contact's full name
 */
@property (nonatomic, nullable, copy) NSString *fullName;

/**
 *	Contact's first name
 */
@property (nonatomic, nullable, copy) NSString *firstName;

/**
 *	Contact's last name
 */
@property (nonatomic, nullable, copy) NSString *lastName;

/**
 *  Organization name
 */
@property (nonatomic, nullable, copy) NSString *organizationName;

/**
 *  Job title
 */
@property (nonatomic, nullable, copy) NSString *jobTitle;

/**
 *  Department name
 */
@property (nonatomic, nullable, copy) NSString *departmentName;

/**
 *  Contact fields associated with the contact
 */
@property (nonatomic, nullable, copy) NSOrderedSet<OHContactField *> *contactFields;

/**
 *  Postal addresses associated with the contact
 */
@property (nonatomic, nullable, copy) NSOrderedSet<OHContactAddress *> *postalAddresses;

/**
 *  Thumbnail photo
 */
@property (nonatomic, nullable, copy) UIImage *thumbnailPhoto;

/**
 *  Set of custom tags (may be added by data providers, post processors, etc.)
 */
@property (nonatomic, readonly) NSMutableSet<NSString *> *tags;

/**
 *  Set of custom properties (may be added by data providers, post processors, etc.)
 */
@property (nonatomic, readonly) NSMutableDictionary<NSString *, id> *customProperties;

- (BOOL)isEqualToContact:(OHContact *)contact;

@end

NS_ASSUME_NONNULL_END
