//
//  customViewController.swift
//  firstCombatSoundSimulator
//
//  Created by student on 7/24/18.
//  Copyright © 2018 Anna Zhang. All rights reserved.
//

import UIKit
import AVFoundation

class CustomViewController: UIViewController {
    
    var dragStartPositionRelativeToCenter : CGPoint? //x and y of image
    
    @IBOutlet weak var doneButton: UIButton! // save coordinates, proceed
    @IBOutlet weak var imageView1: UIImageView! // mickeiy
    @IBOutlet weak var imageView2: UIImageView! // cat
    
    var imageArr: [UIImageView] = [] //stores images
    var coordinateArr: [CGPoint] = [] // stores coordinates
    
    @IBOutlet weak var dragView: UIView!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let displayVC = segue.destination as? RunViewController{
            loadCoordinates()
            displayVC.pointArr = coordinateArr
            displayVC.updateLabels()
            print("image arrays connected")
        }
    }
    
    func loadCoordinates(){
        coordinateArr = []
        print("imageArr")
        for i in 0..<imageArr.count{
            coordinateArr.append(imageArr[i].center)
            print("added to coordinateArr")
        }
    }
    
    // inits
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
