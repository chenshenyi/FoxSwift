//
//  WhiteboardViewController.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/12/18.
//

import PencilKit
import UIKit

class WhiteboardViewController: FSViewController, MVVMView {
    // MARK: - ViewModel
    typealias ViewModel = WhiteboardViewModel

    var viewModel: WhiteboardViewModel?

    func setupViewModel(viewModel: WhiteboardViewModel) {}

    // MARK: Subview
    var pencilButton = FSButton()
    let canvasView = PKCanvasView()
    let toolPicker = PKToolPicker()

    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Whiteboard"

        setupCanvasView()

        setupConstraints()
    }

    func setupCanvasView() {
        canvasView.layer.cornerRadius = 10
        canvasView.tool = PKInkingTool(.pen, color: .gray, width: 10)
        canvasView.delegate = self
        canvasView.drawingPolicy = .anyInput
    }

    func setupConstraints() {
        canvasView.addTo(view) { make in
            make.horizontalEdges.equalToSuperview()
            make.verticalEdges.equalToSuperview().inset(15)
        }
    }
}

extension WhiteboardViewController: PKCanvasViewDelegate {
    func canvasViewDidBeginUsingTool(_ canvasView: PKCanvasView) {
        print(canvasView.drawing.strokes.count)
    }

    func canvasViewDidEndUsingTool(_ canvasView: PKCanvasView) {
        print(canvasView.drawing.strokes.count)
        guard let stroke = canvasView.drawing.strokes.first else { return }
        
    }

    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        print(canvasView.drawing.strokes.count)
    }

    func canvasViewDidFinishRendering(_ canvasView: PKCanvasView) {
        print("Finish".blue)
    }
}
