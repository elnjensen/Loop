//
//  WorkoutHUDController.swift
//  WatchApp Extension
//
//  Created by Eric Jensen on 8/16/19.
//  Copyright © 2019 LoopKit Authors. All rights reserved.
//

// Simple Watch face in Loop to display a stopwatch along with BG info
// to make exercise easier without switching apps.
// Note that the "timer" variable below isn't what keeps track of the
// elapsed time - it is a timer for display updates, so it is turned off
// when the face isn't displayed.  It is the timerStart variable that
// marks the start of the time interval, and we calculate and display offsets
// from that.


import WatchKit
import WatchConnectivity
import LoopKit
import LoopCore
import UIKit

final class WorkoutHUDController: HUDInterfaceController {
    
    @IBOutlet var elapsedTimeLabel: WKInterfaceLabel!
    
    @IBOutlet var startButton: WKInterfaceButton!
    
    @IBAction func toggleTimer() {
        pauseResumeTimer()
    }
    
    var timerStart = Date()
    var savedTime: TimeInterval = 0.0
    var timer = Timer()
    let startColor = UIColor(red: 35/255, green: 124/255, blue: 10/255, alpha: 0.9)
    let stopColor = UIColor(red: 160/255, green: 40/255, blue: 0/255, alpha: 0.9)
    
    func startTimer(offset: TimeInterval) {
        // Starting the timer redefines the variable timerStart to give the
        // correct total displayed time, taking into account pauses, even
        // if that isn't the actual time of initially starting the timer.
        timerStart = Date() - offset
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: {timer in self.elapsedTimeLabel.setAttributedText(self.timeString(time: abs(self.timerStart.timeIntervalSinceNow)))})
    }
    
    @IBAction func resetTimer() {
        timer.invalidate()
        timerIsRunning = false
        savedTime = 0
        startButton.setTitle("Start")
        startButton.setBackgroundColor(startColor)
        elapsedTimeLabel.setAttributedText(timeString(time: 0))
    }

    func pauseResumeTimer() {
        if timerIsRunning {
            timer.invalidate()
            // Reset the current saved time
            savedTime = abs(timerStart.timeIntervalSinceNow)
            startButton.setTitle("Resume")
            startButton.setBackgroundColor(startColor)
        } else {
            startTimer(offset: savedTime)
            startButton.setTitle("Pause")
            startButton.setBackgroundColor(stopColor)
        }
        timerIsRunning = !timerIsRunning
    }


    var timerIsRunning = false
    var shouldResumeTimer = false
    var elapsedTime:TimeInterval = 0.0
    

    
    override func willActivate() {
        super.willActivate()
        if shouldResumeTimer {
            //  Time we are tracking has been continuing to change while
            // controller out of view, update it:
            elapsedTime = abs(timerStart.timeIntervalSinceNow)
            elapsedTimeLabel.setAttributedText(timeString(time: elapsedTime))
            startTimer(offset: elapsedTime)
            shouldResumeTimer = false
        }
    }

    override func willDisappear() {
        if timerIsRunning {
            shouldResumeTimer = true
            timer.invalidate()
        } else {
            shouldResumeTimer = false
        }
    }
    
    // Activation on first run:
    override init() {
        super.init()
        resetTimer()
    }

    private func timeString(time:TimeInterval) -> NSAttributedString {
        let timeFont = UIFont.monospacedDigitSystemFont(ofSize:  UIFont.preferredFont(forTextStyle: .largeTitle).pointSize, weight: UIFont.Weight.regular)
        let hours = Int(time) / 3600
        let minutes = Int(time - Double(hours) * 3600) / 60
        let seconds = time - Double(minutes) * 60 - Double(hours) * 3600
        return NSAttributedString(string: String(format:"%02i:%02i:%02.0f",hours,minutes,seconds), attributes: [NSAttributedString.Key.font: timeFont])
    }
    

}
