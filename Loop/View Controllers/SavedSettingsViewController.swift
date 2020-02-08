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
import LoopCore
import UIKit

final class SavedSettingsTableViewController: TextFieldTableViewController {
    
    private lazy var numFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()

        numberFormatter.maximumSignificantDigits = 3
        numberFormatter.minimumFractionDigits = 1

        return numberFormatter
    }()

    init(manager: DeviceDataManager) {
        
        super.init(style: .grouped)
        
        let maxBolus = numFormatter.string(from: manager.loopManager.settings.maximumBasalRatePerHour ?? 0)
        placeholder = NSLocalizedString("Save current settings", comment: "The placeholder text instructing users to save current settings")
        contextHelp = String(format: NSLocalizedString("Only those settings related to dosing will be saved.  Pump and CGM configuration will not. Current max bolus is %@", comment: "Explanation of which settings are saved."),  maxBolus!)

     }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
