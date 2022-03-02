# TaskForce

[![License](http://img.shields.io/badge/License-MIT-green.svg?style=flat)](https://github.com/igrrik/TaskForce/blob/master/LICENSE)

TaskForce is a small app that gives you opportunity to assemble your own squad of Marvel Characters.

## Screenshots
<table>
  <tr>
    <td>Main Screen</td>
    <td>Character Details</td>
  </tr>
  <tr>
    <td><img src="screenshots/main_screen.png" width=375></td>
    <td><img src="screenshots/character_details.png" width=375></td>
  </tr>
 </table>

## Features
* Communication with REST API via URLSession
* Persistence is implemented with Core Data
* Combine based MVVM architecture
* Localization
* Assets generation with SwiftGen

## Requirements

* Xcode 13+
* [brew](https://brew.sh)
* [Marvel API](https://developer.marvel.com/) `private key` and `public key`

### Note

To use the Marvel API you need to sign up for a developer account. Once you sign up you will find your API keys in the Account section.

It's important to add "*" as an Authorized Referrer in the Account section.

## Installation

* Clone the project
* Open terminal and navigate to project directory
* Run `chmod +x ./install.sh`
* Run `./install.sh`
* Script will ask you to enter your MARVEL API `public key` and `private key`, to add them to `Credentials.plist` which is ignored by `git`
* Open `TaskForce.xcodeproj`
* Wait till SPM dependencies are downloaded
* Run!

## Project overview

### Structure
* Project is structured in a way to give a glance on how modular approach can be achieved. Although it is pretty common to start project as a monolith, modularizing an app from the beginning is a good practice in long term, especially since Apple provided this opportunity with local Swift Packages. Modular architecture is usually applied when a project starts to grow, to reduce build time and simplify project support especially when there are several teams working on it.
* Shared folder is intended to be the place for all code that can be shared between different targets or apps (i.e. UIKit app and SwiftUI app). It includes two Swift Packages: `ImageDownloader` and `TaskForceCore`.
* `ImageDownloader` is a thin wrapper around `Kingfisher` library. This wrapper is created to simplify Unit-testing, and also it gives us opportunity to replace `Kingfisher` with any other solution painlessly, if we need that, and there is no need to modify actual app code in this case.
* `TaskForceCore` is a module that contains all the business logic that is not related to specific target or app implementation.

### Acrhitecture
* `MVVM` is used as a base architecture for presentation layer, because it gives better control of UI-state consistency than `MVP` or `MVC`, while keeping the entry level low. Also it works well with both `UIKit` and `SwiftUI`.
* Routing is inspired by `Coordinator` pattern and is implemented in `AppFlowController`. The difference between common `Coordinator` implementation and the one used in this project, is that `Coordinator` is not a simple class, but a subclass of a `UIViewController`/`UINavigationController`/`UITabViewController`. This is done because common `Coordinator` implementations usually need to either manually handle their life-cycle, which is an error-prone process, or have a lot of custom logic for doing it under the hood, also they either use `UIKit` objects to actually perform navigation or create a bunch of classes to abstract this work. Current approach was chosen because it keeps the navigation logic simple, by leveraging `UIKit` APIs of container view controllers and presentation methods (i.e. `show(_:sender:)`).

### Presentation layer
* Screen logic is located in `TaskForce/UserStories` folder.
* `CharactersList` supports infinite scrolling and consists of two sections:
  * Your squad, which shows all the characters that you've recruited. Squad persists between launches.
  * All Characters.
* `CharacterDetails` shows you a brief informatio about the character and gives you opportunity to recruit of fire a character.
* These modules are created in `AppModulesFactory`, that is owned by `AppFlowController`.
* `AppModulesFactory` uses `DependenciesRegistry` class to obtain dependencies like services, repositories, etc.

### Tooling
* `Swiftlint` is used to lint code files and maintain consistency of code style.
* `SwiftGen` is used to generate enums for compile-time safety of assets and localizable strings.

## Compatibility

This project is written in Swift 5.5 and requires Xcode 13 or newer to build and run.

TaskForce is compatible with iOS 14.0+.

## Things to do/improve

- [ ] Add Persistence Tests
- [ ] Add ViewModel Tests
- [ ] Add UITests
- [ ] Reachability
- [ ] Add SwiftUI version

## License

Copyright 2022 Igor Kokoev.

Licensed under MIT License: https://opensource.org/licenses/MIT