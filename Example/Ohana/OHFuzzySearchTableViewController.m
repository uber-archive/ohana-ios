//
//  OHFuzzySearchTableViewController.m
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

#import "OHFuzzySearchTableViewController.h"

#import <Ohana/Ohana.h>

@interface OHFuzzySearchTableViewController () <OHCNContactsDataProviderDelegate, OHABAddressBookContactsDataProviderDelegate, UISearchResultsUpdating>

@property (nonatomic) OHContactsDataSource *dataSource;

@property (nonatomic) UISearchController *searchController;
@property (nonatomic) OHFuzzyMatchingUtility *fuzzyMatchingUtility;
@property (nonatomic) NSOrderedSet<OHContact *> *searchResults;

@end

@implementation OHFuzzySearchTableViewController

- (instancetype)init
{
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
        [self.searchController setSearchResultsUpdater:self];
        [self.searchController setDimsBackgroundDuringPresentation:NO];
        [self.tableView setTableHeaderView:self.searchController.searchBar];

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

        [self.dataSource.onContactsDataSourceReadySignal addObserver:self callback:^(typeof(self) self, NSOrderedSet<OHContact *> * _Nonnull contacts) {
            self.fuzzyMatchingUtility = [[OHFuzzyMatchingUtility alloc] initWithContacts:self.dataSource.contacts];
            dispatch_async(dispatch_get_main_queue(), ^(){
                [self.tableView reloadData];
            });
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
                                                                      if (self.searchController.searchBar.text.length) {
                                                                          [self.searchController dismissViewControllerAnimated:YES completion:nil];
                                                                          [self.searchController.searchBar setText:nil];
                                                                          [self.tableView reloadData];
                                                                      } else {
                                                                          [self dismissViewControllerAnimated:YES completion:nil];
                                                                      }

                                                                  }]];

                if (self.searchController.searchBar.text.length) {
                    [self.searchController presentViewController:alertController animated:YES completion:nil];
                } else {
                    [self presentViewController:alertController animated:YES completion:nil];
                }
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
    if (self.searchController.searchBar.text.length) {
        return self.searchResults.count;
    } else if (self.dataSource.contacts) {
        return self.dataSource.contacts.count;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ContactCell"];

    if (self.searchController.searchBar.text.length) {
        OHContact *contact = [self.searchResults objectAtIndex:indexPath.row];
        cell.textLabel.attributedText = [self _attributedStringForString:[self _displayTitleForContact:contact] withSearchQuery:self.searchController.searchBar.text];
        cell.detailTextLabel.attributedText = [self _attributedStringForString:[self _displaySubtitleForContact:contact] withSearchQuery:self.searchController.searchBar.text];
    } else if (self.dataSource.contacts) {
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
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    OHContact *contact;
    if (self.searchController.searchBar.text.length) {
        contact = [self.searchResults objectAtIndex:indexPath.row];
    } else if (self.dataSource.contacts) {
        contact = [self.dataSource.contacts objectAtIndex:indexPath.row];
    } else {
        return;
    }

    [self.dataSource selectContacts:[NSOrderedSet orderedSetWithObject:contact]];
    [self.dataSource deselectContacts:[NSOrderedSet orderedSetWithObject:contact]];
}

#pragma mark - OHCNContactsDataProviderDelegate

- (void)dataProviderDidHitContactsAuthenticationChallenge:(OHCNContactsDataProvider *)dataProvider
{
    CNContactStore *contactStore = [[CNContactStore alloc] init];
    [contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError *_Nullable error) {
        if (granted) {
            [dataProvider loadContacts];
        }
    }];
}

#pragma mark - OHABAddressBookContactsDataProviderDelegate

- (void)dataProviderDidHitAddressBookAuthenticationChallenge:(OHABAddressBookContactsDataProvider *)dataProvider
{
    ABAddressBookRequestAccessWithCompletion(nil, ^(bool granted, CFErrorRef error) {
        if (granted) {
            [dataProvider loadContacts];
        }
    });
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    self.searchResults = [self.fuzzyMatchingUtility contactsMatchingQuery:self.searchController.searchBar.text];
    [self.tableView reloadData];
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

- (NSAttributedString *)_attributedStringForString:(NSString *)string withSearchQuery:(NSString *)query
{
    if (string == nil || query == nil) {
        return nil;
    }

    NSMutableArray *queryCharacters = [[NSMutableArray alloc] initWithCapacity:[query length]];
    [query enumerateSubstringsInRange:NSMakeRange(0, query.length)
                              options:NSStringEnumerationByComposedCharacterSequences
                           usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                               [queryCharacters addObject:substring];
                           }];

    NSMutableAttributedString *boldedResultsString = [[NSMutableAttributedString alloc] initWithString:string];

    NSUInteger startIndex = 0;
    for (NSString *character in queryCharacters) {
        NSRange highlightRange = [string rangeOfString:character options:NSCaseInsensitiveSearch range:NSMakeRange(startIndex, string.length - startIndex)];
        if (highlightRange.location == NSNotFound) {
            return [[NSAttributedString alloc] initWithString:string];
        }
        [boldedResultsString addAttribute:NSBackgroundColorAttributeName value:[UIColor colorWithRed:210.0f / 255.0f green:241.0f / 255.0f blue:247.0f / 255.0f alpha:1.0f] range:highlightRange];
        startIndex = highlightRange.location + 1;
    }
    
    return boldedResultsString;
}

@end
