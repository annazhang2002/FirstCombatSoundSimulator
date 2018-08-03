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
    
    var dragViewCenterX: Double = 0.0
    var dragViewCenterY: Double = 0.0
    let maxXPos: Double = 359.0
    let maxYPos: Double = 359.0
    var scaleX50: Double = 0.0
    var scaleY50: Double = 0.0
    var screenWidth: Double = 0.0
    var screenHeight: Double = 0.0
    var dragtoGraphDiff: Double = 0.0
    
    var dragStartPositionRelativeToCenter : CGPoint? //x and y of image
    
    @IBOutlet weak var doneButton: UIButton!
    
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView3: UIImageView!
    @IBOutlet weak var imageView4: UIImageView!
    @IBOutlet weak var imageView5: UIImageView!
    @IBOutlet weak var graphView: UIImageView!
    
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var label4: UILabel!
    @IBOutlet weak var label5: UILabel!
    @IBOutlet weak var backgroundLabel: UILabel!
    @IBOutlet weak var tesLabel: UILabel!
    @IBOutlet weak var testButton: UIButton!
    
    var labelArr: [UILabel] = []
    var imageArr: [UIImageView] = [] //stores images
    var coordinateArr: [CGPoint] = [] //stores coordinates of images
    
    @IBOutlet weak var dragView: UIView! //the graph
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let runViewController = segue.destination as? RunViewController{
            loadCoordinates()
            //print("Preparing for RunViewController")
            runViewController.device = self.device
            runViewController.scenario = self.scenario
            runViewController.pointArr = coordinateArr
            //runViewController.updateLabels()
            //print("image arrays connected")
        }
    }
    //scales coordinates to be in [-100,100]
    func loadCoordinates(){
        coordinateArr = []
        for i in 0..<imageArr.count{
            var center: CGPoint = imageArr[i].center
            center.x = CGFloat((Double(center.x) - dragViewCenterX) * scaleX50)
            center.y = CGFloat((dragViewCenterY - Double(center.y)) * scaleY50)
            coordinateArr.append(center)
            //print("x:\(Double(center.x) - dragViewCenterX), y:\(center.y)")
        }
    }
    
    @IBAction func displayPoint(_ sender: UIButton) {
        tesLabel.text = String("\(imageView1.center.y)")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set background image
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "camo3.jpg")!)
        
        //doneButton.layer.cornerRadius = 10
        screenWidth = Double(self.view.frame.width)
        screenHeight = Double(self.view.frame.height)
        scaleX50 = 50.0 / maxXPos
        scaleY50 = 50.0 / maxYPos
        dragtoGraphDiff = Double(dragView.frame.height - graphView.frame.height)
        
        //set center of graph to (0,0)
        dragViewCenterX = Double(self.view.frame.width / 2)
        dragViewCenterY = Double(768/2)+56

        print("center of dragView - x:\(dragViewCenterX), y\(dragViewCenterY)")
        print("diff btwn drag and graph Views: \(dragtoGraphDiff)")
        print("screen: x=\(screenWidth), y=\(screenHeight)")
        
        //bring graph, label to back layer
        graphView.layer.zPosition = 0
        backgroundLabel.layer.zPosition = 0
        //init arrays of labels and images
        labelArr = [label1,label2,label3,label4,label5]
        imageArr = [imageView1, imageView2, imageView3, imageView4, imageView5]
        
        //init positions of image 2 and 4
        imageView2.center.x = CGFloat(screenWidth/4)
        label2.center.x = CGFloat(screenWidth/4)
        imageView4.center.x = CGFloat(screenWidth*3/4)
        label4.center.x = CGFloat(screenWidth*3/4)
        
        //enable interactions for images, add gesture recognizer to imageView
        for image in imageArr {
            image.layer.zPosition = 1 // bring images to front layer
            image.isUserInteractionEnabled = true
            image.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(CustomViewController.handlePan)))
            //print("enabled")
        }
        for label in labelArr{
            label.layer.zPosition = 1
        }
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
