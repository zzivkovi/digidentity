# Digidentity assessment solution
Zeljko Zivkovic [info@applab.hr]

This repository contains a solution to Digidentity's mobile development testcase - a mobile application to consume a simple REST based API

### Installation

```
git clone https://github.com/zzivkovi/digidentity
cd digidentity
pod install
```
Open the resulting workspace `ZZDigidentity.xcworkspace`

### Application architecture
Project does not have any specific artchitecture in place but code has been structured in such a way to mirror logical units performing single responsibility. All of the architecture layers are abstracted, thus encapsulated and easily mocked during testing.

App structure is listed below ordered from lowest, system level to highest, UI level

##### NetworkManager
Uses `URLSession` to send and receive network requests. It does no semantic data analysis other than error management in regard to network communication.

##### RequestManager
High-level wrapper of `NetworkManager` for ease of use. Parses incoming network `Data` to usable `APIItem` data objects.

##### ItemsDataSource
Serves as a memory cache and an interface between apps's UI-levels and networking. It also uses `ItemsDiskStorage` to persist data received from backend to disk.

##### CatalogueScreenDataSource
This class is a data source for `UITableView` which displays items received from backend service. It extends backend items with additional objects which in UI provide information on networking events (loading/not loading data, end of list, etc.). `CatalogueScreenDataSource` also contains business logic on whether or not network requests can be made.

##### CatalogueScreenTableViewDelegate
Displays data from `CatalogueScreenDataSource` to `UITableView` and triggers data loading on table view's scroll events.

##### CatalogueScreenViewController
`UIViewController` which contains `UITableView` that displays data.

##### Dependencies
Singleton object which instantiates application services and serves as their container.

##### URLSessionCertificateValidator
Class which is a `URLSession` delegate and handles TLS validation.


### Third party dependencies
Only dependency is `RNCryptor` used for AES256 encryption of disk stored data.


### Caveats
Due to time constraints certain compromises have been made in the project:
- `TLSValidator` has been added as a pre-existing Objective-C class. Ideally it should be rewritten in Swift which would mitigate a need for a bridging header.
- Only networking classes have been tested.
- There is no delete or upload functionality
