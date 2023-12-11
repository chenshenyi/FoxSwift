//
//  MeetingPrepareViewModel.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/12/11.
//

import Foundation

class MeetingPrepareViewModel {
    var isCameraOn = Box(true)
    var isMicOn = Box(true)

    var meetingName = Box("Normal Meet")
    var url = Box("http://meeting/nykd54")
}
