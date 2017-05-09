//
//  OHCNContactsDataProvider.h
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

#import <Contacts/Contacts.h>

#import "OHContactsDataProviderProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class OHCNContactsDataProvider;

NS_CLASS_AVAILABLE_IOS(9_0)
@protocol OHCNContactsDataProviderDelegate <NSObject>

- (void)dataProviderHitCNContactsAuthChallenge:(OHCNContactsDataProvider *)dataProvider requiresUserAuthentication:(void (^)())userAuthenticationTrigger;

@end

NS_CLASS_AVAILABLE_IOS(9_0)
@interface OHCNContactsDataProvider : NSObject <OHContactsDataProviderProtocol>

extern NSString *kOHCNContactsDataProviderContactIdentifierKey;  // Identifier unique among contacts on the device (NSString *)

/**
 *  By default, the data provider does not load a thumbnail image to conserve space. Set this to `YES` to load thumbnail image.
 */
@property (nonatomic) BOOL loadThumbnailImage;

- (instancetype)initWithDelegate:(id<OHCNContactsDataProviderDelegate>)delegate NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

+ (OHCNContactsDataProvider *)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
