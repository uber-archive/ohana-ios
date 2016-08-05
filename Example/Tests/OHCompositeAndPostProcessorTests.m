//
//  OHCompositeAndPostProcessorTests.m
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

#import <XCTest/XCTest.h>
#import <Ohana/Ohana.h>
#import <OCMock/OCMock.h>

#import "NSOrderedSetMake+Internal.h"

@interface OHCompositeAndPostProcessorTests : XCTestCase

@property (nonatomic) NSOrderedSet<OHContact *> *testContacts;

@end

@implementation OHCompositeAndPostProcessorTests

- (void)setUp
{
    [super setUp];

    self.testContacts = NSOrderedSetMake([[OHContact alloc] init], [[OHContact alloc] init], [[OHContact alloc] init]);
}

- (void)testCompositeAndNoOverlap
{
    __block NSOrderedSet<OHContact *> *arrayContactA = NSOrderedSetMake(self.testContacts[0]);
    __block NSOrderedSet<OHContact *> *arrayContactB = NSOrderedSetMake(self.testContacts[1]);

    id<OHContactsPostProcessorProtocol> processorA = OCMProtocolMock(@protocol(OHContactsPostProcessorProtocol));
    OCMStub([processorA processContacts:OCMOCK_ANY]).andDo(^(NSInvocation *invocation) {
        [invocation setReturnValue:&arrayContactA];
    });

    id<OHContactsPostProcessorProtocol> processorB = OCMProtocolMock(@protocol(OHContactsPostProcessorProtocol));
    OCMStub([processorB processContacts:OCMOCK_ANY]).andDo(^(NSInvocation *invocation) {
        [invocation setReturnValue:&arrayContactB];
    });

    OHCompositeAndPostProcessor *compositeProcessor = [[OHCompositeAndPostProcessor alloc] initWithPostProcessors:NSOrderedSetMake(processorA, processorB)];

    NSOrderedSet<OHContact *> *result = [compositeProcessor processContacts:self.testContacts];
    NSOrderedSet<OHContact *> *expectedResult = [NSOrderedSet orderedSet];
    XCTAssert([result isEqualToOrderedSet:expectedResult]);
}

- (void)testCompositeAndWithOverlap
{
    __block NSOrderedSet<OHContact *> *arrayContactAB = NSOrderedSetMake(self.testContacts[0], self.testContacts[1]);
    __block NSOrderedSet<OHContact *> *arrayContactBC = NSOrderedSetMake(self.testContacts[1], self.testContacts[2]);

    id<OHContactsPostProcessorProtocol> processorA = OCMProtocolMock(@protocol(OHContactsPostProcessorProtocol));
    OCMStub([processorA processContacts:OCMOCK_ANY]).andDo(^(NSInvocation *invocation) {
        [invocation setReturnValue:&arrayContactAB];
    });

    id<OHContactsPostProcessorProtocol> processorB = OCMProtocolMock(@protocol(OHContactsPostProcessorProtocol));
    OCMStub([processorB processContacts:OCMOCK_ANY]).andDo(^(NSInvocation *invocation) {
        [invocation setReturnValue:&arrayContactBC];
    });

    OHCompositeAndPostProcessor *compositeProcessor = [[OHCompositeAndPostProcessor alloc] initWithPostProcessors:NSOrderedSetMake(processorA, processorB)];

    NSOrderedSet<OHContact *> *result = [compositeProcessor processContacts:self.testContacts];
    NSOrderedSet<OHContact *> *expectedResult = NSOrderedSetMake(self.testContacts[1]);
    XCTAssert([result isEqualToOrderedSet:expectedResult]);
}

- (void)testNoDuplication
{
    __block NSOrderedSet<OHContact *> *arrayContactA = NSOrderedSetMake(self.testContacts[0]);

    id<OHContactsPostProcessorProtocol> processorA = OCMProtocolMock(@protocol(OHContactsPostProcessorProtocol));
    OCMStub([processorA processContacts:OCMOCK_ANY]).andDo(^(NSInvocation *invocation) {
        [invocation setReturnValue:&arrayContactA];
    });

    id<OHContactsPostProcessorProtocol> processorB = OCMProtocolMock(@protocol(OHContactsPostProcessorProtocol));
    OCMStub([processorB processContacts:OCMOCK_ANY]).andDo(^(NSInvocation *invocation) {
        [invocation setReturnValue:&arrayContactA];
    });

    OHCompositeAndPostProcessor *compositeProcessor = [[OHCompositeAndPostProcessor alloc] initWithPostProcessors:NSOrderedSetMake(processorA, processorB)];

    NSOrderedSet<OHContact *> *result = [compositeProcessor processContacts:self.testContacts];
    NSOrderedSet<OHContact *> *expectedResult = NSOrderedSetMake(self.testContacts[0]);
    XCTAssert([result isEqualToOrderedSet:expectedResult]);
}

@end
