//
//  OHContactsPostProcessorProtocol.h
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

NS_ASSUME_NONNULL_BEGIN

@protocol OHContactsPostProcessorProtocol;

/**
 *  Signal to be fired after the contacts post processor has finished its work
 *
 *  @param processedContacts The contacts returned by the post processor
 *  @param postProcessor The post processor that has finished processing
 */
CreateSignalInterface(OHContactsPostProcessorFinishedSignal, NSOrderedSet<OHContact *> *processedContacts, id<OHContactsPostProcessorProtocol> postProcessor);

@protocol OHContactsPostProcessorProtocol <NSObject>

/**
 *  Signal to be fired after the contacts post processor has finished its work (see signal definition)
 */
@property (nonatomic, readonly) OHContactsPostProcessorFinishedSignal *onContactsPostProcessorFinishedSignal;

/**
 *  The main method of any post processor, this method does the actual post processing on the contact data
 *
 *  @discussion The post processor may add, remove, or modify contacts passed into it.
 *
 *  @param preProcessedContacts The contacts to be run through the post processor
 *
 *  @return The contacts processed by the post processor
 */
- (NSOrderedSet<OHContact *> *_Nullable)processContacts:(NSOrderedSet<OHContact *> *)preProcessedContacts;

@end

NS_ASSUME_NONNULL_END
