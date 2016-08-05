//
//  OHCompositeAndPostProcessor.m
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

#import "OHCompositeAndPostProcessor.h"

@interface OHCompositeAndPostProcessor ()

@property (nonatomic) NSOrderedSet<id<OHContactsPostProcessorProtocol>> *postProcessors;

@end

@implementation OHCompositeAndPostProcessor

@synthesize onContactsPostProcessorFinishedSignal = _onContactsPostProcessorFinishedSignal;

- (instancetype)initWithPostProcessors:(NSOrderedSet<id<OHContactsPostProcessorProtocol>> *)postProcessors
{
    if (self = [super init]) {
        _postProcessors = postProcessors;
        _onContactsPostProcessorFinishedSignal = [[OHContactsPostProcessorFinishedSignal alloc] init];
    }
    return self;
}

#pragma mark - OHContactsPostProcessorProtocol

- (NSOrderedSet<OHContact *> *)processContacts:(NSOrderedSet<OHContact *> *)preProcessedContacts
{
    NSMutableOrderedSet<OHContact *> *processedContacts = [[NSMutableOrderedSet<OHContact *> alloc] init];

    NSOrderedSet<OHContact *> *firstPostProcessorResults = [[self.postProcessors objectAtIndex:0] processContacts:preProcessedContacts];
    if (firstPostProcessorResults.count) {
        [processedContacts unionOrderedSet:firstPostProcessorResults];
    }

    if (self.postProcessors.count > 1) {
        for (id<OHContactsPostProcessorProtocol> postProcessor in [[self.postProcessors array] subarrayWithRange:NSMakeRange(1, self.postProcessors.count - 1)]) {
            NSOrderedSet<OHContact *> *subprocessedContacts = [postProcessor processContacts:preProcessedContacts];
            if (subprocessedContacts.count) {
                [processedContacts intersectOrderedSet:subprocessedContacts];
            } else {
                processedContacts = nil;
                break;
            }
        }
    }
    _onContactsPostProcessorFinishedSignal.fire(processedContacts, self);
    return processedContacts;
}

@end
