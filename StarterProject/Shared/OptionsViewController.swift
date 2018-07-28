//
//  OptionsViewController.swift
//  firstCombatSoundSimulator
//
//  Created by student on 7/23/18.
//  Copyright © 2018 Anna Zhang. All rights reserved.
//

import UIKit
import AVFoundation
import MetaWear

protocol SendScenarioDelegate: class {
    func sendScenario(scene: Int)
}

class OptionsViewController: UIViewController {
    
    weak var scenarioSender: SendScenarioDelegate?
    
    var device: MBLMetaWear? = nil
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let runViewController = segue.destination as?
            RunViewController {
            print("Preparing for RunViewController")
            scenarioSender = runViewController
            runViewController.device = self.device
        }
    }
    
    
    @IBAction func scenario1Pressed(_ sender: UIButton) {
        self.scenarioSender?.sendScenario(scene: 1)
    }
    
    @IBAction func scenario2Pressed(_ sender: UIButton) {
        self.scenarioSender?.sendScenario(scene: 2)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //set background image
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "camo.jpg")!)
    }
}
