//
//  runViewController.swift
//  firstCombatSoundSimulator
//
//  Created by student on 7/24/18.
//  Copyright © 2018 Anna Zhang. All rights reserved.
//

import UIKit
import AVFoundation
import MetaWear
class RunViewController: UIViewController, SendScenarioDelegate {
    
    var scene: Int?
    var soundArray : [String] = []
    
    
    var optionsViewController: OptionsViewController?
    
    func sendScenario(scene: Int) {
        self.scene = scene
        print("Scenario: " + String(scene))
    }
    
    var playSoundsController: PlaySoundsController? = nil
    
    @IBOutlet weak var deviceStatus: UILabel!
    
    let PI : Double = 3.14159265359
    
    var device: MBLMetaWear!
    
    
    func data (p: Float, y : Float, r: Float) {
        print("p: " + String(p))
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        /*
         device.addObserver(self, forKeyPath: "state", options: NSKeyValueObservingOptions.new, context: nil)
         device.connectAsync().success { _ in
         self.device.led?.flashColorAsync(UIColor.green, withIntensity: 1.0, numberOfFlashes: 3)
         NSLog("We are connected")
         }
         */
        loadSounds()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //disconnect the sensors when the view disappears
        device.removeObserver(self, forKeyPath: "state")
        device.led?.flashColorAsync(UIColor.red, withIntensity: 1.0, numberOfFlashes: 3)
        device.disconnectAsync()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        OperationQueue.main.addOperation {
            switch (self.device.state) {
            case .connected:
                self.deviceStatus.text = "Connected";
                self.device.sensorFusion?.mode = MBLSensorFusionMode.imuPlus
                print("connected")
                
            case .connecting:
                self.deviceStatus.text = "Connecting";
                print("connecting")
            case .disconnected:
                self.deviceStatus.text = "Disconnected";
                print("Disconnected")
            case .disconnecting:
                self.deviceStatus.text = "Disconnecting";
                print("Disconnecting")
            case .discovery:
                self.deviceStatus.text = "Discovery";
                print("Discovery")
            }
        }
    }
    
    func getFusionValues(obj: MBLEulerAngleData){
        
        let xS =  String(format: "%.02f", (obj.p))
        let yS =  String(format: "%.02f", (obj.y))
        let zS =  String(format: "%.02f", (obj.r))
        
        let x = radians((obj.p * -1) + 90)
        let y = radians(abs(365 - obj.y))
        let z = radians(obj.r)
        
        print("X: " + String(x))
        print("Y: " + String(y))
        print("Z: " + String(z))
        playSoundsController?.updateAngularOrientation(abs(Float(365 - obj.y)))
        
        // Send OSC here
    }
    
    func radians(_ degree: Double) -> Double {
        return ( PI/180 * degree)
    }
    func degrees(_ radian: Double) -> Double {
        return (180 * radian / PI)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //set background image
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "camo.jpg")!)
        
        optionsViewController?.scenarioSender = self
    }
    
    @IBAction func startPressed(_ sender: UIButton) {
        
        device.sensorFusion?.eulerAngle.startNotificationsAsync { (obj, error) in
            self.getFusionValues(obj: obj!)
            }.success { result in
                print("Successfully subscribed")
            }.failure { error in
                print("Error on subscribe: \(error)")
        }
        
        //plays the sounds in the array
        for sound in soundArray.enumerated() {
            playSoundsController?.play(index: sound.offset)
        }
        
    }
    
    @IBAction func stopPressed(_ sender: UIButton) {
        
        device.sensorFusion?.eulerAngle.stopNotificationsAsync().success { result in
            print("Successfully unsubscribed")
            }.failure { error in
                print("Error on unsubscribe: \(error)")
        }
        
        //plays the sounds in the array
        for sound in soundArray.enumerated() {
            playSoundsController?.stop(index: sound.offset)
        }
        
    }
    
    
    func loadSounds() {
        
        /* sounds
         * 0.wav : AK47
         * 1.wav : Explosion 2
         * 2.wav : Explosion
         * 3.wav : Grenade Launcher
         * 4.wav : Helicopter 2
         * 5.wav : Helicopter Flyby
         * 6.wav : Helicopter
         * 7.wav : Machine Gun 1
         * 8.wav : Machine Gun 2
         * 9.wav : Machine Gun 3
         * 10.wav : Machine Gun 4
         * 11.wav : Overal Battle
         * 12.wav : Shotgun
         * 13.wav : Sniper Rifle
         * 14.wav : Tank
         */
        
        
        for index in 0...14 {
            soundArray.append(String(index) + ".wav")
        }
        
        
        //initializing the player with the soundArray files
        playSoundsController = PlaySoundsController(files: soundArray)
        
        //put the sounds into specific positions
        playSoundsController?.updatePosition(index: 0, position: AVAudio3DPoint(x: 50, y: 50, z: 0))
        
    }
    
    func sendScenario(scenario: Int) {
        print(scenario)
    }
    
}
