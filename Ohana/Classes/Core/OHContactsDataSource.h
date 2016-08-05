//
//  OHContactsDataSource.h
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

#import "OHContact.h"
#import "OHContactsDataProviderProtocol.h"
#import "OHContactsPostProcessorProtocol.h"
#import "OHContactsSelectionFilterProtocol.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Signal fired after the data source selects contacts
 *
 *  @discussion selectedContacts contains contacts that have passed through the selection filters and were not already selected
 */
CreateSignalInterface(OHContactsDataSourceSelectedContactsSignal, NSOrderedSet<OHContact *> *selectedContacts);

/**
 *  Signal fired after the data source deselects contacts
 *
 *  @discussion deselectedContacts contains contacts that have passed through the selection filters and were previously selected
 */
CreateSignalInterface(OHContactsDataSourceDeselectedContactsSignal, NSOrderedSet<OHContact *> *deselectedContacts);

@interface OHContactsDataSource : NSObject

/**
 *  Ordered set of data providers that the data source was initialized with
 */
@property (nonatomic, readonly) NSOrderedSet<id<OHContactsDataProviderProtocol>> *dataProviders;

/**
 *  Ordered set of post processors that the data source was initialized with
 */
@property (nonatomic, readonly, nullable) NSOrderedSet<id<OHContactsPostProcessorProtocol>> *postProcessors;

/**
 *  Ordered set of selection filters
 *
 *  @discussion The selection filters can be updated at any time
 */
@property (nonatomic, nullable) NSOrderedSet<id<OHContactsSelectionFilterProtocol>> *selectionFilters;

/**
 *  Signal fired after the data source has finished loading all of its data providers
 */
@property (nonatomic, readonly) UBEmptySignal *onContactsDataSourceLoadedProvidersSignal;

/**
 *  Signal fired after the data source has finished running all of its post processors
 */
@property (nonatomic, readonly) UBEmptySignal *onContactsDataSourcePostProcessorsFinishedSignal;

/**
 *  Signal fired after the data source is ready to be used
 *
 *  @discussion When this signal is fired, the `contacts` property will have been set
 */
@property (nonatomic, readonly) UBEmptySignal *onContactsDataSourceReadySignal;

/**
 *  Signal fired after the data source selects contacts
 */
@property (nonatomic, readonly) OHContactsDataSourceSelectedContactsSignal *onContactsDataSourceSelectedContactsSignal;

/**
 *  Signal fired after the data source deselects contacts
 */
@property (nonatomic, readonly) OHContactsDataSourceDeselectedContactsSignal *onContactsDataSourceDeselectedContactsSignal;

/**
 *  Ordered set of contacts received from the data providers and processed by the post processors
 *
 *  @discussion This will be nil until loadContacts is called
 */
@property (nonatomic, readonly, nullable) NSOrderedSet<OHContact *> *contacts;

/**
 *  Set of selected contacts
 */
@property (nonatomic, readonly) NSOrderedSet<OHContact *> *selectedContacts;

/**
 *  Contact filtering block used in the contactsPassingFilter method
 *
 *  @param contact The contact being filtered on
 *
 *  @return A boolean representing if the contact passes the filter or not
 */
typedef BOOL (^FilterContactsBlock)(OHContact *contact);

/**
 *  Designated initalizer for contact data source
 *
 *  @discussion You must provide at least one data provider.
 *
 *  @param dataProviders    An ordered set of objects conforming to the UBCLContactsDataProviderProtocol, will be used to populate contact data in the data source
 *  @param postProcessors   An ordered set of postprocessors to run on the data from the UBCLContactsDataProviderProtocol objects (optional)
 *
 *  @return an instance of UBContactsDataSource
 */
- (instancetype)initWithDataProviders:(NSOrderedSet<id<OHContactsDataProviderProtocol>> *)dataProviders postProcessors:(NSOrderedSet<id<OHContactsPostProcessorProtocol>> *_Nullable)postProcessors NS_DESIGNATED_INITIALIZER;

/**
 *  Convenience initalizer for contact data source with selection filters
 *
 *  @discussion You must provide at least one data provider.
 *
 *  @param dataProviders    An ordered set of objects conforming to the UBCLContactsDataProviderProtocol, will be used to populate contact data in the data source
 *  @param postProcessors   An ordered set of postprocessors to run on the data from the UBCLContactsDataProviderProtocol objects (optional)
 *  @param selectionFilters An ordered set of selection filters to filter contacts before selection or deselection occurs (optional)
 */
- (instancetype)initWithDataProviders:(NSOrderedSet<id<OHContactsDataProviderProtocol>> *)dataProviders postProcessors:(NSOrderedSet<id<OHContactsPostProcessorProtocol>> *_Nullable)postProcessors selectionFilters:(NSOrderedSet<id<OHContactsSelectionFilterProtocol>> *_Nullable)selectionFilters;

- (instancetype)init NS_UNAVAILABLE;

/**
 *  Tells the data source to begin loading contacts data from the data providers and then pass that contact data through the post processors.
 *  This method fires several important events that should be observed on to act on the contact data, see above for more information on the available signals.
 */
- (void)loadContacts;

/**
 *  Method used to filter on the contacts in the data source, each contact in the data source will be passed through
 *  the provided filterContactsBlock and this method will return contacts that pass that block
 *
 *  @param filterContactsBlock Filtering block that returns a boolean noting if the filter passed or not on the provided contact
 *
 *  @return Ordered set of contacts passing the filterContactsBlock
 */
- (NSOrderedSet<OHContact *> *)contactsPassingFilter:(FilterContactsBlock)filterContactsBlock;

/**
 *  Marks a set of contacts as selected in the data source
 *
 *  @discussion The contacts will be passed through the selection filters before being selected
 *
 *  @param contacts The contacts that will be selected
 */
- (void)selectContacts:(NSOrderedSet<OHContact *> *)contacts;

/**
 *  Unmarks a set of contacts as selected in the data source
 *
 *  @discussion The contacts will be passed through the selection filters before being deselected
 *
 *  @param contacts The contacts that will be deselected
 */
- (void)deselectContacts:(NSOrderedSet<OHContact *> *)contacts;

@end

NS_ASSUME_NONNULL_END
