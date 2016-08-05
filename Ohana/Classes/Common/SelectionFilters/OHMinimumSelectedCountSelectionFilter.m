//
//  OHMinimumSelectedCountSelectionFilter.m
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

#import "OHMinimumSelectedCountSelectionFilter.h"

CreateSignalImplementation(OHContactsDataSourceSelectedContactsAttemptedToDropBelowMinimumCountSignal, NSOrderedSet<OHContact *> *failedContacts);

@interface OHMinimumSelectedCountSelectionFilter ()

@property (nonatomic, readonly, weak) OHContactsDataSource *dataSource;
@property (nonatomic, readwrite) UBEmptySignal *onContactsDataSourceSelectedContactsReachedMinimumCountSignal;
@property (nonatomic, readwrite) OHContactsDataSourceSelectedContactsAttemptedToDropBelowMinimumCountSignal *onContactsDataSourceSelectedContactsAttemptedToDropBelowMinimumCountSignal;
@property (nonatomic, readwrite) UBEmptySignal *onContactsDataSourceSelectedContactsNoLongerAtMinimumCountSignal;

@end

@implementation OHMinimumSelectedCountSelectionFilter

- (instancetype)initWithDataSource:(OHContactsDataSource *)dataSource minimumSelectedCount:(NSUInteger)minimumSelectedCount
{
    if (self = [super init]) {
        _dataSource = dataSource;
        _minimumSelectedCount = minimumSelectedCount;
        _onContactsDataSourceSelectedContactsReachedMinimumCountSignal = [[UBEmptySignal alloc] init];
        _onContactsDataSourceSelectedContactsAttemptedToDropBelowMinimumCountSignal = [[OHContactsDataSourceSelectedContactsAttemptedToDropBelowMinimumCountSignal alloc] init];
        _onContactsDataSourceSelectedContactsNoLongerAtMinimumCountSignal = [[UBEmptySignal alloc] init];

        [dataSource.onContactsDataSourceDeselectedContactsSignal addObserver:self callback:^(typeof(self) self, NSOrderedSet<OHContact *> *deselectedContacts) {
            if (deselectedContacts.count > 0 && self.dataSource.selectedContacts.count == self.minimumSelectedCount) {
                self.onContactsDataSourceSelectedContactsReachedMinimumCountSignal.fire();
            }
        }];

        [dataSource.onContactsDataSourceSelectedContactsSignal addObserver:self callback:^(typeof(self) self, NSOrderedSet<OHContact *> *selectedContacts) {
            BOOL previouslyAtMinimumCount = self.dataSource.selectedContacts.count - selectedContacts.count == self.minimumSelectedCount;
            if (previouslyAtMinimumCount && self.dataSource.selectedContacts.count > self.minimumSelectedCount) {
                self.onContactsDataSourceSelectedContactsNoLongerAtMinimumCountSignal.fire();
            }
        }];
    }
    return self;
}

#pragma mark - OHContactsSelectionFilterProtocol

- (NSOrderedSet<OHContact *> *_Nullable)filterContactsForDeselection:(NSOrderedSet<OHContact *> *)preFilteredContacts
{
    // Check if deselecting the given contacts would drop below the minimum selected count, and if so fail
    if (self.dataSource.selectedContacts.count - preFilteredContacts.count < self.minimumSelectedCount) {
        int subCount = 0;
        for (OHContact *contact in preFilteredContacts) {
            if ([self.dataSource.selectedContacts containsObject:contact]) {
                subCount++;
            }
        }
        if (self.dataSource.selectedContacts.count - subCount < self.minimumSelectedCount) {
            self.onContactsDataSourceSelectedContactsAttemptedToDropBelowMinimumCountSignal.fire(preFilteredContacts);
            return nil;
        }
    }
    return preFilteredContacts;
}

@end
