//
//  OHBasicContactPhotosPicker.swift
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

import UIKit
import Ohana

class OHBasicContactPhotosPicker : UITableViewController, OHCNContactsDataProviderDelegate, OHABAddressBookContactsDataProviderDelegate {

    var dataSource: OHContactsDataSource!

    init() {
        super.init(nibName: nil, bundle: nil)

        let alphabeticalSortProcessor = OHAlphabeticalSortPostProcessor(sortMode: .FullName)

        var dataProvider: OHContactsDataProviderProtocol
        if #available(iOS 9.0, *) {
            let contactsDataProvider = OHCNContactsDataProvider(delegate: self)
            contactsDataProvider.loadThumbnailImage = true
            dataProvider = contactsDataProvider
        } else {
            dataProvider = OHABAddressBookContactsDataProvider(delegate: self)
        }

        dataSource = OHContactsDataSource(dataProviders: NSOrderedSet(objects: dataProvider), postProcessors: NSOrderedSet(object: alphabeticalSortProcessor))

        dataSource.onContactsDataSourceReadySignal.addObserver(self, callback: { (self) in
            self.tableView?.reloadData()
        })

        dataSource.loadContacts()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: OHCNContactsDataProviderDelegate

    @available(iOS 9.0, *)
    func dataProviderDidHitContactsAuthenticationChallenge(dataProvider: OHCNContactsDataProvider) {
        let store = CNContactStore()
        store.requestAccessForEntityType(.Contacts) { (granted, error) in
            if granted {
                dataProvider.loadContacts()
            }
        }
    }

    // MARK: OHABAddressBookContactsDataProviderDelegate

    func dataProviderDidHitAddressBookAuthenticationChallenge(dataProvider: OHABAddressBookContactsDataProvider) {
        ABAddressBookRequestAccessWithCompletion(nil) { (granted, error) in
            if granted {
                dataProvider.loadContacts()
            }
        }
    }

    // MARK: UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.contacts!.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Default, reuseIdentifier: nil)

        if let contact = self.dataSource.contacts?.objectAtIndex(indexPath.row) as? OHContact {
            cell.textLabel?.text = displayTitleForContact(contact)

            cell.imageView?.image = contact.thumbnailPhoto

            if dataSource.selectedContacts.containsObject(contact) {
                cell.backgroundColor = UIColor(red: 210.0 / 255.0, green: 241.0 / 255.0, blue: 247.0 / 255.0, alpha: 1.0)
            } else {
                cell.backgroundColor = UIColor.whiteColor()
            }
        }

        return cell
    }

    // MARK: UITableViewDelegate

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let contact = self.dataSource.contacts?.objectAtIndex(indexPath.row) as? OHContact {
            if dataSource.selectedContacts.containsObject(contact) {
                dataSource.deselectContacts(NSOrderedSet(object: contact))
            } else {
                dataSource.selectContacts(NSOrderedSet(object: contact))
            }
        }
        tableView.reloadData()
    }

    // MARK: Private

    private func displayTitleForContact(contact: OHContact) -> String? {
        if contact.fullName?.characters.count > 0 {
            return contact.fullName
        } else if contact.contactFields?.count > 0 {
            return contact.contactFields?.objectAtIndex(0).value
        } else {
            return "(Unnamed Contact)"
        }
    }

}
