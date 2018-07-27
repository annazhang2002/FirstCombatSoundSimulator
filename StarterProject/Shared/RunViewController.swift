//
//  runViewController.swift
//  firstCombatSoundSimulator
//
//  Created by student on 7/24/18.
//  Copyright © 2018 Anna Zhang. All rights reserved.
//

import UIKit
import AVFoundation

class RunViewController: UIViewController {
    
    var soundPlayer: PlaySoundsController? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //set background image
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "camo.jpg")!)
        
    }
    
    @IBAction func startPressed(_ sender: UIButton) {
        loadSounds()
        
    }
    
    @IBAction func stopPressed(_ sender: UIButton) {
        
        
    }
    
    
    func loadSounds() {
        
        //adding the sound files to an array
        var soundArray : [String] = []
        
        /* sounds
         * 0.wav : sandyRockRunning
         * 1.wav : gunShots
         */
        
        
        for index in 0...0 {
            soundArray.append(String(index) + ".wav")
        }
        
        
        //initializing the player with the soundArray files
        soundPlayer = PlaySoundsController(files: soundArray)
        
        //put the sounds into specific positions
        soundPlayer?.updatePosition(index: 0, position: AVAudio3DPoint(x: 50, y: 50, z: 0))
        
        
        //plays the sounds in the array
        for sound in soundArray.enumerated() {
            soundPlayer?.play(index: sound.offset)
        }
        
        
        
    }
    
    
}
