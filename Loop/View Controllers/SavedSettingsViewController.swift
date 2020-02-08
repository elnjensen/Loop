//
//  SavedSettingsViewController.swift
//  Loop
//
//  Created by Eric Jensen on 2/7/20.
//  Copyright © 2020 LoopKit Authors. All rights reserved.
//

import Foundation
import HealthKit
import LoopKit
import LoopKitUI
import UIKit

final class SavedSettingsTableViewController: TextFieldTableViewController {
    
    init(testLabel: String) {
        
        super.init(style: .grouped)
        
        placeholder = NSLocalizedString("Save current settings", comment: "The placeholder text instructing users to save current settings")
        contextHelp = NSLocalizedString("Only those settings related to dosing will be saved.  Pump and CGM configuration will not.", comment: "Explanation of which settings are saved.")

     }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
