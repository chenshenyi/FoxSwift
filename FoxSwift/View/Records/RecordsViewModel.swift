//
//  RecordsViewModel.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/12/9.
//

import Foundation

final class RecordsViewModel {
    var meetingCodes: [Box<MeetingRoom.MeetingCode>] = [Box("424123"), Box("oaeu"), Box("aoe")]

    func deleteRecord(for index: Int) {
        meetingCodes.remove(at: index)
    }

    func renameRecord(for index: Int, to newName: String) {}

    func moveRecord(from oldIndex: Int, to newIndex: Int) {
        let meetingCode = meetingCodes.remove(at: oldIndex)
        meetingCodes.insert(meetingCode, at: newIndex)
    }
}
