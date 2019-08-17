//
//  WorkoutHUDController.swift
//  WatchApp Extension
//
//  Created by Eric Jensen on 8/16/19.
//  Copyright © 2019 LoopKit Authors. All rights reserved.
//

import WatchKit
import WatchConnectivity
import LoopKit
import LoopCore

final class WorkoutHUDController: HUDInterfaceController {
    
    @IBOutlet var elapsedTimeLabel: WKInterfaceLabel!
    
    @IBOutlet var startButton: WKInterfaceButton!
    
    @IBAction func toggleTimer() {
        if timerIsRunning {
            startButton.setTitle("Start")
            elapsedTimeLabel.setText("00:00:00")
        } else {
            startButton.setTitle("Stop")
            elapsedTimeLabel.setText("running...")
        }
         timerIsRunning = !timerIsRunning
    }
    //  var timer: Timer
    
    var timerIsRunning = false
    
    
    
    override func willActivate() {
        super.willActivate()
        update()
    }
    
    override func update() {
        super.update()
      //  elapsedTimeLabel.setText("1")
    }
    
}
