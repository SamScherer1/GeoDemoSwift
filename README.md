# iOS-GEODemo

> **Note: This Sample Project is developed based on iOS SDK v3.5.1, an update version for iOS SDK v4.0 will be published soon.**

## Introduction

  From this demo, you will learn how to use the `DJIFlyZoneManager` and `DJIFlyZoneInformation` of DJI Mobile SDK to get the fly zone information, and unlock authorization fly zones.

## Requirements

 - iOS 9.0+
 - Xcode 8.0+
 - DJI iOS SDK 4.0.1

## SDK Installation with CocoaPods

Since this project has been integrated with [DJI iOS SDK CocoaPods](https://cocoapods.org/pods/DJI-SDK-iOS) now, please check the following steps to install **DJISDK.framework** using CocoaPods after you downloading this project:

**1.** Install CocoaPods

Open Terminal and change to the download project's directory, enter the following command to install it:

~~~
sudo gem install cocoapods
~~~

The process may take a long time, please wait. For further installation instructions, please check [this guide](https://guides.cocoapods.org/using/getting-started.html#getting-started).

**2.** Install SDK with CocoaPods in the Project

Run the following command in the project's path:

~~~
pod install
~~~

If you install it successfully, you should get the messages similar to the following:

~~~
Analyzing dependencies
Downloading dependencies
Installing DJI-SDK-iOS (4.0.1)
Generating Pods project
Integrating client project

[!] Please close any current Xcode sessions and use `DJIGEOSample.xcworkspace` for this project from now on.
Pod installation complete! There is 1 dependency from the Podfile and 1 total pod
installed.
~~~

> **Note**: If you saw "Unable to satisfy the following requirements" issue during pod install, please run the following commands to update your pod repo and install the pod again:
> 
> ~~~
> pod repo update
> pod install
> ~~~

## Tutorial

For this demo's tutorial: **DJI GEO System Tutorial**, please refer to <https://developer.dji.com/mobile-sdk/documentation/ios-tutorials/GEODemo.html>.

## Feedback

We’d love to hear your feedback on this demo and tutorial.

Please use **Github Issue** or **email** [oliver.ou@dji.com](oliver.ou@dji.com) when you meet any problems of using this demo. At a minimum please let us know:

* Which DJI Product you are using?
* Which iOS Device and iOS version you are using?
* A short description of your problem includes debugging logs or screenshots.
* Any bugs or typos you come across.

## License

iOS-GEODemo is available under the MIT license. Please see the LICENSE file for more info.

