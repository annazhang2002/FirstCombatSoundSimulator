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
    private var scenarioSelected = -1
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let runViewController = segue.destination as?
            RunViewController {
            print("Preparing for RunViewController")
            runViewController.device = self.device
            runViewController.scenario = scenarioSelected
        }
    }
    
    
    @IBAction func scenario1Pressed(_ sender: UIButton) {
        self.scenarioSelected = 1
    }
    
    @IBAction func scenario2Pressed(_ sender: UIButton) {
        self.scenarioSelected = 2
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //set background image
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "camo")!)
    }
}
