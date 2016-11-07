//
//  OHPhoneNumberPickerTableViewController.m
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

#import "OHPhoneNumberPickerTableViewController.h"

#import <Ohana/Ohana.h>

@interface OHPhoneNumberPickerTableViewController () <OHCNContactsDataProviderDelegate, OHABAddressBookContactsDataProviderDelegate>

@property (nonatomic) OHContactsDataSource *dataSource;

@end

@implementation OHPhoneNumberPickerTableViewController

- (instancetype)init
{
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        id<OHContactsDataProviderProtocol> dataProvider;
        if ([CNContact class]) {
            dataProvider = [[OHCNContactsDataProvider alloc] initWithDelegate:self];
        } else {
            dataProvider = [[OHABAddressBookContactsDataProvider alloc] initWithDelegate:self];
        }

        OHAlphabeticalSortPostProcessor *alphabeticalSortProcessor = [[OHAlphabeticalSortPostProcessor alloc] initWithSortMode:OHAlphabeticalSortPostProcessorSortModeFullName];

        OHSplitOnFieldTypePostProcessor *splitOnPhoneProcessor = [[OHSplitOnFieldTypePostProcessor alloc] initWithFieldType:OHContactFieldTypePhoneNumber];

        _dataSource = [[OHContactsDataSource alloc] initWithDataProviders:[NSOrderedSet orderedSetWithObjects:dataProvider, nil]
                                                           postProcessors:[NSOrderedSet orderedSetWithObjects:alphabeticalSortProcessor, splitOnPhoneProcessor, nil]];

        [self.dataSource.onContactsDataSourceReadySignal addObserver:self callback:^(typeof(self) self) {
            [self.tableView reloadData];
        }];

        [self.dataSource.onContactsDataSourceSelectedContactsSignal addObserver:self callback:^(typeof(self) self, NSOrderedSet<OHContact *> * _Nonnull selectedContacts) {
            for (OHContact *contact in selectedContacts) {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Selected Contact"
                                                                                         message:[NSString stringWithFormat:@"%@\n%@",
                                                                                                    contact.fullName ? contact.fullName : @"Unnamed Contact",
                                                                                                    contact.contactFields[0].value]
                                                                                  preferredStyle:UIAlertControllerStyleAlert];

                [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                                    style:UIAlertActionStyleCancel
                                                                  handler:^(UIAlertAction * _Nonnull action) {
                                                                      [self dismissViewControllerAnimated:YES completion:nil];
                                                                  }]];

                [self presentViewController:alertController animated:YES completion:nil];
            }
        }];
        
        [self.dataSource loadContacts];
    }
    return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.dataSource.contacts) {
        return self.dataSource.contacts.count;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ContactCell"];

    if (self.dataSource.contacts) {
        OHContact *contact = [self.dataSource.contacts objectAtIndex:indexPath.row];
        cell.textLabel.text = [self _displayTitleForContact:contact];
        cell.detailTextLabel.text = [self _displaySubtitleForContact:contact];
    } else {
        cell.textLabel.text = @"No contacts access, open Settings app to fix this";
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.dataSource.contacts) {
        OHContact *contact = [self.dataSource.contacts objectAtIndex:indexPath.row];

        [self.dataSource selectContacts:[NSOrderedSet orderedSetWithObject:contact]];
        [self.dataSource deselectContacts:[NSOrderedSet orderedSetWithObject:contact]];
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - OHCNContactsDataProviderDelegate

- (void)dataProviderHitCNContactsAuthChallenge:(OHCNContactsDataProvider *)dataProvider requiresUserAuthentication:(void (^)())userAuthenticationTrigger
{
    userAuthenticationTrigger();
}

#pragma mark - OHABAddressBookContactsDataProviderDelegate

- (void)dataProviderHitABAddressBookAuthChallenge:(OHABAddressBookContactsDataProvider *)dataProvider requiresUserAuthentication:(void (^)())userAuthenticationTrigger
{
    userAuthenticationTrigger();
}

#pragma mark - Private

- (NSString *)_displayTitleForContact:(OHContact *)contact
{
    if (contact.fullName.length) {
        return contact.fullName;
    }
    if (contact.contactFields.count) {
        return [contact.contactFields objectAtIndex:0].value;
    }
    return nil;
}

- (NSString *)_displaySubtitleForContact:(OHContact *)contact
{
    if (contact.fullName.length && contact.contactFields.count) {
        return [contact.contactFields objectAtIndex:0].value;
    }
    return nil;
}

@end
