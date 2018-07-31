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

class OptionsViewController: UIViewController {
    
    var device: MBLMetaWear? = nil
    var scenarioSelected = 0
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let runViewController = segue.destination as?
            RunViewController {
            print("Preparing for RunViewController")
            runViewController.device = self.device
            runViewController.scenario = scenarioSelected
        }
        else if let customViewController = segue.destination as?
            CustomViewController {
            print("Preparing for CustomViewController")
            customViewController.device = self.device
            customViewController.scenario = scenarioSelected
        }
    }
    
    @IBAction func aScenario1Pressed(_ sender: UIButton) {
        self.scenarioSelected = 1
    }
    
    @IBAction func aScenario2Pressed(_ sender: UIButton) {
        self.scenarioSelected = 2
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //set background image
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "camo")!)
    }
}
