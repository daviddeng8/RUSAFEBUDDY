# r u safe, buddy?
As COVID19 worsens worldwide and LA Hacks is around the corner, we wants to create an application that echoes the importance of social distancing. While eyeing six feet may be as accurate as asking developers to [estimate their own projects](http://improvingwetware.com/pages/WhenEstimateIsWrong), we realize that this can be easily accomplished by using a beacon that everyone holds - smartphoness. By using [iBeacon](https://developer.apple.com/ibeacon/) as the base of our app, we develop a simple IOS app using Swift that responds accordingly to its relative distance with another smartphone.

## What is r u safe, buddy?
Health officials have recommended we maintain a **6 foot range** from other people when outside. COVID19 is a respiratory disease, and maintaining this range is the best way to avoid being infected. And yet, we notice people unknowingly crossing into the 6 foot safety bubble all the time! So we introduced r u safe, buddy? - an app that alerts you when you are within 6 feet of other people. It lets you know when you are a safe distance away from others, and as you get closer, the screen will change colors and the app will exclaim "Danger, danger!".

## How to use it?
After downloading the app, tap anywhere to initialize the beacon. It will automatically detect any closeby device that are also running this app and display
1. You are safe. (further away than 6 feet from other devices)
2. You are slightly in danger. (around 6 feet from other devices)
3. You are in danger. (within 6 feet from other devices)

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
git clone https://github.com/daviddeng8/RUSAFEBUDDY.git
```

* Open "Xcode Project" directory in Xcode and you are good to go!

*Note: this project will not run using the Xcode simulator, as it requires Bluetooth/Location features unsupported by the simulator. To run the project, connect a supported iOS device to your computer and launch the app on that device. When the device prompts you to turn on location usage, tap allow.*
