![Ohana](https://s3.amazonaws.com/uploads.hipchat.com/17604/3775258/b8P910panT41Y7a/ohana.png)

[![CI Status](http://img.shields.io/travis/uber/ohana-ios.svg?style=flat)](https://travis-ci.org/uber/ohana-ios)
[![Version](https://img.shields.io/cocoapods/v/Ohana.svg?style=flat)](http://cocoapods.org/pods/Ohana)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/cocoapods/l/Ohana.svg?style=flat)](http://cocoapods.org/pods/Ohana)
[![Platform](https://img.shields.io/cocoapods/p/Ohana.svg?style=flat)](http://cocoapods.org/pods/Ohana)

Ohana is a framework for working with a user's contacts on the iOS platform. It provides a component-based architecture for loading and processing contacts, as well as managing state such as contact selection and tagging. Whether loading contacts to display to a user, or processing contact data programatically, Ohana provides a simple, but extensible, framework for contact access in your application.  Check out the [wiki](https://github.com/uber/ohana-ios/wiki) to learn how the library works.  There are two quickstart guides available: one for [Swift](https://github.com/uber/ohana-ios/wiki/Quick-Start-(Swift)) and one for [Objective-C](https://github.com/uber/ohana-ios/wiki/Quick-Start-(Objective-C)).  If you have any questions, feel free to ask on [Stack Overflow](http://stackoverflow.com/questions/tagged/ohana) (tag "ohana").

## Features

- [x] Easy to get started
- [x] Extensible architecture
- [x] Runtime-injectable components
- [x] Swift-compatible

## Installation

#### CocoaPods

To integrate Ohana into your project using [CocoaPods](http://cocoapods.org), add the following line to your Podfile:

```ruby
pod 'Ohana', '~> 1.3'
```

#### Carthage

To consume Ohana using [Carthage](https://github.com/Carthage/Carthage) add this to your Cartfile:

```
github "uber/ohana-ios" ~> 1.3
```

You'll need to manually import Ohana, and its dependencies, libPhoneNumber and UberSignals.

## Running the Examples App

* Clone the repo `git clone git@github.com:uber/ohana-ios.git`
* Open the Example directory `cd ohana-ios/Example`
* run `pod install`
* `open Ohana.xcworkspace` 
* Run the `OhanaExample` scheme in Xcode

## Authors

* Nick Entin ([@NickEntin](https://github.com/NickEntin))
* Maxwell Elliott (maxwelle@uber.com, [@maxwellE](https://github.com/maxwellE))
* Doug Togno (dtogno@uber.com)
* Adam Zethraeus (adamz@uber.com, [@zethraeus](https://github.com/zethraeus))

## Contributions

We'd love for you to contribute to our open source projects. Before we can accept your contributions, we kindly ask you to sign our [Uber Contributor License Agreement](https://docs.google.com/a/uber.com/forms/d/1pAwS_-dA1KhPlfxzYLBqK6rsSWwRwH95OCCZrcsY5rk/viewform).

- If you **find a bug**, open an issue or submit a fix via a pull request.
- If you **have a feature request**, open an issue or submit an implementation via a pull request
- If you **want to contribute**, submit a pull request.

Check out the [Contribution Guidelines](https://github.com/uber/ohana-ios/wiki/Contribution-Guidelines) for more information.

## License

Ohana is released under the MIT license. See the LICENSE file for more info.
