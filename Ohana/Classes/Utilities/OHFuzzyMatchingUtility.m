//
//  OHFuzzyMatchingUtility.m
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

#import "OHFuzzyMatchingUtility.h"

@interface OHContactMatchNominee : NSObject

@property (nonatomic) NSString *valueString;
@property (nonatomic) OHContact *contact;

@end

@implementation OHContactMatchNominee

@end

@interface OHFuzzyMatchingUtility ()

@property (nonatomic) NSOrderedSet<OHContactMatchNominee *> *matchNominees;

@end

@implementation OHFuzzyMatchingUtility

- (instancetype)initWithContacts:(NSOrderedSet<OHContact *> *)contacts
{
    if (self = [super init]) {
        NSMutableOrderedSet<OHContactMatchNominee *> *matchNominees = [[NSMutableOrderedSet<OHContactMatchNominee *> alloc] init];
        for (OHContact *contact in contacts) {
            if (contact.fullName.length) {
                OHContactMatchNominee *matchNominee = [[OHContactMatchNominee alloc] init];
                matchNominee.valueString = contact.fullName;
                matchNominee.contact = contact;
                [matchNominees addObject:matchNominee];
            }

            for (OHContactField *contactField in contact.contactFields) {
                if (contactField.value.length) {
                    OHContactMatchNominee *matchNominee = [[OHContactMatchNominee alloc] init];
                    matchNominee.valueString = contactField.value;
                    matchNominee.contact = contact;
                    [matchNominees addObject:matchNominee];
                }
            }
        }
        self.matchNominees = matchNominees;
    }
    return self;
}

- (NSOrderedSet<OHContact *> *)contactsMatchingQuery:(NSString *)originalQuery
{
    if (!originalQuery.length) {
        return nil;
    }

    NSString *query = [self _fuzzyQueryFromQuery:originalQuery];

    NSUInteger index = 0;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:query options:NSRegularExpressionCaseInsensitive error:NULL];
    NSMapTable<OHContact *, NSNumber *> *contactScores = [[NSMapTable<OHContact *, NSNumber *> alloc] initWithKeyOptions:NSMapTableStrongMemory valueOptions:NSMapTableStrongMemory capacity:self.matchNominees.count];
    for (OHContactMatchNominee *nominee in self.matchNominees) {
        if ([regex firstMatchInString:nominee.valueString options:0 range:NSMakeRange(0, nominee.valueString.length)]) {
            if (self.scoringBlock) {
                NSInteger score = self.scoringBlock(originalQuery, nominee.valueString);
                NSNumber *existingScore = [contactScores objectForKey:nominee.contact];
                if (!existingScore || score > [existingScore integerValue]) {
                    [contactScores setObject:@(score) forKey:nominee.contact];
                }
            } else {
                [contactScores setObject:@(index++) forKey:nominee.contact];
            }
        }
    }

    return [NSOrderedSet orderedSetWithArray:[[[contactScores keyEnumerator] allObjects] sortedArrayUsingComparator:^NSComparisonResult(OHContact *obj1, OHContact *obj2) {
        if (self.scoringBlock) {
            return [[contactScores objectForKey:obj2] compare:[contactScores objectForKey:obj1]];
        } else {
            return [[contactScores objectForKey:obj1] compare:[contactScores objectForKey:obj2]];
        }
    }]];
}

#pragma mark - Private

- (NSString *)_fuzzyQueryFromQuery:(NSString *)query
{
    NSMutableArray *characters = [[NSMutableArray alloc] initWithCapacity:[query length]];
    [query enumerateSubstringsInRange:NSMakeRange(0, query.length)
                              options:NSStringEnumerationByComposedCharacterSequences
                           usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                               [characters addObject:substring];
                           }];
    return [characters componentsJoinedByString:@".*?"];
}

@end
