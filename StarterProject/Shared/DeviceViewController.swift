//
//  DeviceViewController.swift
//  SwiftStarter
//
//  Created by Stephen Schiffli on 10/20/15.
//  Copyright © 2015 MbientLab Inc. All rights reserved.
//

import UIKit
import MetaWear
import AVFoundation

class DeviceViewController: UIViewController {
    
    var device: MBLMetaWear!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let optionsViewController = segue.destination as?
            OptionsViewController {
            print("Preparing for OptionsViewController")
            optionsViewController.device = self.device
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set background image
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "camo")!)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        device.addObserver(self, forKeyPath: "state", options: NSKeyValueObservingOptions.new, context: nil)
        device.connectAsync().success { _ in
            self.device.led?.flashColorAsync(UIColor.green, withIntensity: 1.0, numberOfFlashes: 3)
            NSLog("We are connected")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
         device.removeObserver(self, forKeyPath: "state")
         device.led?.flashColorAsync(UIColor.red, withIntensity: 1.0, numberOfFlashes: 3)
         device.disconnectAsync()
 
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        OperationQueue.main.addOperation {
            switch (self.device.state) {
            case .connected:
                print("Connected");
                self.device.sensorFusion?.mode = MBLSensorFusionMode.imuPlus
            case .connecting:
                print("Connecting");
            case .disconnected:
                print("Disconnected");
            case .disconnecting:
                print("Disconnecting");
            case .discovery:
                print("Discovery");
            }
        }
    }
    
}
