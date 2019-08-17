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
        pauseResumeTimer()
    }
    
    var timerStart = NSDate()
    var savedTime: TimeInterval = 0.0
    var timer = Timer()
    let startColor = UIColor(red: 35/255, green: 124/255, blue: 0/255, alpha: 1.0)
    let stopColor = UIColor(red: 160/255, green: 40/255, blue: 0/255, alpha: 1.0)
    
    func startTimer(offset: TimeInterval) {
        timerStart = NSDate() // initialize to now
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true, block: {timer in self.elapsedTimeLabel.setText(self.timeString(time: abs(self.timerStart.timeIntervalSinceNow) + offset))})
    }
    
    func resetTimer() {
        timer.invalidate()
        timerIsRunning = false
        savedTime = 0
        startButton.setTitle("Start")
        startButton.setBackgroundColor(startColor)
        elapsedTimeLabel.setText(timeString(time: 0))
    }

    func pauseResumeTimer() {
        if timerIsRunning {
            timer.invalidate()
            // Reset the current saved time
            savedTime = abs(timerStart.timeIntervalSinceNow) + savedTime
            startButton.setTitle("Resume")
            startButton.setBackgroundColor(startColor)
        } else {
            startTimer(offset: savedTime)
            startButton.setTitle("Pause")
            startButton.setBackgroundColor(stopColor)
        }
        timerIsRunning = !timerIsRunning
    }


    //let timeInterval:TimeInterval = 0.05
    var timerIsRunning = false
    var elapsedTime:TimeInterval = 0.0

    
    override func willActivate() {
        super.willActivate()
        resetTimer()
//        update()
    }
    
//    override func update() {
//        super.update()
//    }
    
    private func timeString(time:TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time - Double(hours) * 3600) / 60
        let seconds = time - Double(minutes) * 60 - Double(hours) * 3600
        return String(format:"%02i:%02i:%04.1f",hours, minutes,seconds)
    }
    

}
