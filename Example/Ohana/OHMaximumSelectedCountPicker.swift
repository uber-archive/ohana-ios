//
//  OHMaximumSelectedCountPicker.swift
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


class OHMaximumSelectedCountPicker: UITableViewController, OHCNContactsDataProviderDelegate, OHABAddressBookContactsDataProviderDelegate {

    var dataSource: OHContactsDataSource!

    init() {
        super.init(nibName: nil, bundle: nil)

        let alphabeticalSortProcessor = OHAlphabeticalSortPostProcessor(sortMode: .fullName)

        var dataProvider: OHContactsDataProviderProtocol
        if #available(iOS 9.0, *) {
            dataProvider = OHCNContactsDataProvider(delegate: self)
        } else {
            dataProvider = OHABAddressBookContactsDataProvider(delegate: self)
        }

        dataSource = OHContactsDataSource(dataProviders: NSOrderedSet(objects: dataProvider), postProcessors: NSOrderedSet(object: alphabeticalSortProcessor))

        let maximumSelectedFilter = OHMaximumSelectedCountSelectionFilter(dataSource: dataSource, maximumSelectedCount: 3)

        maximumSelectedFilter.onContactsDataSourceSelectedContactsAttemptedToExceedMaximumCountSignal.addObserver(self) { [weak self] (observer, failedContacts: NSOrderedSet) in
            for contact in failedContacts.array as! [OHContact] {
                let alertController = UIAlertController(title: "Failed to Select Contact", message: "\(contact.fullName ?? "Unnamed Contact")\n\nA maximum of three contacts may be selected at a time.", preferredStyle: .alert)

                alertController.addAction(UIAlertAction(title: "OK", style: .cancel) { (action) in
                    self?.dismiss(animated: true, completion: nil)
                })

                self?.present(alertController, animated: true, completion: nil)
            }
        }

        dataSource.selectionFilters = NSOrderedSet(object: maximumSelectedFilter)

        dataSource.onContactsDataSourceReadySignal.addObserver(self, callback: { [weak self] (observer) in
            DispatchQueue.main.async {
                self?.tableView?.reloadData()
            }
        })
        
        dataSource.loadContacts()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: OHCNContactsDataProviderDelegate

    @available(iOS 9.0, *)
    func dataProviderHitCNContactsAuthChallenge(_ dataProvider: OHCNContactsDataProvider, requiresUserAuthentication userAuthenticationTrigger: @escaping () -> Void) {
        userAuthenticationTrigger()
    }

    // MARK: OHABAddressBookContactsDataProviderDelegate

    func dataProviderHitABAddressBookAuthChallenge(_ dataProvider: OHABAddressBookContactsDataProvider, requiresUserAuthentication userAuthenticationTrigger: @escaping () -> Void) {
        userAuthenticationTrigger()
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
