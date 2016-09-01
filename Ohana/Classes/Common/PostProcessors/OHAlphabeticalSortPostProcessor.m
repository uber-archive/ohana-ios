//
//  OHAlphabeticalSortPostProcessor.m
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

#import "OHAlphabeticalSortPostProcessor.h"

@interface OHAlphabeticalSortPostProcessor ()

@property (nonatomic, readwrite) OHAlphabeticalSortPostProcessorSortMode sortMode;

@end

@implementation OHAlphabeticalSortPostProcessor

@synthesize onContactsPostProcessorFinishedSignal = _onContactsPostProcessorFinishedSignal;

- (instancetype)initWithSortMode:(OHAlphabeticalSortPostProcessorSortMode)sortMode
{
    if (self = [super init]) {
        _onContactsPostProcessorFinishedSignal = [[OHContactsPostProcessorFinishedSignal alloc] init];
        _sortMode = sortMode;
    }
    return self;
}

#pragma mark - OHContactsPostProcessorProtocol

- (NSOrderedSet<OHContact *> *)processContacts:(NSOrderedSet<OHContact *> *)preProcessedContacts
{
    NSOrderedSet<OHContact *> *processedContacts = [NSOrderedSet orderedSetWithArray:[preProcessedContacts sortedArrayUsingComparator:^NSComparisonResult(OHContact *contact1, OHContact *contact2) {
        if (![self _comparableFieldForContact:contact1].length) {
            return [self _comparableFieldForContact:contact2].length ? NSOrderedDescending : [self _secondaryComparisonOfContact:contact1 againstContact:contact2];
        } else if (![self _comparableFieldForContact:contact2].length) {
            return NSOrderedAscending;
        }
        NSComparisonResult comparison = [[self _comparableFieldForContact:contact1] compare:[self _comparableFieldForContact:contact2]];
        if (comparison == NSOrderedSame) {
            comparison = [self _secondaryComparisonOfContact:contact1 againstContact:contact2];
        }
        return comparison;
    }]];
    self.onContactsPostProcessorFinishedSignal.fire(processedContacts, self);
    return processedContacts;
}

- (NSComparisonResult)_secondaryComparisonOfContact:(OHContact *)contact1 againstContact:(OHContact *)contact2
{
    if (![self _secondaryComparableFieldForContact:contact1].length) {
        return [self _secondaryComparableFieldForContact:contact2].length ? NSOrderedDescending : NSOrderedSame;
    } else if (![self _secondaryComparableFieldForContact:contact2].length) {
        return NSOrderedAscending;
    }
    return [[self _secondaryComparableFieldForContact:contact1] compare:[self _secondaryComparableFieldForContact:contact2]];
}

- (NSString *)_comparableFieldForContact:(OHContact *)contact
{
    switch (self.sortMode) {
        case OHAlphabeticalSortPostProcessorSortModeFullName:
            return contact.fullName;
        case OHAlphabeticalSortPostProcessorSortModeFirstName:
            return contact.firstName;
        case OHAlphabeticalSortPostProcessorSortModeLastName:
            return contact.lastName;
    }
}

- (NSString *)_secondaryComparableFieldForContact:(OHContact *)contact {
    switch (self.sortMode) {
        case OHAlphabeticalSortPostProcessorSortModeFullName:
            return contact.fullName;
        case OHAlphabeticalSortPostProcessorSortModeFirstName:
            return contact.lastName;
        case OHAlphabeticalSortPostProcessorSortModeLastName:
            return contact.firstName;
    }
}

@end
