//
//  SoundPlayer.swift
//  firstCombatSoundSimulator
//
//  Created by student on 7/23/18.
//  Copyright © 2018 Anna Zhang. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class PlaySoundsController {
    
    //array that holds the string names of each sounds file
    var files : [String]
    
    //initializer to load into buffer
    init(files : [String]) {
        self.files = files
        loadFilesIntoBuffer()
    }
    
    //variables that store the various nodes and buffers
    private var buffer = AVAudioPCMBuffer()
    private var player = [AVAudioPlayerNode()]
    private var mixer3d = AVAudioEnvironmentNode()
    private var audioFile = AVAudioFile()
    private var engine = AVAudioEngine()
    
    private func loadFilesIntoBuffer(){
        
        var fileExtensionCount : Int
        var fileExtension : String = ""
        var fileName : String =  ""
        let loop = AVAudioPlayerNodeBufferOptions.loops
        var counter = 0
        
        let mixer = engine.mainMixerNode
        engine.attach(mixer3d)
        engine.connect(mixer3d, to: mixer, format: mixer3d.outputFormat(forBus: 0))
        for _ in 0..<files.count {
            player.append(AVAudioPlayerNode())
        }
        for index in files {
            
            fileExtensionCount = 0
            fileExtension = ""
            fileName =  ""
            fileExtensionCount = index.count - 3
            fileExtension = (fileExtension.padding(toLength: 3, withPad: index, startingAt: fileExtensionCount))
            fileName = (fileName.padding(toLength: (fileExtensionCount-1), withPad: index, startingAt: 0))
            print(fileName)
            print(fileExtension)
            guard let filePath = Bundle.main.url(forResource: fileName, withExtension: fileExtension)
                
                else {
                    print("Cannot find file")
                    return
            }
            
            do {
                audioFile = try AVAudioFile(forReading: filePath)
            }
            catch {
                print("Cannot load audiofile!")
            }
            //Second: we need to load the sound into a buffer
            
            buffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: AVAudioFrameCount(audioFile.length))
            
            do {
                try audioFile.read(into: buffer)
                print("File loaded")
                print(buffer.frameLength)
            }
            catch{
                print("Could not load file into buffer")
            }
            print("There are \(counter + 1) sounds")
            engine.attach(player[counter])
            engine.connect(player[counter], to: mixer3d, format: audioFile.processingFormat)
            mixer.renderingAlgorithm = .sphericalHead
            player[counter].renderingAlgorithm = AVAudio3DMixingRenderingAlgorithm(rawValue: 1)!
            player[counter].scheduleBuffer(buffer, at: nil, options: loop, completionHandler: nil)
            counter += 1
            
        }
        print("Players Ok")
        initEngine()
    }
    
    private func initEngine(){
        
        do {
            try engine.start()
        }
        catch {
            print("Cannot initialize engine")
        }
        initPositions()//(mixer3d, playerPosition: player)
    }
    
    func play(index: Int){
        player[index].play(at: AVAudioTime(hostTime: 0))
    }
    
    func stop(index: Int){
        player[index].pause()
    }
    
    private func initPositions(){
        
        mixer3d.listenerPosition.x = 0 //center
        mixer3d.listenerPosition.y = 0 //center
        mixer3d.listenerPosition.z = 0 //center
        for sound in player {
            sound.position = AVAudio3DPoint(x: 0.0, y: 0.0, z: 0.0)
            sound.volume = 1.0
        }
    }
    
    func updateVolume(index: Int, volume: Float) {
        player[index].volume = volume
    }
    
    func updatePosition(index: Int, position: AVAudio3DPoint){
        
        player[index].position = position
    }
    
    func updateAngularOrientation(_ degreesYaw: Float, _ rPart: Float, _ pPart: Float){
        mixer3d.listenerAngularOrientation.yaw = degreesYaw
        mixer3d.listenerAngularOrientation.roll = rPart
        mixer3d.listenerAngularOrientation.pitch = pPart
    }
    
    func updateListenerPosition(_ x: Float, _ y: Float, _ z: Float){
        mixer3d.listenerPosition.x = x
        mixer3d.listenerPosition.y = y
        mixer3d.listenerPosition.z = z
    }
    
    
}
