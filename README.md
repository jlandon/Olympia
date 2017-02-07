# Olympia

A JSON parsing library specifically for structs (but also usable in classes), with no Foundation dependency.

## Example
```swift
struct Vehicle: Decodable {
	let make: String
	let model: String?
	let year: Int
	
	init(json: JSON) throws {
		make = try json.decode("make") // generic decoder
        model = json.string("model") // optional String getter
		year = json.value("year", default: 2016) // optional Int getter with default value
	}
}
```

## Installation

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that automates the process of adding frameworks to your Cocoa application.

You can install Carthage with [Homebrew](http://brew.sh/) using the following commands:

```bash
$ brew update
$ brew install carthage
```

To integrate Olympia into your Xcode project using Carthage, specify it in your [Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile):

```ogdl
github "ovenbits/Olympia"
```

Then, run `carthage update`.

Follow the current instructions in [Carthage's README](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application) for up-to-date installation instructions.

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager) is a dependency management tool provided by Apple, still in early design and development. For more infomation check out its [GitHub Page](https://github.com/apple/swift-package-manager).

You can use the Swift Package Manager to install `Olympia` by adding it as a dependency in your `Package.swift` file:
```swift
import PackageDescription

let package = Package(
    name: "PROJECT_NAME",
    targets: [],
    dependencies: [
        .Package(url: "https://github.com/ovenbits/Olympia.git", versions: "1.0.0" ..< Version.max)
    ]
)
```
