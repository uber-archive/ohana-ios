//
//  OHContactAddress.m
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

#import "OHContactAddress.h"

@interface OHContactAddress ()

@property (nonatomic, readwrite) NSMutableSet<NSString *> *tags;
@property (nonatomic, readwrite) NSMutableDictionary<NSString *, id> *customProperties;

@end

@implementation OHContactAddress

- (instancetype)initWithLabel:(NSString *)label street:(NSString *)street city:(NSString *)city state:(NSString *)state postalCode:(NSString *)postalCode country:(NSString *)country dataProviderIdentifier:(NSString *)dataProviderIdentifier
{
    if (self = [super init]) {
        _label = label;
        _street = street;
        _city = city;
        _state = state;
        _postalCode = postalCode;
        _country = country;
        _dataProviderIdentifier = dataProviderIdentifier;
    }
    return self;
}

- (instancetype)initWithLabel:(NSString *)label street:(NSString *)street city:(NSString *)city state:(NSString *)state postalCode:(NSString *)postalCode country:(NSString *)country dataProviderIdentifier:(NSString *)dataProviderIdentifier tags:(NSMutableSet<NSString *> *)tags customProperties:(NSMutableDictionary<NSString *, id> *)customProperties
{
    if (self = [self initWithLabel:label street:street city:city state:state postalCode:postalCode country:country dataProviderIdentifier:dataProviderIdentifier]) {
        _tags = tags;
        _customProperties = customProperties;
    }
    return self;
}

#pragma mark - Properties

- (NSMutableSet<NSString *> *)tags
{
    if (!_tags) {
        _tags = [[NSMutableSet<NSString *> alloc] init];
    }
    return _tags;
}

- (NSMutableDictionary<NSString *, id> *)customProperties
{
    if (!_customProperties) {
        _customProperties = [[NSMutableDictionary<NSString *, id> alloc] init];
    }
    return _customProperties;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    return [[OHContactAddress alloc] initWithLabel:[self.label copy] street:[self.street copy] city:[self.city copy] state:[self.state copy] postalCode:[self.postalCode copy] country:[self.country copy] dataProviderIdentifier:[self.dataProviderIdentifier copy] tags:[self.tags copy] customProperties:[self.customProperties copy]];
}

#pragma mark - Equality

- (BOOL)isEqualToContactAddress:(OHContactAddress *)contactAddress
{
    return  [self.label isEqualToString:contactAddress.label] &&
            [self.street isEqualToString:contactAddress.street] &&
            [self.city isEqualToString:contactAddress.city] &&
            [self.state isEqualToString:contactAddress.state] &&
            [self.postalCode isEqualToString:contactAddress.postalCode] &&
            [self.country isEqualToString:contactAddress.country] &&
            [self.dataProviderIdentifier isEqualToString:contactAddress.dataProviderIdentifier] &&
            [self.tags isEqualToSet:contactAddress.tags] &&
            [self.customProperties isEqualToDictionary:contactAddress.customProperties];
}

@end
