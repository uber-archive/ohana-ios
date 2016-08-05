//
//  OHContactsDataProviderProtocol.h
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

#import <UberSignals/UberSignals.h>

#import "OHContact.h"

typedef NS_ENUM(NSInteger, OHContactsDataProviderStatus) {
    OHContactsDataProviderStatusInitialized,
    OHContactsDataProviderStatusProcessing,
    OHContactsDataProviderStatusLoaded,
    OHContactsDataProviderStatusError
};

NS_ASSUME_NONNULL_BEGIN

@protocol OHContactsDataProviderProtocol;

/**
 *  Signal to be fired after the contacts data provider has finished loading
 *
 *  @discussion Before firing this signal the data provider should have a status of UBCLContactsDataProviderStatusLoaded
 *
 *  @param dataProvider The data provider that has finished loading
 */
CreateSignalInterface(OHContactsDataProviderFinishedLoadingSignal, id<OHContactsDataProviderProtocol> dataProvider);

/**
 *  Signal to be fired after the contacts data provider has encountered an error
 *
 *  @discussion Before firing this signal the data provider should have a status of UBCLContactsDataProviderStatusError
 *
 *  @param dataProvider The data provider that failed to load
 */
CreateSignalInterface(OHContactsDataProviderErrorSignal, NSError *error, id<OHContactsDataProviderProtocol> dataProvider);

typedef NS_ENUM(NSInteger, OHContactsDataProviderErrorCode) {
    OHContactsDataProviderErrorCodeUnknown,            // Default
    OHContactsDataProviderErrorCodeAuthenticationError // Indicates that a failure occurred with authentication after (or before) an authentication challenge
};

extern NSString *const OHContactsDataProviderErrorDomain;

@protocol OHContactsDataProviderProtocol <NSObject>

/**
 *  Signal to be fired after the contacts data provider has finished loading (see signal definition)
 */
@property (nonatomic, readonly) OHContactsDataProviderFinishedLoadingSignal *onContactsDataProviderFinishedLoadingSignal;

/**
 *  Signal to be fired after the contacts data provider has encountered an error (see signal definition)
 */
@property (nonatomic, readonly) OHContactsDataProviderErrorSignal *onContactsDataProviderErrorSignal;

/**
 *  Status of the data provider
 */
@property (nonatomic, readonly) OHContactsDataProviderStatus status;

/**
 *  All contacts loaded by the data provider
 *
 *  @discussion This will be nil until onDataProviderFinishedLoadingSignal has fired
 */
@property (nonatomic, readonly, nullable) NSOrderedSet<OHContact *> *contacts;

/**
 *  Method to start the data provider loading contacts.
 *
 *  @discussion This method should start the loading process. If loading completes successfully, the contacts property should return a populated array of OHContacts
 *  and onDataProviderFinishedLoading should be fired. If an error occurs during loading, onDataProviderError should be fired.
 */
- (void)loadContacts;

/**
 * The identifier for this provider that will be assigned to contact fields and contact addresses returned by the provider
 *
 * @discussion This identifier should be unique across all data providers. We recommend using the class name.
 */
+ (NSString *)providerIdentifier;

@end

NS_ASSUME_NONNULL_END
