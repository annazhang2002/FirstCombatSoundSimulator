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
    
    @IBOutlet weak var scenario1Button: UIButton!
    @IBOutlet weak var scenario2Button: UIButton!
    @IBOutlet weak var customButton: UIButton!
    @IBOutlet weak var scenarioLabel: UILabel!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let runViewController = segue.destination as?
            RunViewController {
            //print("Preparing for RunViewController")
            runViewController.device = self.device
            runViewController.scenario = scenarioSelected
        }
        else if let customViewController = segue.destination as?
            CustomViewController {
            //print("Preparing for CustomViewController")
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
        //self.view.backgroundColor = UIColor(patternImage: UIImage(named: "camo3.jpg")!)
        self.view.backgroundColor = UIColor.white
        let screenSize: CGRect = UIScreen.main.bounds
        let bgImage = UIImageView(image: UIImage(named: "star.jpg"))
        bgImage.center = CGPoint(x: self.view.bounds.size.width / 2,y: self.view.bounds.size.height / 2)
        bgImage.transform = CGAffineTransform(scaleX: screenSize.width / 768, y: screenSize.height / 1024)
        self.view.addSubview(bgImage)
        bgImage.layer.zPosition = 0
        
        scenario1Button.layer.zPosition = 1
        scenario2Button.layer.zPosition = 1
        customButton.layer.zPosition = 1
        scenarioLabel.layer.zPosition = 1
        
        scenario1Button.layer.cornerRadius = 20
        scenario2Button.layer.cornerRadius = 20
        customButton.layer.cornerRadius = 20
    }
}
