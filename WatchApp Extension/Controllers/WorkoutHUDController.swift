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
    
    override func willActivate() {
        super.willActivate()
        update()
    }
    
    
    override func update() {
        super.update()
    }
    
}
