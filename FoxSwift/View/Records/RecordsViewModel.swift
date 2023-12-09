//
//  RecordsViewModel.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/12/9.
//

import Foundation

final class RecordsViewModel {
    var isEditing: Box<Bool> = .init(false)

    var meetingCodes: [Box<MeetingRoom.MeetingCode>] = [Box("424123"), Box("oaeu"), Box("aoe")]

    func deleteRecord(for: MeetingRoom.MeetingCode) {}

    func renameRecord(for: MeetingRoom.MeetingCode) {}

    func moveRecord(from oldIndex: Int, to newIndex: Int) {
        let meetingCode = meetingCodes.remove(at: oldIndex)
        meetingCodes.insert(meetingCode, at: newIndex)
    }
}

extension RecordsViewModel: FSEditableViewModel {}
