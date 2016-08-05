//
//  OHMaximumSelectedCountSelectionFilter.m
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

#import "OHMaximumSelectedCountSelectionFilter.h"

CreateSignalImplementation(OHContactsDataSourceSelectedContactsAttemptedToExceedMaximumCountSignal, NSOrderedSet<OHContact *> *failedContacts);

@interface OHMaximumSelectedCountSelectionFilter ()

@property (nonatomic, readonly, weak) OHContactsDataSource *dataSource;
@property (nonatomic, readwrite) UBEmptySignal *onContactsDataSourceSelectedContactsReachedMaximumCountSignal;
@property (nonatomic, readwrite) OHContactsDataSourceSelectedContactsAttemptedToExceedMaximumCountSignal *onContactsDataSourceSelectedContactsAttemptedToExceedMaximumCountSignal;
@property (nonatomic, readwrite) UBEmptySignal *onContactsDataSourceSelectedContactsNoLongerAtMaximumCountSignal;

@end

@implementation OHMaximumSelectedCountSelectionFilter

- (instancetype)initWithDataSource:(OHContactsDataSource *)dataSource maximumSelectedCount:(NSUInteger)maximumSelectedCount
{
    if (self = [super init]) {
        _dataSource = dataSource;
        _maximumSelectedCount = maximumSelectedCount;
        _onContactsDataSourceSelectedContactsReachedMaximumCountSignal = [[UBEmptySignal alloc] init];
        _onContactsDataSourceSelectedContactsAttemptedToExceedMaximumCountSignal = [[OHContactsDataSourceSelectedContactsAttemptedToExceedMaximumCountSignal alloc] init];
        _onContactsDataSourceSelectedContactsNoLongerAtMaximumCountSignal = [[UBEmptySignal alloc] init];

        [dataSource.onContactsDataSourceSelectedContactsSignal addObserver:self callback:^(typeof(self) self, NSOrderedSet<OHContact *> *selectedContacts) {
            if (selectedContacts.count > 0 && self.dataSource.selectedContacts.count == self.maximumSelectedCount) {
                self.onContactsDataSourceSelectedContactsReachedMaximumCountSignal.fire();
            }
        }];

        [dataSource.onContactsDataSourceDeselectedContactsSignal addObserver:self callback:^(typeof(self) self, NSOrderedSet<OHContact *> *deselectedContacts) {
            BOOL previouslyAtMaximumCount = self.maximumSelectedCount > 0 && self.dataSource.selectedContacts.count + deselectedContacts.count == self.maximumSelectedCount;
            if (previouslyAtMaximumCount && self.dataSource.selectedContacts.count < self.maximumSelectedCount) {
                self.onContactsDataSourceSelectedContactsNoLongerAtMaximumCountSignal.fire();
            }
        }];
    }
    return self;
}

#pragma mark - OHContactsSelectionFilterProtocol

- (NSOrderedSet<OHContact *> *_Nullable)filterContactsForSelection:(NSOrderedSet<OHContact *> *)preFilteredContacts
{
    // Check if selecting the given contacts would exceed the maximum selected count, and if so fail
    if (self.maximumSelectedCount > 0 && self.dataSource.selectedContacts.count + preFilteredContacts.count > self.maximumSelectedCount) {
        int addCount = 0;
        for (OHContact *contact in preFilteredContacts) {
            if (![self.dataSource.selectedContacts containsObject:contact]) {
                addCount++;
            }
        }
        if (self.dataSource.selectedContacts.count + addCount > self.maximumSelectedCount) {
            self.onContactsDataSourceSelectedContactsAttemptedToExceedMaximumCountSignal.fire(preFilteredContacts);
            return nil;
        }
    }
    return preFilteredContacts;
}

@end
