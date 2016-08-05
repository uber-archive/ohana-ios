//
//  OHFuzzyMatchingUtility.h
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

NS_ASSUME_NONNULL_BEGIN

@interface OHFuzzyMatchingUtility : NSObject

/**
 *  @param contacts Set of contacts to run queries against
 */
- (instancetype)initWithContacts:(NSOrderedSet<OHContact *> *)contacts;

typedef NSInteger (^OHFuzzyScoringBlock)(NSString *query, NSString *nominee);

/**
 *  Block by which to score matches (optional)
 *
 *  @discussion If the scoringBlock is set, results will be sorted according to the highest score each contact got.
 */
@property (nonatomic, nullable) OHFuzzyScoringBlock scoringBlock;

/**
 *  Returns a copy of each contact that has full name or at least one contact field that fuzzy matches the provided query string
 *
 *  @discussion Sorted by score if scoringBlock is provided, or in their original order in allContacts if scoringBlock is nil.
 */
- (NSOrderedSet<OHContact *> *_Nullable)contactsMatchingQuery:(NSString *)query;

@end

NS_ASSUME_NONNULL_END
