//
//  OHMaximumSelectedCountSelectionFilter.h
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
#import <UberSignals/UberSignals.h>

#import "OHContactsSelectionFilterProtocol.h"
#import "OHContactsDataSource.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Signal fired when an attempt to exceed the maximum number of selected contacts is made
 *
 *  @param failedContacts The contacts that were not able to be selected
 */
CreateSignalInterface(OHContactsDataSourceSelectedContactsAttemptedToExceedMaximumCountSignal, NSOrderedSet<OHContact *> *failedContacts);

@interface OHMaximumSelectedCountSelectionFilter : NSObject <OHContactsSelectionFilterProtocol>

/**
 *  Sets an upper limit on the number of selected contacts. Setting a value of '0' means no limit.
 */
@property (nonatomic) NSUInteger maximumSelectedCount;

/**
 *  Signal fired when the maximum number of selected contacts has been reached
 */
@property (nonatomic, readonly) UBEmptySignal *onContactsDataSourceSelectedContactsReachedMaximumCountSignal;

/**
 *  Signal fired when an attempt to exceed the maximum number of selected contacts is made
 *
 *  @param failedContacts The contacts that were not able to be selected
 */
@property (nonatomic, readonly) OHContactsDataSourceSelectedContactsAttemptedToExceedMaximumCountSignal *onContactsDataSourceSelectedContactsAttemptedToExceedMaximumCountSignal;

/**
 *  Signal fired when the number of selected contacts was previously at the maximum count but has now dropped
 */
@property (nonatomic, readonly) UBEmptySignal *onContactsDataSourceSelectedContactsNoLongerAtMaximumCountSignal;


- (instancetype)initWithDataSource:(OHContactsDataSource *)dataSource maximumSelectedCount:(NSUInteger)maximumSelectedCount;

@end

NS_ASSUME_NONNULL_END
