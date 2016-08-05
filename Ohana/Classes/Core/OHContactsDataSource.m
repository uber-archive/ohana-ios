//
//  OHContactsDataSource.m
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

#import "OHContactsDataSource.h"

CreateSignalImplementation(OHContactsDataSourceSelectedContactsSignal, NSSet<OHContact *> *selectedContacts);

CreateSignalImplementation(OHContactsDataSourceDeselectedContactsSignal, NSSet<OHContact *> *deselectedContacts);

@interface OHContactsDataSource ()

/**
 *  Read-only public properties
 */
@property (nonatomic, readwrite) NSOrderedSet<id<OHContactsDataProviderProtocol>> *dataProviders;
@property (nonatomic, readwrite, nullable) NSOrderedSet<id<OHContactsPostProcessorProtocol>> *postProcessors;
@property (nonatomic, readwrite) UBEmptySignal *onContactsDataSourceLoadedProvidersSignal;
@property (nonatomic, readwrite) UBEmptySignal *onContactsDataSourcePostProcessorsFinishedSignal;
@property (nonatomic, readwrite) UBEmptySignal *onContactsDataSourceReadySignal;
@property (nonatomic, readwrite) OHContactsDataSourceSelectedContactsSignal *onContactsDataSourceSelectedContactsSignal;
@property (nonatomic, readwrite) OHContactsDataSourceDeselectedContactsSignal *onContactsDataSourceDeselectedContactsSignal;
@property (nonatomic, readwrite, nullable) NSOrderedSet<OHContact *> *contacts;
@property (nonatomic, readwrite) NSMutableOrderedSet<OHContact *> *selectedContacts;

/**
 *  Used internally to store contacts while processing. Use the contacts property externally.
 */
@property (nonatomic) NSMutableOrderedSet<OHContact *> *allContacts;

@property (nonatomic, readwrite) NSMutableSet<id<OHContactsDataProviderProtocol>> *completedDataProviders;

@property (nonatomic, readwrite) NSMutableSet<id<OHContactsPostProcessorProtocol>> *completedPostProcessors;

@end

@implementation OHContactsDataSource

- (instancetype)initWithDataProviders:(NSOrderedSet<id<OHContactsDataProviderProtocol>> *)dataProviders postProcessors:(NSOrderedSet<id<OHContactsPostProcessorProtocol>> *_Nullable)postProcessors
{
    if (dataProviders.count == 0) {
        [NSException raise:@"UBDataSource must have at least 1 data provider" format:@"%@", self];
    }
    if (self = [super init]) {
        _dataProviders = dataProviders;
        _postProcessors = postProcessors;

        _onContactsDataSourceLoadedProvidersSignal = [[UBEmptySignal alloc] init];
        _onContactsDataSourcePostProcessorsFinishedSignal = [[UBEmptySignal alloc] init];
        _onContactsDataSourceReadySignal = [[UBEmptySignal alloc] init];
        _onContactsDataSourceSelectedContactsSignal = [[OHContactsDataSourceSelectedContactsSignal alloc] init];
        _onContactsDataSourceDeselectedContactsSignal = [[OHContactsDataSourceDeselectedContactsSignal alloc] init];

        _allContacts = [[NSMutableOrderedSet<OHContact *> alloc] init];
        _selectedContacts = [[NSMutableOrderedSet alloc] init];


        _completedDataProviders = [[NSMutableSet<id<OHContactsDataProviderProtocol>> alloc] initWithCapacity:dataProviders.count];
        _completedPostProcessors = [[NSMutableSet<id<OHContactsPostProcessorProtocol>> alloc] initWithCapacity:postProcessors.count];

        // Iterate over data providers and subscribe to their onDataProviderFinishedLoadingSignal
        for (id<OHContactsDataProviderProtocol> dataProvider in _dataProviders) {
            // Add onFinishedLoadingSignal observers on each data provider
            [self _setupOnDataProviderFinishedLoadingSignalObserverForDataProvider:dataProvider];
        }
    }
    return self;
}

- (instancetype)initWithDataProviders:(NSOrderedSet<id<OHContactsDataProviderProtocol>> *)dataProviders postProcessors:(NSOrderedSet<id<OHContactsPostProcessorProtocol>> *)postProcessors selectionFilters:(NSOrderedSet<id<OHContactsSelectionFilterProtocol>> *)selectionFilters
{
    if (self = [self initWithDataProviders:dataProviders postProcessors:postProcessors]) {
        _selectionFilters = selectionFilters;
    }
    return self;
}

- (void)loadContacts
{
    for (id<OHContactsDataProviderProtocol> dataProvider in self.dataProviders) {
        [dataProvider loadContacts];
    }
}

- (NSOrderedSet<OHContact *> *)contactsPassingFilter:(FilterContactsBlock)filterContactsBlock
{
    NSMutableOrderedSet<OHContact *> *filteredContacts = [[NSMutableOrderedSet<OHContact *> alloc] init];
    for (OHContact *contact in self.contacts) {
        if (filterContactsBlock(contact)) {
            [filteredContacts addObject:contact];
        }
    }
    return filteredContacts;
}

- (void)selectContacts:(NSOrderedSet<OHContact *> *)contacts
{
    NSMutableOrderedSet *mutableContacts = [contacts mutableCopy];
    [mutableContacts minusOrderedSet:self.selectedContacts];
    contacts = mutableContacts;

    for (id<OHContactsSelectionFilterProtocol> selectionFilter in self.selectionFilters) {
        if ([selectionFilter respondsToSelector:@selector(filterContactsForSelection:)]) {
            contacts = [selectionFilter filterContactsForSelection:contacts];
        }
    }

    if (contacts.count) {
        [_selectedContacts unionOrderedSet:contacts];

        self.onContactsDataSourceSelectedContactsSignal.fire(contacts);
    }
}

- (void)deselectContacts:(NSOrderedSet<OHContact *> *)contacts;
{
    NSMutableOrderedSet *mutableContacts = [contacts mutableCopy];
    [mutableContacts intersectOrderedSet:self.selectedContacts];
    contacts = mutableContacts;

    for (id<OHContactsSelectionFilterProtocol> selectionFilter in self.selectionFilters) {
        if ([selectionFilter respondsToSelector:@selector(filterContactsForDeselection:)]) {
            contacts = [selectionFilter filterContactsForDeselection:contacts];
        }
    }

    if (contacts.count) {
        [_selectedContacts minusOrderedSet:contacts];

        self.onContactsDataSourceDeselectedContactsSignal.fire(contacts);
    }
}

#pragma mark - Private

- (void)_setupOnDataProviderFinishedLoadingSignalObserverForDataProvider:(id<OHContactsDataProviderProtocol>)dataProvider
{
    [dataProvider.onContactsDataProviderFinishedLoadingSignal addObserver:self callback:^(typeof(self) self, id<OHContactsDataProviderProtocol> dataProvider) {
        [self.allContacts unionOrderedSet:dataProvider.contacts];
        [self.completedDataProviders addObject:dataProvider];
        if (self.completedDataProviders.count == self.dataProviders.count) {
            // If we have loaded all our providers we can start firing our post processors
            self.onContactsDataSourceLoadedProvidersSignal.fire();

            if (self.postProcessors.count) {
                NSOrderedSet *postProcessedContacts = self.allContacts;
                for (id<OHContactsPostProcessorProtocol> postProcessor in self.postProcessors) {
                    postProcessedContacts = [postProcessor processContacts:postProcessedContacts];
                }
                self.contacts = postProcessedContacts;
                self.onContactsDataSourcePostProcessorsFinishedSignal.fire();
            } else {
                self.contacts = self.allContacts;
            }

            self.onContactsDataSourceReadySignal.fire();
        }
    }];
}

@end
