# r u safe, buddy? <img src="/Xcode Project/rusafebuddy/Assets.xcassets/AppIcon.appiconset/120x120.png" height="32">
As COVID19 worsens worldwide, we wanted to use this opportunity at LAHacks to create an application that echoes the importance of social distancing. While eyeing six feet may be as accurate as asking developers to [estimate their own projects](http://improvingwetware.com/pages/WhenEstimateIsWrong), we realize that this can be easily accomplished by using a beacon that everyone holds - smartphones. By using [iBeacon](https://developer.apple.com/ibeacon/) as the base of our app, we developed an IOS app using Swift that responds accordingly to its relative distance with other smartphones.

Devpost Submission: https://devpost.com/software/r-u-safe-buddy

## What is r u safe, buddy?
Health officials have recommended we maintain a **6 feet range** from other people when outside. COVID19 is a respiratory disease, and maintaining this range is the best way to avoid being infected. And yet, we notice people unknowingly crossing into the 6 foot safety bubble all the time! So, we introduced r u safe, buddy? - an app that alerts you when you are within 6 feet of other people. It lets you know when you are a safe distance away from others, and as you get closer, the screen will change colors as the app exclaims "Danger, danger!".

## How to use it?
After downloading the app, tap anywhere to initialize the beacon. It will automatically detect any close by devices that are also running this app and display:
1. You are safe. (More than 6 feet away from the closest device)
2. You are slightly in danger. (Around 6 feet away from the closest device)
3. You are in danger. (Within 6 feet away from the closest device)

## Future Improvements
1. Android Compatibility
2. Running in the Background & Notification

## For Devs
### Requirements
* Swift 5
* Xcode 11

### How to Get Started?
* Clone this repository
```bash
git clone https://github.com/daviddeng8/r-u-safe-buddy.git
```

* Open "Xcode Project" directory in Xcode and you are good to go!

*Note: this project will not run using the Xcode simulator, as it requires Bluetooth/Location features unsupported by the simulator. To run the project, connect a supported iOS device to your computer and launch the app on that device. When the device prompts you to turn on location usage, tap allow.*

## Contributors
* David Deng
* Rishi Sankar
* Angela Lu
* Ray Huang
* Justin Li
