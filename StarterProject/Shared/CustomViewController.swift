//
//  customViewController.swift
//  firstCombatSoundSimulator
//
//  Created by student on 7/24/18.
//  Copyright © 2018 Anna Zhang. All rights reserved.
//

import UIKit
import AVFoundation
import MetaWear

class CustomViewController: UIViewController {
    
    var device: MBLMetaWear!
    var scenario: Int = 0
    
    //changed to...
    var dragViewCenterX: Double = 0.0
    var dragViewCenterY: Double = 0.0
    let maxXPos: Double = 152.0 // max x or y position of image
    var scale100: Double = 0.0 // constant to scale position to 100
    //...here
    
    var dragStartPositionRelativeToCenter : CGPoint? //x and y of image
    
    @IBOutlet weak var doneButton: UIButton!
    
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var graphView: UIImageView!
    
    var imageArr: [UIImageView] = [] //stores images
    var coordinateArr: [CGPoint] = [] //stores coordinates of images
    
    @IBOutlet weak var dragView: UIView! //the graph
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let runViewController = segue.destination as? RunViewController{
            loadCoordinates()
            print("Preparing for RunViewController")
            runViewController.device = self.device
            runViewController.scenario = self.scenario
            runViewController.pointArr = coordinateArr
            runViewController.updateLabels()
            print("image arrays connected")
        }
    }
    //scales coordinates to be in [-100,100]
    func loadCoordinates(){
        coordinateArr = []
        for i in 0..<imageArr.count{
            //changed to...
            var center: CGPoint = imageArr[i].center
            center.x = CGFloat((Double(center.x) - dragViewCenterX) * scale100)
            center.y = CGFloat((dragViewCenterY - Double(center.y)) * scale100)
            coordinateArr.append(center)
            print("x:\(Double(imageArr[i].center.x) - dragViewCenterX), y:\(imageArr[i].center.y)")
            //...here
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set background image
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "camo")!)
        
        //changed
        scale100 = 50.0 / maxXPos
        
        
        doneButton.setBackgroundImage(UIImage(named: "buttonimage"), for: UIControlState.normal)
        
        //changed to...
        //set center of graph to (0,0)
        dragViewCenterX = Double(dragView.frame.width / 2)
        dragViewCenterY = Double(dragView.frame.height / 2)
        print("center of dragView - x:\(dragViewCenterX), y\(dragViewCenterY)")
        
        //bring icons in front of graph
        imageView1.layer.zPosition = 1
        imageView2.layer.zPosition = 1
        graphView.layer.zPosition = 0
        //...here
        
        //set background image
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "camo.jpg")!)
        
        imageArr = [imageView1, imageView2]
        
        //enable interactions for images
        imageView1.isUserInteractionEnabled = true
        imageView2.isUserInteractionEnabled = true
        
        //add gesture recognizer to imageView
        imageView1.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(CustomViewController.handlePan)))
        imageView2.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(CustomViewController.handlePan)))
    }
    
    @objc func handlePan(gesture: UIGestureRecognizer!) {
        
        //get the x and y values and store them in a CGPoint
        if gesture.state == UIGestureRecognizerState.began {
            let locationInView = gesture.location(in: self.view)
            dragStartPositionRelativeToCenter = CGPoint(x: locationInView.x - (gesture.view?.center.x)!, y: locationInView.y - (gesture.view?.center.y)!)
            return
        }
        //if ended, nil
        if gesture.state == UIGestureRecognizerState.ended {
            dragStartPositionRelativeToCenter = nil
            return
        }
        
        let locationInView = gesture.location(in: self.view)
        //update the imageView's x and y to reflect the CGPoint
        if dragStartPositionRelativeToCenter != nil{
            //keep image within bounds
            var posX = locationInView.x - self.dragStartPositionRelativeToCenter!.x
            var posY = locationInView.y - self.dragStartPositionRelativeToCenter!.y
            let maxHeight = dragView.frame.height
            let maxWidth = dragView.frame.width
            let imageWidth = imageView1.frame.width / 2
            if posX >= (maxWidth - imageWidth) {
                posX = maxWidth - imageWidth
            } else if posX <= imageWidth {
                posX = imageWidth
            }
            if posY >= (maxHeight - imageWidth) {
                posY = maxHeight - imageWidth
            } else if posY <= imageWidth  {
                posY = imageWidth
            }
            //animate images
            UIImageView.animate(withDuration: 0.01) {
                gesture.view?.center = CGPoint(x: posX,y: posY)
            }
        }
    }
    
}
