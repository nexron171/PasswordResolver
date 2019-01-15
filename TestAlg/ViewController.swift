//
//  ViewController.swift
//  PasswordResolver
//
//  Created by Sergey Shirnin on 15/01/2019.
//  Copyright © 2019 Sergey Shirnin. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBAction func generateButtonPressed(_ sender: Any) {
        generatePasswords()
    }

    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var rawPasswordInput: NSTextField!
    @IBOutlet weak var activityIndicator: NSProgressIndicator!

    let cifers = [
        ["!", "@", "$", "#"],
        ["(", "_", "-", ")"],
        ["a", "b", "c", "^"],
        ["d", "e", "f", "*"],
        ["g", "h", "i", "A"],
        ["j", "k", "l", "B"],
        ["m", "n", "o", "C"],
        ["p", "q", "r", "D"],
        ["s", "t", "u", "v"],
        ["w", "x", "y", "z"]
    ]

    // Результирующая выборка
    var passwordsList: [String] = []

    // Основная функция
    func resolve(input: String) -> [String] {
        guard input.count >= 1 else { return [] }
        var variants: [String] = []

        var interestedList: [[String]] = []

        for char in input {
            let index = Int(String(char))!
            interestedList.append(cifers[index])
        }

        func getVariants(symbList: [String], nextIndex: Int) -> [String] {
            guard nextIndex < interestedList.count else {
                return symbList
            }

            let variants = getVariants(symbList: interestedList[nextIndex], nextIndex: nextIndex + 1)
            var results: [String] = []
            for symb in symbList {
                for variant in variants {
                    results.append(symb+variant)
                }
            }
            return results
        }

        guard interestedList.count > 1 else { return interestedList[0] }
        variants = getVariants(symbList: interestedList[0], nextIndex: 1)
        return variants
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
    }

    func generatePasswords() {
        let rawPassword = rawPasswordInput.stringValue
        let queue = DispatchQueue(label: "Resolve", qos: .background)
        activityIndicator.startAnimation(self)
        queue.async {
            self.passwordsList = self.resolve(input: rawPassword)
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.activityIndicator.stopAnimation(self)
            }
        }
    }
}

extension ViewController: NSTableViewDataSource, NSTableViewDelegate {

    func numberOfRows(in tableView: NSTableView) -> Int {
        return passwordsList.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "PasswordCell"), owner: nil) as? NSTableCellView else {
            return nil
        }
        cell.textField?.stringValue = passwordsList[row]
        return cell
    }
    
}
