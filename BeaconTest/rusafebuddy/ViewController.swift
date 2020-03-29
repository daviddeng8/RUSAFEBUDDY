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
    
    //UIButton to trigger scanning when the home screen is pressed
    @IBAction func startScanning(_ sender: UIButton) {
        //getCurrentLocation()
        if (!leftHome) {
            leftHome = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentViewController = self
        // Do any additional setup after loading the view.
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization() //requests location services
        
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
        
        initLocalBeacon()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    startScanning()
                }
            }
        }
    }
    
    func startScanning() {
        //randomly generated UUID from terminal
        let uuid = UUID(uuidString: "3C5F9383-4ABC-4D7E-9396-193E28B44125")!
        let beaconRegion = CLBeaconRegion(proximityUUID: uuid, major: 123, minor: 456, identifier: "beacon")
        
        locationManager.startMonitoring(for: beaconRegion)
        locationManager.startRangingBeacons(in: beaconRegion)
        
    }
    
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
                updateDistance(1)
            }
        }
    }

    func updateDistance(_ rssi: Int) {
        /*let vc1 = YouAreSafeViewController()
        let vc2 = YouAreSlightlyInDangerViewController()
        let vc3 = YouAreInDangerViewController()*/
        
        //UIView.animate(withDuration: 0.8) {
            
            if rssi == 1 {
                if self.curState != 0 {
                    self.view.backgroundColor = UIColor.gray
                    //self.dismiss(animated: true, completion: nil)
                    self.curState = 0
                    let NoBuddiesFoundViewController = self.storyboard?.instantiateViewController(withIdentifier: "NoBuddies") as! NoBuddiesFoundViewController
                    NoBuddiesFoundViewController.isModalInPresentation = true
                    NoBuddiesFoundViewController.modalPresentationStyle = .fullScreen
                    //self.present(NoBuddiesFoundViewController, animated: true, completion: nil)
                    self.currentViewController.addChild(NoBuddiesFoundViewController)
                    self.currentViewController.view.addSubview(NoBuddiesFoundViewController.view)
                    self.currentViewController = NoBuddiesFoundViewController
                    //show(NoBuddiesFoundViewController, sender: self)
                    //self.navigationController?.pushViewController(NoBuddiesFoundViewController, animated: true)
                }
                
                   
            } else if rssi < -70 || (rssi < -65 && curState == 0) {
                if self.curState != 1 {
                    //self.dismiss(animated: true, completion: nil)
                    self.view.backgroundColor = UIColor.blue
                    let YouAreSafeViewController = self.storyboard?.instantiateViewController(withIdentifier: "Safe") as! YouAreSafeViewController
                    YouAreSafeViewController.isModalInPresentation = true
                    YouAreSafeViewController.modalPresentationStyle = .fullScreen
                    //self.present(YouAreSafeViewController, animated: true, completion: nil)
                    self.currentViewController.addChild(YouAreSafeViewController)
                    self.currentViewController.view.addSubview(YouAreSafeViewController.view)
                    self.currentViewController = YouAreSafeViewController
                    //show(YouAreSafeViewController, sender: self)
                    self.curState = 1
                    self.safeSoundEffect?.play()
                    //self.navigationController?.pushViewController(YouAreSafeViewController, animated: true)
                }
                
                //self.present(YouAreSafeViewController(), animated: true, completion: nil)
            //self.navigationController?.pushViewController(YouAreSafeViewController(), animated: true)
                
            } else if rssi < -63 && (rssi > -67 || curState == 0)  {
                if self.curState != 2 {
                    //self.dismiss(animated: true, completion: nil)
                    self.view.backgroundColor = UIColor.orange
                    let YouAreSlightlyInDangerViewController = self.storyboard?.instantiateViewController(withIdentifier: "SlightDanger") as! YouAreSlightlyInDangerViewController
                    YouAreSlightlyInDangerViewController.isModalInPresentation = true
                    YouAreSlightlyInDangerViewController.modalPresentationStyle = .fullScreen
                    //self.present(YouAreSlightlyInDangerViewController, animated: true, completion: nil)
                    self.currentViewController.addChild(YouAreSlightlyInDangerViewController)
                    self.currentViewController.view.addSubview(YouAreSlightlyInDangerViewController.view)
                    self.currentViewController = YouAreSlightlyInDangerViewController
                    //show(YouAreSlightlyInDangerViewController, sender: self)
                    if self.curState != 3 {
                        self.slightDangerSoundEffect?.play()
                    }
                    self.curState = 2
                    //self.navigationController?.pushViewController(YouAreSlightlyInDangerViewController, animated: true)
                }
               
               // self.present(YouAreSlightlyInDangerViewController(), animated: true, completion: nil)
                //self.navigationController?.pushViewController(YouAreSafeViewController(), animated: true)
            } else if rssi > -60 || curState == 0 {
                if self.curState != 3 {
                    //self.dismiss(animated: true, completion: nil)
                    self.view.backgroundColor = UIColor.red
                    let YouAreInDangerViewController = self.storyboard?.instantiateViewController(withIdentifier: "Danger") as! YouAreInDangerViewController
                    YouAreInDangerViewController.isModalInPresentation = true
                    YouAreInDangerViewController.modalPresentationStyle = .fullScreen
                    //self.present(YouAreInDangerViewController, animated: true, completion: nil)
                    self.currentViewController.addChild(YouAreInDangerViewController)
                    self.currentViewController.view.addSubview(YouAreInDangerViewController.view)
                    self.currentViewController = YouAreInDangerViewController
                    //show(YouAreInDangerViewController, sender: self)
                    self.curState = 3
                    self.dangerSoundEffect?.play()
                    //self.navigationController?.pushViewController(YouAreInDangerViewController, animated: true)
                }
                
                //self.present(YouAreInDangerViewController(), animated: true, completion: nil)
                //self.navigationController?.pushViewController(YouAreSafeViewController(), animated: true)
            }
            
            //self.label.text = "RSSI: \(rssi)"
           // self.view.addSubview(self.label)
       // }
    }
    
    
    //CODE TO MAKE PHONE INTO A BEACON
    
    var localBeacon: CLBeaconRegion!
    var beaconPeripheralData: NSDictionary!
    var peripheralManager: CBPeripheralManager!

    func initLocalBeacon() {
        if localBeacon != nil {
            stopLocalBeacon()
        }

        let uuid = UUID(uuidString: "3C5F9383-4ABC-4D7E-9396-193E28B44125")!
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
