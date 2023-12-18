//
//  WhiteboardViewModel.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/12/18.
//

import UIKit
import PencilKit

class WhiteboardViewModel: MVVMViewModel {
    var drawingProvider: DrawingProvider?

    var drawing: Box<PKDrawing> = .init(.init())

    func update(meetingCode: MeetingRoom.MeetingCode) {
        guard drawingProvider == nil else { return }

        drawingProvider = .init(meetingCode: meetingCode)

        drawingProvider?.startListen { [weak self] stroke in
            guard let self else { return }

            drawing.value.strokes.append(stroke)
        }
    }

    func send(stroke: PKStroke) {
        if isLocal(stroke: stroke) {
            drawingProvider?.send(stroke: stroke)
        }
    }

    deinit {
        drawingProvider?.stopListenMessage()
    }

    private func isLocal(stroke: PKStroke) -> Bool {
        return !drawing.value.strokes.contains(where: { remoteStroke in
            stroke.path.creationDate == remoteStroke.path.creationDate
        })
    }
}
