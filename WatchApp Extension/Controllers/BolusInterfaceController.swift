//
//  BolusInterfaceController.swift
//  Naterade
//
//  Created by Nathan Racklyeft on 3/20/16.
//  Copyright © 2016 Nathan Racklyeft. All rights reserved.
//

import LoopCore
import WatchKit
import Foundation
import WatchConnectivity


final class BolusInterfaceController: WKInterfaceController, IdentifiableClass {

    fileprivate var pickerValue: Int = 0 {
        didSet {
            guard pickerValue >= 0 else {
                pickerValue = 0
                return
            }

            guard pickerValue <= maxPickerValue else {
                pickerValue = maxPickerValue
                return
            }

            let bolusValue = bolusValueFromPickerValue(pickerValue)

            switch bolusValue {
            case let x where x < 1:
                formatter.minimumFractionDigits = 2
            case let x where x < 10:
                formatter.minimumFractionDigits = 2
            default:
                formatter.minimumFractionDigits = 1
            }

            valueLabel.setText(formatter.string(from: bolusValue) ?? "--")
        }
    }

    private func pickerValueFromBolusValue(_ bolusValue: Double) -> Int {
        switch bolusValue {
        case let bolus where bolus > 10:
            return Int((bolus - 10.0) * 10) + pickerValueFromBolusValue(10)
        case let bolus where bolus > 1:
            return Int((bolus - 1.0) * 20) + pickerValueFromBolusValue(1)
        default:
            return Int(bolusValue * 40)
        }
    }

    private func bolusValueFromPickerValue(_ pickerValue: Int) -> Double {
        switch pickerValue {
        case let picker where picker > 220:
            return Double(picker - 220) / 10.0 + bolusValueFromPickerValue(220)
        case let picker where picker > 40:
            return Double(picker - 40) / 20.0 + bolusValueFromPickerValue(40)
        default:
            return Double(pickerValue) / 40.0
        }
    }

    private lazy var formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumIntegerDigits = 1

        return formatter
    }()

    private lazy var insulinFormatter: NumberFormatter = {
        let insulinFormatter = NumberFormatter()
        insulinFormatter.numberStyle = .decimal
        insulinFormatter.minimumIntegerDigits = 1
        insulinFormatter.minimumFractionDigits = 1
        insulinFormatter.maximumFractionDigits = 2

        return insulinFormatter
    }()

    private var maxPickerValue = 0

    /// 1.25
    @IBOutlet weak var valueLabel: WKInterfaceLabel!

    /// REC: 2.25 U
    @IBOutlet weak var recommendedValueLabel: WKInterfaceLabel!
    
    /// (Pending: 0.3 U)
    @IBOutlet weak var pendingValueLabel: WKInterfaceLabel!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)

        let maxBolusValue: Double = ExtensionDelegate.shared().loopManager.settings.maximumBolus ?? 10
        var pickerValue = 0

        if let context = context as? WatchContext, let recommendedBolus = context.recommendedBolusDose {
            pickerValue = pickerValueFromBolusValue(recommendedBolus)

//            if let valueString = formatter.string(from: recommendedBolus) {
//                recommendedValueLabel.setText(String(format: NSLocalizedString("Rec: %@ U", comment: "The label and value showing the recommended bolus"), valueString).localizedUppercase)
//            }
            
            if let iob = context.iob, let iobString = insulinFormatter.string(from: iob) {
                if let pendingInsulin = context.pendingInsulin, pendingInsulin > 0, let pendingValueString = insulinFormatter.string(from: pendingInsulin) {
                    pendingValueLabel.setText(String(format: NSLocalizedString("IOB %@ U\n (Pending: %@ U)", comment: "The label and value showing insulin on board and pending insulin"), iobString, pendingValueString))

                } else {
                    pendingValueLabel.setText(String(format: NSLocalizedString("IOB %@ U", comment: "The label and value showing insulin on board"), iobString))
                }
            }
        }

        self.maxPickerValue = pickerValueFromBolusValue(maxBolusValue)
        self.pickerValue = pickerValue

        crownSequencer.delegate = self
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didAppear() {
        super.didAppear()

        crownSequencer.focus()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    // MARK: - Actions

    @IBAction func decrement() {
        pickerValue -= 10

        WKInterfaceDevice.current().play(.directionDown)
    }

    @IBAction func increment() {
        pickerValue += 10

        WKInterfaceDevice.current().play(.directionUp)
    }

    @IBAction func deliver() {
        let bolusValue = bolusValueFromPickerValue(pickerValue)

        if bolusValue > 0 {
            let bolus = SetBolusUserInfo(value: bolusValue, startDate: Date())

            do {
                try WCSession.default.sendBolusMessage(bolus) { (error) in
                    DispatchQueue.main.async {
                        if let error = error {
                            ExtensionDelegate.shared().present(error)
                        } else {
                            ExtensionDelegate.shared().loopManager.addConfirmedBolus(bolus)
                        }
                    }
                }
            } catch {
                presentAlert(
                    withTitle: NSLocalizedString("Bolus Failed", comment: "The title of the alert controller displayed after a bolus attempt fails"),
                    message: NSLocalizedString("Make sure your iPhone is nearby and try again", comment: "The recovery message displayed after a bolus attempt fails"),
                    preferredStyle: .alert,
                    actions: [WKAlertAction.dismissAction()]
                )
                return
            }
        }

        dismiss()
    }

    // MARK: - Crown Sequencer

    fileprivate var accumulatedRotation: Double = 0
}

fileprivate let rotationsPerValue: Double = 1/24

extension BolusInterfaceController: WKCrownDelegate {
    func crownDidRotate(_ crownSequencer: WKCrownSequencer?, rotationalDelta: Double) {
        accumulatedRotation += rotationalDelta

        let remainder = accumulatedRotation.truncatingRemainder(dividingBy: rotationsPerValue)
        let delta = Int((accumulatedRotation - remainder) / rotationsPerValue)

        pickerValue += delta

        accumulatedRotation = remainder
    }
}
