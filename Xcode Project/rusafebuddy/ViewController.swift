/*

r u safe, buddy?
ViewController.swift

Created for LAHacks 2020 - March 28-29, 2020

Contributors:
- David Deng
- Rishi Sankar
- Angela Lu
- Justin Li
- Ray Huang

*/

import UIKit

import CoreBluetooth
import CoreLocation
import AVFoundation

class ViewController: UIViewController, CLLocationManagerDelegate, CBPeripheralManagerDelegate {
    var locationManager: CLLocationManager!
    
    var homeSoundEffect: AVAudioPlayer?
    var safeSoundEffect: AVAudioPlayer?
    var dangerSoundEffect: AVAudioPlayer?
    var slightDangerSoundEffect: AVAudioPlayer?
    
    var currentViewController: UIViewController!
    var curState = -1
    var leftHome = false
    
    //Randomly generated unique beacon ID
    var UUID_STR = "3C5F9383-4ABC-4D7E-9396-193E28B44125"
    
    //UIButton to trigger scanning when the home screen is pressed
    @IBAction func startScanning(_ sender: UIButton) {
        if (!leftHome) {
            leftHome = true
        }
    }
    
    //Loads the view on startup
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Default view controller is the main home page
        currentViewController = self
        
        //Load Sound Effects as AVAudioPlayer
        let path1 = Bundle.main.path(forResource: "homeSound.m4a", ofType:nil)!
        let url1 = URL(fileURLWithPath: path1)
        let path2 = Bundle.main.path(forResource: "safe.m4a", ofType:nil)!
        let url2 = URL(fileURLWithPath: path2)
        let path3 = Bundle.main.path(forResource: "slightdanger.m4a", ofType:nil)!
        let url3 = URL(fileURLWithPath: path3)
        let path4 = Bundle.main.path(forResource: "danger.m4a", ofType:nil)!
        let url4 = URL(fileURLWithPath: path4)
        do {
            homeSoundEffect = try AVAudioPlayer(contentsOf: url1)
            safeSoundEffect = try AVAudioPlayer(contentsOf: url2)
            slightDangerSoundEffect = try AVAudioPlayer(contentsOf: url3)
            dangerSoundEffect = try AVAudioPlayer(contentsOf: url4)
            homeSoundEffect?.play()
        } catch { }
        
        //Configure location services to enable Bluetooth/scanning for nearby beacons
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization() //requests location services
        initLocalBeacon()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    //Start scanning for beacons if location/bluetooth requirements are met
                    startScanning()
                }
            }
        }
    }
    
    //Scan for nearby beacons
    func startScanning() {
        let uuid = UUID(uuidString: UUID_STR)!
        let beaconRegion = CLBeaconRegion(proximityUUID: uuid, major: 123, minor: 456, identifier: "beacon")
        
        locationManager.startMonitoring(for: beaconRegion)
        locationManager.startRangingBeacons(in: beaconRegion)
        
    }
    
    //Called repeatedly during beacon scan
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        if leftHome {
            if beacons.count > 0 {
                var temp = beacons[0]
                for elem in beacons {
                    if elem.rssi > temp.rssi {
                        temp = elem
                    }
                }
                updateDistance(temp.rssi)
            } else {
                //RSSI is always negative - so 1 represents no beacons found
                updateDistance(1)
            }
        }
    }
    
    func configureDisplaySettings(_ futureVC: UIViewController) {
        //Configure basic display settings to make new pages overlay on screen
        futureVC.isModalInPresentation = true
        futureVC.modalPresentationStyle = .fullScreen
        self.currentViewController.addChild(futureVC)
        self.currentViewController.view.addSubview(futureVC.view)
        self.currentViewController = futureVC
    }

    //Experimental RSSI values (decibels) shown to approximate the desired 6-foot range
    //Potential future work - add calibration feature for each device
    var rssiBound1 = -44
    var rssiBound2 = -47
    var rssiBound3 = -51
    var rssiBound4 = -54
    
    func updateDistance(_ rssi: Int) {
        //Display "no buddies found" page if no beacons detected (rssi == 1)
        if rssi == 1 {
            //Don't update screen if already at correct screen
            if self.curState != 0 {
                let NoBuddiesFoundViewController = self.storyboard?.instantiateViewController(withIdentifier: "NoBuddies") as! NoBuddiesFoundViewController
                configureDisplaySettings(NoBuddiesFoundViewController)
                self.curState = 0
            }
        //If much more than 7 feet distance, as extrapolated by RSSI, display safe screen
        } else if rssi < rssiBound4 || (rssi < rssiBound3 && curState == 0) {
            if self.curState != 1 {
                let YouAreSafeViewController = self.storyboard?.instantiateViewController(withIdentifier: "Safe") as! YouAreSafeViewController
                configureDisplaySettings(YouAreSafeViewController)
                self.curState = 1
                self.safeSoundEffect?.play()
            }
        //If close to 6 feet distance, as extrapolated by RSSI, display slight danger screen
        } else if rssi < rssiBound2 && (rssi > rssiBound3 || curState == 0)  {
            if self.curState != 2 {
                let YouAreSlightlyInDangerViewController = self.storyboard?.instantiateViewController(withIdentifier: "SlightDanger") as! YouAreSlightlyInDangerViewController
                configureDisplaySettings(YouAreSlightlyInDangerViewController)
                if self.curState != 3 {
                    //Only play sound if changing from safe (not if changing from danger)
                    self.slightDangerSoundEffect?.play()
                }
                self.curState = 2
            }
        //If under 6 feet distance, as extrapolated by RSSI, display danger screen
        } else if rssi > rssiBound1 || curState == 0 {
            if self.curState != 3 {
                let YouAreInDangerViewController = self.storyboard?.instantiateViewController(withIdentifier: "Danger") as! YouAreInDangerViewController
                configureDisplaySettings(YouAreInDangerViewController)
                self.curState = 3
                self.dangerSoundEffect?.play()
            }
        }
    }
    
    
    //Turns phone into an "advertising" iBeacon (independent of above code)
    
    var localBeacon: CLBeaconRegion!
    var beaconPeripheralData: NSDictionary!
    var peripheralManager: CBPeripheralManager!

    func initLocalBeacon() {
        if localBeacon != nil {
            stopLocalBeacon()
        }

        //IMPORTANT - use same UUID string as earlier
        let uuid = UUID(uuidString: UUID_STR)!
        let localBeacon = CLBeaconRegion(proximityUUID: uuid, major: 123, minor: 456, identifier: "beacon")

        beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
    }

    func stopLocalBeacon() {
        peripheralManager.stopAdvertising()
        peripheralManager = nil
        beaconPeripheralData = nil
        localBeacon = nil
    }

    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            peripheralManager.startAdvertising(beaconPeripheralData as? [String: Any])
        } else if peripheral.state == .poweredOff {
            peripheralManager.stopAdvertising()
        }
    }
    
    
}
