//
//  OHContactSelectionTableViewController.m
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

#import "OHContactSelectionTableViewController.h"

#import <Ohana/Ohana.h>

@interface OHContactSelectionTableViewController () <OHCNContactsDataProviderDelegate, OHABAddressBookContactsDataProviderDelegate>

@property (nonatomic) OHContactsDataSource *dataSource;

@property (nonatomic) NSDictionary<NSString *, NSOrderedSet<OHContact *> *> *contactsByLetter;
@property (nonatomic) NSMutableOrderedSet<NSString *> *sections;

@end

@implementation OHContactSelectionTableViewController

- (instancetype)init
{
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        _sections = [[NSMutableOrderedSet<NSString *> alloc] init];

        [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"ContactCell"];

        id<OHContactsDataProviderProtocol> dataProvider;
        if ([CNContact class]) {
            dataProvider = [[OHCNContactsDataProvider alloc] initWithDelegate:self];
        } else {
            dataProvider = [[OHABAddressBookContactsDataProvider alloc] initWithDelegate:self];
        }

        OHAlphabeticalSortPostProcessor *alphabeticalSortProcessor = [[OHAlphabeticalSortPostProcessor alloc] initWithSortMode:OHAlphabeticalSortPostProcessorSortModeFullName];

        _dataSource = [[OHContactsDataSource alloc] initWithDataProviders:[NSOrderedSet orderedSetWithObjects:dataProvider, nil]
                                                           postProcessors:[NSOrderedSet orderedSetWithObjects:alphabeticalSortProcessor, nil]];

        [self.dataSource.onContactsDataSourceReadySignal addObserver:self callback:^(typeof(self) self, NSOrderedSet<OHContact *> * _Nonnull contacts) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.contactsByLetter = [self _contactsByLetterDictionaryForContacts:self.dataSource.contacts];
                [self.tableView reloadData];
            });
        }];

        [self.dataSource.onContactsDataSourceSelectedContactsSignal addObserver:self callback:^(typeof(self) self, NSOrderedSet<OHContact *> * _Nonnull selectedContacts) {
            if (self.dataSource.contacts.count == self.dataSource.selectedContacts.count) {
                self.navigationItem.rightBarButtonItem.title = @"DESELECT ALL";
                self.navigationItem.rightBarButtonItem.action = @selector(deselectAllContacts:);
            } else {
                self.navigationItem.rightBarButtonItem.title = @"SELECT ALL";
                self.navigationItem.rightBarButtonItem.action = @selector(selectAllContacts:);
            }
        }];

        [self.dataSource.onContactsDataSourceDeselectedContactsSignal addObserver:self callback:^(typeof(self) self, NSOrderedSet<OHContact *> * _Nonnull deselectedContacts) {
            if (self.dataSource.contacts.count == self.dataSource.selectedContacts.count) {
                self.navigationItem.rightBarButtonItem.title = @"DESELECT ALL";
                self.navigationItem.rightBarButtonItem.action = @selector(deselectAllContacts:);
            } else {
                self.navigationItem.rightBarButtonItem.title = @"SELECT ALL";
                self.navigationItem.rightBarButtonItem.action = @selector(selectAllContacts:);
            }
        }];

        [self.dataSource loadContacts];

        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"SELECT ALL" style:UIBarButtonItemStylePlain target:self action:@selector(selectAllContacts:)];
    }
    return self;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.dataSource.contacts) {
        return [self.contactsByLetter count];
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.dataSource.contacts) {
        return [[self.contactsByLetter objectForKey:[self.sections objectAtIndex:section]] count];
    } else {
        return 1;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.dataSource.contacts) {
        return [self.sections objectAtIndex:section];
    } else {
        return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ContactCell"];

    if (self.dataSource.contacts) {
        OHContact *contact = [[self.contactsByLetter objectForKey:[self.sections objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
        cell.textLabel.text = [self _displayNameForContact:contact];

        if ([self.dataSource.selectedContacts containsObject:contact]) {
            cell.backgroundColor = [UIColor colorWithRed:210.0f / 255.0f green:241.0f / 255.0f blue:247.0f / 255.0f alpha:1.0f];
        } else {
            cell.backgroundColor = [UIColor whiteColor];
        }
    } else {
        cell.textLabel.text = @"No contacts access, open Settings app to fix this";
    }

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.dataSource.contacts) {
        OHContact *contact = [[self.contactsByLetter objectForKey:[self.sections objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];

        if ([self.dataSource.selectedContacts containsObject:contact]) {
            [self.dataSource deselectContacts:[NSOrderedSet orderedSetWithObject:contact]];
        } else {
            [self.dataSource selectContacts:[NSOrderedSet orderedSetWithObject:contact]];
        }
    }

    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.tableView reloadData];
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

#pragma mark - Actions

- (void)selectAllContacts:(id)sender
{
    [self.dataSource selectContacts:self.dataSource.contacts];
    [self.tableView reloadData];
}

- (void)deselectAllContacts:(id)sender
{
    [self.dataSource deselectContacts:self.dataSource.contacts];
    [self.tableView reloadData];
}

#pragma mark - Private

- (NSDictionary<NSString *, NSOrderedSet<OHContact *> *> *)_contactsByLetterDictionaryForContacts:(NSOrderedSet *)contacts
{
    NSMutableDictionary<NSString *, NSMutableOrderedSet<OHContact *> *> *contactsByLetter = [[NSMutableDictionary<NSString *, NSMutableOrderedSet<OHContact *> *> alloc] init];

    for (OHContact *contact in contacts) {
        NSString *indexLetter = [self _indexLetterForContact:contact];
        if ([contactsByLetter objectForKey:indexLetter] == nil) {
            [self.sections addObject:indexLetter];
            [contactsByLetter setObject:[[NSMutableOrderedSet<OHContact *> alloc] init] forKey:indexLetter];
        }
        [[contactsByLetter objectForKey:indexLetter] addObject:contact];
    }

    return contactsByLetter;
}

- (NSString *)_indexLetterForContact:(OHContact *)contact
{
    if (contact.fullName.length) {
        return [contact.fullName substringToIndex:1];
    }
    return @"#";
}

- (NSString *)_displayNameForContact:(OHContact *)contact
{
    if (contact.fullName.length) {
        return contact.fullName;
    }
    if (contact.contactFields.count) {
        return [contact.contactFields objectAtIndex:0].value;
    }
    return nil;
}

@end
