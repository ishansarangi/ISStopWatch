//
//  ViewController.swift
//  ISStopWatch
//
//  Created by Ishan Sarangi on 6/1/20.
//  Copyright © 2020 Ishan Sarangi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var mainTimerLabel: UILabel!
    @IBOutlet weak var millisecondsTimerLabel: UILabel!
    @IBOutlet weak var controlButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    
    //CA layers variables
    let stopwatchTrackLayer = CAShapeLayer()
    let stopwatchCircleFillLayer = CAShapeLayer()
    let stopwatchRoundLayer = CAShapeLayer()
    
    //timer
    var stopwatchTimer = Timer()
    var stopwatchSecondTimer = Timer()
    var stopwatchAnimationTimer = Timer()
    
    //color
    var trackColor = UIColor.gray.withAlphaComponent(0.5)
    var trackFillColor = UIColor.systemOrange
    var trackLeadColor = UIColor.systemRed
    
    var initialValue: CGFloat = 0.1
    
    var stopwatchSecondCount = 0
    var stopwatchMinuteCount = 0
    var milliSeconds = 0
    
    var stopwatchStarted = false {
        didSet {
            pauseButton.isEnabled = stopwatchStarted
            pauseButton.backgroundColor = stopwatchStarted ?
                (stopwatchPaused
                    ? UIColor.systemGreen.withAlphaComponent(0.8)
                    : UIColor.systemOrange
                )
                : UIColor.systemGray6
        }
    }
    var stopwatchPaused = false
    
    //animation
    lazy var strokeStartAnimation: CABasicAnimation = {
        let strokeStart = CABasicAnimation(keyPath: "strokeStart")
        strokeStart.duration = 60
        strokeStart.toValue = 1
        strokeStart.fillMode = .forwards
        return strokeStart
    }()
    
    lazy var strokeEndAnimation: CABasicAnimation = {
        let strokeEnd = CABasicAnimation(keyPath: "strokeEnd")
        strokeEnd.duration = 60
        strokeEnd.toValue = 1
        strokeEnd.fillMode = .forwards
        return strokeEnd
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
        
        self.setup()
    }
    
    func setup() {
        self.containerView.backgroundColor = UIColor.systemBackground
        
        self.setupLayers()
        self.setupControlButton()
        self.setupPauseButton()
        
    }
    
    func setupLayers(){
        // get the dimensions of the containerView and create a circle with a radius of 140
        let arcPath = UIBezierPath(arcCenter: CGPoint(x: containerView.frame.origin.x +
            (containerView.frame.width / 4),
            y: containerView.frame.origin.y -
                (containerView.frame.height / 2)),
                                   radius: 140, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        
        // set the stopwatchTrackLayer
        stopwatchTrackLayer.path = arcPath.cgPath
        stopwatchTrackLayer.strokeColor = trackColor.cgColor
        stopwatchTrackLayer.lineWidth = 8
        stopwatchTrackLayer.lineCap = .round
        stopwatchTrackLayer.fillColor = UIColor.clear.cgColor
        
        // set the stopwatchCircleFillLayer
        stopwatchCircleFillLayer.path = arcPath.cgPath
        stopwatchCircleFillLayer.lineWidth = 8
        stopwatchCircleFillLayer.strokeColor =  trackFillColor.cgColor
        stopwatchCircleFillLayer.lineCap = .round
        stopwatchCircleFillLayer.strokeEnd = 0
        stopwatchCircleFillLayer.fillColor = UIColor.lightGray.withAlphaComponent(0.25).cgColor
        
        // set the stopwatchRoundLayer
        stopwatchRoundLayer.path = arcPath.cgPath
        stopwatchRoundLayer.lineWidth = 20
        stopwatchRoundLayer.strokeColor = trackLeadColor.cgColor
        stopwatchRoundLayer.fillColor = UIColor.clear.cgColor
        stopwatchRoundLayer.strokeStart = (self.initialValue) / 100
        stopwatchRoundLayer.strokeEnd = (self.initialValue) / 100 + 0.004
        stopwatchRoundLayer.lineCap = .round
        
        // add the layers to the containerView
        containerView.layer.addSublayer(stopwatchTrackLayer)
        containerView.layer.addSublayer(stopwatchCircleFillLayer)
        containerView.layer.addSublayer(stopwatchRoundLayer)
    }
    
    func setupControlButton(){
        // customize the controlButton
        controlButton.layer.cornerRadius = 24
        controlButton.setTitleColor(UIColor.white, for: .normal)
        self.controlButton.setTitle("Start", for: .normal)
        self.controlButton.backgroundColor = UIColor.systemGreen
    }
    
    func setupPauseButton(){
        pauseButton.layer.cornerRadius = 24
        pauseButton.setTitleColor(UIColor.white, for: .normal)
        self.pauseButton.setTitle("Pause", for: .normal)
        self.pauseButton.backgroundColor = UIColor.systemOrange
        self.stopwatchPaused = false
        self.pauseButton.isEnabled = stopwatchStarted
        pauseButton.backgroundColor = stopwatchStarted ? (stopwatchPaused ? UIColor.systemGreen.withAlphaComponent(0.8): UIColor.systemOrange): UIColor.systemGray6
    }
    
    @IBAction func controlButtonTapped(_ sender: Any) {
        // stop all the timers on click of the control button
        self.stopwatchTimer.invalidate()
        self.stopwatchSecondTimer.invalidate()
        self.stopwatchAnimationTimer.invalidate()
        
        if (!stopwatchStarted) {
            // set the controlButton
            self.controlButton.setTitle("Stop", for: .normal)
            self.controlButton.backgroundColor = UIColor.systemRed.withAlphaComponent(0.8)
            
            // starts the stopwatch
            self.resetStopwatch()
            self.startStopwatch()
        } else {
            // sets the controlButton
            self.controlButton.setTitle("Start", for: .normal)
            self.controlButton.backgroundColor = UIColor.systemGreen
            
            // stops the stopwatch
            self.resetStopwatch()
        }
        self.stopwatchStarted = !self.stopwatchStarted
    }
    
    @IBAction func pauseButtonTapped(_ sender: Any) {
        self.stopwatchTimer.invalidate()
        self.stopwatchSecondTimer.invalidate()
        self.stopwatchAnimationTimer.invalidate()
        
        if (!stopwatchPaused) {
            // set the controlButton
            self.pauseButton.setTitle("Resume", for: .normal)
            self.pauseButton.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.8)
            
            // starts the stopwatch
            self.pauseStopwatch()
        } else {
            // sets the controlButton
            self.pauseButton.setTitle("Pause", for: .normal)
            self.pauseButton.backgroundColor = UIColor.systemOrange
            
            // stops the stopwatch
            self.resumeStopwatch()
        }
        self.stopwatchPaused = !self.stopwatchPaused
    }
    
    //MARK:- functions for the viewController
    func startStopwatch(){
        self.startTimer()
        // start the animation for the Layers for the first time
        animateStopwatch()
        
        // repeat filling of the circle layers every 60 seconds.
        stopwatchAnimationTimer =  Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { (Timer) in
            // swap the colors to give a nice effect on the trackLayer
            let tempColor = self.trackLeadColor
            self.trackLeadColor = self.trackFillColor
            self.trackFillColor = tempColor
            
            self.stopwatchTrackLayer.strokeColor = self.trackLeadColor.withAlphaComponent(0.25).cgColor
            self.animateStopwatch()
        }
    }
    
    func pauseStopwatch() {
        pauseLayer(layer: self.stopwatchRoundLayer)
        pauseLayer(layer: self.stopwatchCircleFillLayer)
    }

    func resumeStopwatch() {
        self.startTimer()
        resumeAnimation(layer: self.stopwatchRoundLayer)
        resumeAnimation(layer: self.stopwatchCircleFillLayer)
    }

    // function to reset the stopWatch
    func resetStopwatch(){
        // set all the values to default
        self.stopwatchSecondCount = 0
        self.initialValue = 0.1
        self.milliSeconds = 0
        self.stopwatchMinuteCount = 0
        
        // reset the layers to the starting point
        self.stopwatchRoundLayer.strokeStart = (self.initialValue) / 100
        self.stopwatchRoundLayer.strokeEnd = (self.initialValue) / 100 + 0.004
        self.stopwatchCircleFillLayer.strokeEnd = 0
        self.mainTimerLabel.text = "00:00"
        self.millisecondsTimerLabel.text = "00"
        
        // reset the colors of the layers
        trackFillColor = UIColor.systemRed
        trackLeadColor = UIColor.systemOrange
        trackColor = UIColor.gray.withAlphaComponent(0.5)
        
        // remove all the animations from the layers
        self.stopwatchCircleFillLayer.removeAllAnimations()
        self.stopwatchRoundLayer.removeAllAnimations()
        
        self.setupPauseButton()
    }

    func startTimer() {
        // start the milliSeconds Timer
        stopwatchSecondTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { (Timer) in
            self.milliSeconds += 1
            self.millisecondsTimerLabel.text = "\(self.milliSeconds)"
        })
        
        // start the minute & seconds timer
        stopwatchTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (Timer) in
            self.stopwatchSecondCount += 1
            
            if (self.stopwatchSecondCount == 60){
                self.stopwatchSecondCount = 0
                self.stopwatchMinuteCount += 1
            }
            self.mainTimerLabel.text = "\(Int(self.stopwatchMinuteCount).appendZeros()):\(Int(self.stopwatchSecondCount).appendZeros())"
        }

    }
    
    // function to animates the layers
    func animateStopwatch(){
        self.stopwatchCircleFillLayer.add(self.strokeEndAnimation, forKey: "circleShape")
        self.stopwatchRoundLayer.add(self.strokeStartAnimation, forKey: "roundShape")
        self.stopwatchRoundLayer.add(self.strokeEndAnimation, forKey: "roundEnd")
    }
    
    // function to pause animation of the layers
    func pauseLayer(layer : CALayer){
        let pausedTime : CFTimeInterval = layer.convertTime(CACurrentMediaTime(), from: nil)
        layer.speed = 0.0
        layer.timeOffset = pausedTime
    }
    
    // function to resume animation of the layers
    func resumeAnimation(layer : CALayer){
        let pausedTime = layer.timeOffset
        layer.speed = 1.0
        layer.timeOffset = 0.0
        layer.beginTime = 0.0
        let timeSincePause = layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        layer.beginTime = timeSincePause
    }
}

extension Int{
    func appendZeros() -> String {
        if (self < 10) {
            return "0\(self)"
        } else {
            return "\(self)"
        }
    }
}
