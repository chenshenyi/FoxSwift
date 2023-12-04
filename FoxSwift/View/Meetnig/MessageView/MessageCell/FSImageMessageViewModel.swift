//
//  FSImageMessageViewModel.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/12/4.
//

import UIKit

class FSImageMessageViewModel: FSMessageViewModel {
    var content: Box<UIImage?> = .init(.init(systemName: "photo"))
    
    override func setup(message: FSMessage) {
        super.setup(message: message)
        
        let data = message.data
        
        content.value = UIImage(data: data)
    }
}
