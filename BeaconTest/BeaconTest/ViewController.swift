//
//  ViewController.swift
//  BeaconTest
//
//  Created by David Deng on 3/27/20.
//  Copyright © 2020 David Deng. All rights reserved.
//

import UIKit

import CoreBluetooth
import CoreLocation

//https://www.hackingwithswift.com/example-code/location/how-to-make-an-iphone-transmit-an-ibeacon

class ViewController: UIViewController, CLLocationManagerDelegate, CBPeripheralManagerDelegate {
    var locationManager: CLLocationManager!
    var label: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization() //requests location services
        
        //getCurrentLocation()
        
        label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
        label.center = CGPoint(x: 160, y: 285)
        label.textAlignment = .center
        
        initLocalBeacon()
        updateDistance(.far, 46)
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
        let uuid = UUID(uuidString: "3C5F9383-4ABC-4D7E-9396-193E28B44125")!
        let beaconRegion = CLBeaconRegion(proximityUUID: uuid, major: 123, minor: 456, identifier: "beacon")
        
        locationManager.startMonitoring(for: beaconRegion)
        locationManager.startRangingBeacons(in: beaconRegion)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        if beacons.count > 0 {
            updateDistance(beacons[0].proximity, beacons[0].rssi)
        } else {
            updateDistance(.unknown, 0)
        }
    }

    func updateDistance(_ distance: CLProximity, _ rssi: Int) {
        UIView.animate(withDuration: 0.8) {
            switch distance {
            case .unknown:
                self.view.backgroundColor = UIColor.gray

            case .far:
                self.view.backgroundColor = UIColor.blue
                
            case .near:
                self.view.backgroundColor = UIColor.orange

            case .immediate:
                self.view.backgroundColor = UIColor.red
            @unknown default:
                fatalError()
            }
            
            self.label.text = "RSSI: \(rssi)"
            self.view.addSubview(self.label)
        }
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

