//
//  OHStatisticsExample.swift
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

import Foundation
import Ohana

class OHStatisticsExample : NSObject, OHCNContactsDataProviderDelegate, OHABAddressBookContactsDataProviderDelegate {
    var presenter : UIViewController?

    func generateStatistics(presenter: UIViewController) {
        self.presenter = presenter
        var dataProvider: OHContactsDataProviderProtocol
        if #available(iOS 9.0, *) {
            dataProvider = OHCNContactsDataProvider(delegate: self)
        } else {
            dataProvider = OHABAddressBookContactsDataProvider(delegate: self)
        }

        dataProvider.onContactsDataProviderErrorSignal.addObserver(self, callback: { (self) in
            let alertController = UIAlertController(title: "No Contacts Access",
                message: "Open the Settings app and enable contacts access in Privacy Settings", preferredStyle: .Alert)

            alertController.addAction(UIAlertAction(title: "OK", style: .Cancel) { (action) in
                presenter.dismissViewControllerAnimated(true, completion: nil)
            })

            presenter.presentViewController(alertController, animated: true, completion: nil)
        })

        if #available(iOS 9.0, *) {
            let statsProcessor = OHStatisticsPostProcessor()

            let dataSource = OHContactsDataSource(dataProviders: NSOrderedSet(object: dataProvider), postProcessors: NSOrderedSet(object: statsProcessor))

            dataSource.onContactsDataSourceReadySignal.addObserver(self, callback: { (self) in
                var totalPhoneNumbers = 0
                var totalEmailAddresses = 0
                for contact in dataSource.contacts?.array as! [OHContact] {
                    if let numPhoneNumbers = contact.customProperties.objectForKey(kOHStatisticsNumberOfPhoneNumbers)?.integerValue {
                        totalPhoneNumbers += numPhoneNumbers
                    }
                    if let numEmailAddresses = contact.customProperties.objectForKey(kOHStatisticsNumberOfEmailAddresses)?.integerValue {
                        totalEmailAddresses += numEmailAddresses
                    }
                }

                let avgPhoneNumbers = Double(totalPhoneNumbers) / Double(dataSource.contacts!.count)
                let avgEmailAddresses = Double(totalEmailAddresses) / Double(dataSource.contacts!.count)

                let alertController = UIAlertController(title: "Statistics",
                    message: "Number of contacts:\n\(dataSource.contacts!.count)\n\nAverage # of phone numbers fields:\n\(avgPhoneNumbers)\n\nAverage # of email address fields:\n\(avgEmailAddresses)", preferredStyle: .Alert)

                alertController.addAction(UIAlertAction(title: "OK", style: .Cancel) { (action) in
                    presenter.dismissViewControllerAnimated(true, completion: nil)
                })

                presenter.presentViewController(alertController, animated: true, completion: nil)
            });

            dataSource.loadContacts()
        }
    }

    // MARK: OHCNContactsDataProviderDelegate

    @available(iOS 9.0, *)
    func dataProviderDidHitContactsAuthenticationChallenge(dataProvider: OHCNContactsDataProvider) {
        let store = CNContactStore()
        store.requestAccessForEntityType(.Contacts) { (granted, error) in
            if granted {
                dataProvider.loadContacts()
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    let alertController = UIAlertController(title: "No Contacts Access",
                                                            message: "Open the Settings app and enable contacts access in Privacy Settings", preferredStyle: .Alert)

                    alertController.addAction(UIAlertAction(title: "OK", style: .Cancel) { [weak self] (action) in
                        self?.presenter?.dismissViewControllerAnimated(true, completion: nil)
                        })

                    self.presenter?.presentViewController(alertController, animated: true, completion: nil)
                }
            }
        }
    }

    // MARK: OHABAddressBookContactsDataProviderDelegate

    func dataProviderDidHitAddressBookAuthenticationChallenge(dataProvider: OHABAddressBookContactsDataProvider) {
        ABAddressBookRequestAccessWithCompletion(nil) { (granted, error) in
            if granted {
                dataProvider.loadContacts()
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    let alertController = UIAlertController(title: "No Contacts Access",
                                                            message: "Open the Settings app and enable contacts access in Privacy Settings", preferredStyle: .Alert)

                    alertController.addAction(UIAlertAction(title: "OK", style: .Cancel) { [weak self] (action) in
                        self?.presenter?.dismissViewControllerAnimated(true, completion: nil)
                        })

                    self.presenter?.presentViewController(alertController, animated: true, completion: nil)
                }
            }
        }
    }
}