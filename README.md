# Bluebonnet

[![Circle CI](https://circleci.com/gh/yatatsu/Bluebonnet.svg?style=svg)](https://circleci.com/gh/yatatsu/Bluebonnet)
[![Version](https://img.shields.io/cocoapods/v/Bluebonnet.svg?style=flat)](http://cocoapods.org/pods/Bluebonnet)
[![License](https://img.shields.io/cocoapods/l/Bluebonnet.svg?style=flat)](http://cocoapods.org/pods/Bluebonnet)
[![Platform](https://img.shields.io/cocoapods/p/Bluebonnet.svg?style=flat)](http://cocoapods.org/pods/Bluebonnet)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

Bluebonnet is a simple APIClient using [Alamofire](https://github.com/Alamofire/Alamofire) and [ReactKit/SwiftTask](https://github.com/ReactKit/SwiftTask).

## Feature

- typed response
- handle as SwiftTask
- Swift 1.2

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

### Set up client

- First, create a API class inherited ``Bluebonnet``.
- Then, create a struct implemented ``BluebonnetRequest``.
- Define request in the struct. (e.g. ``method``, ``parameters``)

```swift
public class GitHubAPI: Bluebonnet {

    // baseURL for all api
    static let baseURL: NSURL = NSURL(string: "https://api.github.com")!

    /**
    for respective API
    */
    struct GetUserProfile: BluebonnetRequest {
        typealias Response = User
        typealias ErrorResponse = GitHubError
        let userName: String
        let method: HTTPMethod = .GET
        var parameters: [String: AnyObject] = [:]
        var path: String {
            return "users/\(userName.URLEscapedString)"
        }

        init(userName: String) {
            self.userName = userName
        }

        /// it is requred property for converting to request
        var URLRequest: NSURLRequest {
            return Bluebonnet.build(baseURL, path: path, method: method, parameters: parameters)
        }
    }
}
```

### Use the client

- You can get task like this. 
- Both responses in .success/.failure are typed.

```swift
let task = GitHubAPI.requestTask(GitHubAPI.GetUserProfile(userName: userName))
task
    .progress { (oldProgress, newProgress) in
        print(newProgress.bytesWritten)
        print(newProgress.totalBytesWritten)
        return
    }
    .success { user in // type inference
        print(user.name)
        return
    }
    .failure { (errorResult, isCancelled) -> Void in
        print(errorResult?.error.description)
        print(errorResult?.response?.message
        return
    }
```

## Requirements

- Swift 1.2


## Installation

Bluebonnet is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "Bluebonnet"
```

## Acknowledgement

Bluebonnet refers to [APIKit](https://github.com/ishkawa/APIKit).

## Author

KITAGAWA Tatsuya, yatatsukitagawa@gmail.com

## License

Bluebonnet is available under the MIT license. See the LICENSE file for more info.
