//
//  RecordsViewController.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/12/8.
//

import UIKit

// MARK: RecordsViewModelProtocol
protocol RecordsViewModelProtocol {
    associatedtype Message: Identifiable

    var recordName: Box<String> { get }

    var messages: Box<[Message]> { get }

    func renameRecord(name: String)

    func editMessage(newText: String, messageId: Message.ID)
}

// MARK: RecordsViewController
class RecordsViewController: FSViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
