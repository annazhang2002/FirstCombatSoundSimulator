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
    
    @IBOutlet weak var beginButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    var device: MBLMetaWear!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let optionsViewController = segue.destination as?
            OptionsViewController {
            //print("Preparing for OptionsViewController")
            optionsViewController.device = self.device
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set background image
        //self.view.backgroundColor = UIColor(patternImage: UIImage(named: "star.jpg")!)
        
        self.view.backgroundColor = UIColor.white
        let screenSize: CGRect = UIScreen.main.bounds
        let bgImage = UIImageView(image: UIImage(named: "star.jpg"))
        bgImage.center = CGPoint(x: self.view.bounds.size.width / 2,y: self.view.bounds.size.height / 2)
        bgImage.transform = CGAffineTransform(scaleX: screenSize.width / 768, y: screenSize.height / 1024)
        self.view.addSubview(bgImage)
        bgImage.layer.zPosition = 0
        
        titleLabel.layer.zPosition = 1
        beginButton.layer.zPosition = 1
        beginButton.layer.cornerRadius = 10
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        device.addObserver(self, forKeyPath: "state", options: NSKeyValueObservingOptions.new, context: nil)
        device.connectAsync().success { _ in
            self.device.led?.flashColorAsync(UIColor.green, withIntensity: 1.0, numberOfFlashes: 3)
            //NSLog("We are connected")
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
