# LoggingOSLog

A logging backend for `SwiftLog` that sends log messages to `OSLog`.

 The logger's `label` is used to specify the `subsystem` and `categorgy` for `OSLog` in string format `"mysubsystem/mycategory"`. The `metadataContentType` is used to control the output of `LoggerMetadata`. If `private` is set, the `LoggerMetadata` content output is replaced with `<private>` String value. This is useful for protecting sensitive information for Release build.

## Getting started

#### Adding the dependency 

Xcode's Swift Package Manager integration (Xcode 12 and higher):

```
https://github.com/inmotionsoftware/swift-log-oslog.git
```

And use 1.0.0 as the base version. 

Package.swift:

```
.package(url: "https://github.com/inmotionsoftware/swift-log-oslog.git", .from("1.0.0"))
```

#### Bootstrap LoggingOSLog

```swift
import Logging
import LoggingOSLog

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        LoggingSystem.bootstrap {
            #if DEBUG
                OSLogHandler(label: $0, metadataContentType: .public)
            #else
                OSLogHandler(label: $0, metadataContentType: .private)
            #endif
        }
}
```

#### Let's log

```swift
// 1) let's import the logging API package
import Logging
import LoggingOSLog

// 2) we need to create a logger
let logger = Logger(label:"LoggingExample/ExampleCategory")

// 3) we're now ready to use it
logger.info("Hello World!")
```

For more details on all the features of the Swift Logging API, check out the [`swift-log`](https://github.com/apple/swift-log) repo.

#### License

MIT
