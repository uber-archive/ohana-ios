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

        let alphabeticalSortProcessor = OHAlphabeticalSortPostProcessor(sortMode: .fullName)

        var dataProvider: OHContactsDataProviderProtocol
        if #available(iOS 9.0, *) {
            let contactsDataProvider = OHCNContactsDataProvider(delegate: self)
            contactsDataProvider.loadThumbnailImage = true
            dataProvider = contactsDataProvider
        } else {
            dataProvider = OHABAddressBookContactsDataProvider(delegate: self)
        }

        dataSource = OHContactsDataSource(dataProviders: NSOrderedSet(objects: dataProvider), postProcessors: NSOrderedSet(object: alphabeticalSortProcessor))

        dataSource.onContactsDataSourceReadySignal.addObserver(self, callback: { [weak self] (observer) in
            self?.tableView?.reloadData()
        })

        dataSource.loadContacts()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: OHCNContactsDataProviderDelegate

    @available(iOS 9.0, *)
    func dataProviderDidHitContactsAuthenticationChallenge(_ dataProvider: OHCNContactsDataProvider) {
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { (granted, error) in
            if granted {
                dataProvider.loadContacts()
            }
        }
    }

    // MARK: OHABAddressBookContactsDataProviderDelegate

    func dataProviderDidHitAddressBookAuthenticationChallenge(_ dataProvider: OHABAddressBookContactsDataProvider) {
        ABAddressBookRequestAccessWithCompletion(nil) { (granted, error) in
            if granted {
                dataProvider.loadContacts()
            }
        }
    }

    // MARK: UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let contacts = dataSource.contacts {
            return contacts.count
        }
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)

        if let contact = self.dataSource.contacts?.object(at: indexPath.row) as? OHContact {
            cell.textLabel?.text = displayTitleForContact(contact)

            cell.imageView?.image = contact.thumbnailPhoto

            if dataSource.selectedContacts.contains(contact) {
                cell.backgroundColor = UIColor(red: 210.0 / 255.0, green: 241.0 / 255.0, blue: 247.0 / 255.0, alpha: 1.0)
            } else {
                cell.backgroundColor = UIColor.white
            }
        } else {
            cell.textLabel?.text = "No contacts access, open Settings app to fix this"
        }

        return cell
    }

    // MARK: UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let contact = self.dataSource.contacts?.object(at: indexPath.row) as? OHContact {
            if dataSource.selectedContacts.contains(contact) {
                dataSource.deselectContacts(NSOrderedSet(object: contact))
            } else {
                dataSource.selectContacts(NSOrderedSet(object: contact))
            }
        }
        tableView.reloadData()
    }

    // MARK: Private

    fileprivate func displayTitleForContact(_ contact: OHContact) -> String? {
        if contact.fullName?.characters.count ?? 0 > 0 {
            return contact.fullName
        } else if contact.contactFields?.count ?? 0 > 0 {
            return (contact.contactFields?.object(at: 0) as? OHContactField)?.value
        } else {
            return "(Unnamed Contact)"
        }
    }

}
