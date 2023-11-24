//
//  VideoControlBar.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/24.
//

import UIKit

class VideoControlBar: UIView {
    
    let muteButton = RoundButton()
    let micButton = RoundButton()
    let cameraButton = RoundButton()
    
    convenience override init(frame: CGRect) {
        self.init(frame: frame)
        
        setupConstraints()
    }
    
    func setupConstraints() {
        
    }
}

