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
        let startTime = Date()
        guard input.count >= 1 else { return [] }
        var variants: [String] = []

        var interestedList: [[String]] = []

        for char in input {
            let index = Int(String(char))!
            interestedList.append(cifers[index])
        }

        func getVariants(symbList: [String], nextIndex: Int, index: Int? = nil) -> [String] {
            guard nextIndex < interestedList.count else {
                return symbList
            }

            let variants = getVariants(symbList: interestedList[nextIndex], nextIndex: nextIndex + 1)
            var results: [String] = []
            if let index = index {
                for variant in variants {
                    results.append(symbList[index]+variant)
                }
            } else {
                for symb in symbList {
                    for variant in variants {
                        results.append(symb+variant)
                    }
                }
            }

            return results
        }

        guard interestedList.count > 1 else { return interestedList[0] }

        let queueA = DispatchQueue(label: "qA", qos: .background)
        let queueB = DispatchQueue(label: "qB", qos: .background)
        let queueC = DispatchQueue(label: "qC", qos: .background)
        let queueD = DispatchQueue(label: "qD", qos: .background)

        let groupA = DispatchGroup()
        let groupB = DispatchGroup()
        let groupC = DispatchGroup()
        let groupD = DispatchGroup()

        var resultsA: [String] = []
        var resultsB: [String] = []
        var resultsC: [String] = []
        var resultsD: [String] = []

        groupA.enter()
        groupB.enter()
        groupC.enter()
        groupD.enter()

        queueA.async {
            resultsA = getVariants(symbList: interestedList[0], nextIndex: 1, index: 0)
            groupA.leave()
        }
        queueB.async {
            resultsB = getVariants(symbList: interestedList[0], nextIndex: 1, index: 1)
            groupB.leave()
        }
        queueC.async {
            resultsC = getVariants(symbList: interestedList[0], nextIndex: 1, index: 2)
            groupC.leave()
        }
        queueD.async {
            resultsD = getVariants(symbList: interestedList[0], nextIndex: 1, index: 3)
            groupD.leave()
        }

        groupA.wait()
        groupB.wait()
        groupC.wait()
        groupD.wait()

        //        variants = getVariants(symbList: interestedList[0], nextIndex: 1, start: 0, end: 1)
        let endTime = Date()
        print("Elapsed: \(endTime.timeIntervalSince(startTime))")
        return resultsA + resultsB + resultsC + resultsD
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
