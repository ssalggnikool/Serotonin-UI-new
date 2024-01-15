//
//  a.swift
//  barracuta
//
//  Created by samara on 1/14/24.
//  Copyright © 2024 samiiau. All rights reserved.
//

import Foundation
import UIKit

class OptionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    var tableView: UITableView!
    var tableData = [
        ["About"],
        ["Beta iOS", "Verbose Boot", "Hide Internal Text"],
        ["PUAF Pages", "Static Headroom"],
        ["Set Defaults"]
    ]

    var sectionTitles = [
        "\(Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "")", "Options", "Exploit", ""
    ]
    
    var settingsManager = SettingsManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        self.title = "Options"
        tableView = UITableView(frame: view.bounds, style: .insetGrouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 40, right: 0)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func numberOfSections(in tableView: UITableView) -> Int { return sectionTitles.count }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return tableData[section].count }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? { return sectionTitles[section] }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let sectionTitle = sectionTitles[section]
        if sectionTitle.isEmpty { return 0 }
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let title = sectionTitles[section]
        let headerView = CustomSectionHeader(title: title)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = "Cell"
        let cell = UITableViewCell(style: .value1, reuseIdentifier: reuseIdentifier)
        cell.selectionStyle = .none
        cell.accessoryType = .none

        let cellText = tableData[indexPath.section][indexPath.row]
        cell.textLabel?.text = cellText

        switch cellText {
        case "About":
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .default

        case "Set Defaults":
            cell.textLabel?.textColor = UIColor(named: "AccentColor")
            cell.selectionStyle = .default
            
        case "Static Headroom":
            let stepper = UIStepper()
            stepper.value = Double(settingsManager.staticHeadroom)
            stepper.minimumValue = 0
            stepper.maximumValue = 1920
            stepper.stepValue = 128
            stepper.addTarget(self, action: #selector(stepperValueChanged(_:)), for: .valueChanged)

            cell.accessoryView = stepper
            cell.detailTextLabel?.text = "\(settingsManager.staticHeadroom) MB"
            
        case "PUAF Pages":
            let switchView = UISwitch()
            switchView.isOn = switchStateForSetting(cellText)
            switchView.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
            cell.accessoryView = switchView
            cell.detailTextLabel?.text = "3072"
            
        case "Beta iOS", "Verbose Boot", "Hide Internal Text":
            let switchView = UISwitch()
            switchView.isOn = switchStateForSetting(cellText)
            switchView.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
            cell.accessoryView = switchView
            
        default:
            break
        }

        return cell
    }
    
    @objc func stepperValueChanged(_ sender: UIStepper) {
        let value = Int(sender.value)
        settingsManager.staticHeadroom = value
        
        if let sectionIndex = sectionTitles.firstIndex(of: "Exploit"),
           let rowIndex = tableData[sectionIndex].firstIndex(of: "Static Headroom") {
            
            let indexPath = IndexPath(row: rowIndex, section: sectionIndex)
            
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.detailTextLabel?.text = "\(value) MB"
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellText = tableData[indexPath.section][indexPath.row]

        switch cellText {
        case "Set Defaults":
            settingsManager.resetToDefaultDefaults()
            UIView.transition(with: tableView, duration: 0.4, options: .transitionCrossDissolve, animations: {
                tableView.reloadData() // Update the table to reflect the changes with animation
            }, completion: nil)
        case "About":
            let aboutView = AboutViewController()
            navigationController?.pushViewController(aboutView, animated: true)
        default:
            break
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

    
    @objc func switchChanged(_ sender: UISwitch) {
        guard let cell = findCell(for: sender) else {
            return
        }
        
        if let indexPath = tableView.indexPath(for: cell) {
            let setting = tableData[indexPath.section][indexPath.row]
            switch setting {
            case "PUAF Pages":
                settingsManager.puafPages = sender.isOn
            case "Beta iOS":
                settingsManager.isBetaIos = sender.isOn
            case "Verbose Boot":
                settingsManager.verboseBoot = sender.isOn
            case "Hide Internal Text":
                settingsManager.hideInternalText = sender.isOn
            default:
                break
            }
        }
    }
    
    private func switchStateForSetting(_ setting: String) -> Bool {
        switch setting {
        case "PUAF Pages":
            return settingsManager.puafPages
        case "Beta iOS":
            return settingsManager.isBetaIos
        case "Verbose Boot":
            return settingsManager.verboseBoot
        case "Hide Internal Text":
            return settingsManager.hideInternalText
        default:
            return false
        }
    }
    
    private func findCell(for switchView: UISwitch) -> UITableViewCell? {
        var view = switchView
        while let superview = view.superview {
            if let cell = superview as? UITableViewCell {
                return cell
            }
            view = superview as! UISwitch
        }
        return nil
    }
}
