//
//  ResizeImage.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/12/14.
//

import UIKit

extension UIImage {
    func resizeWithLimit(limit: CGFloat) -> Data? {
        let ratio = size.width / size.height
        let newSize: CGSize
        
        if size.width > size.height {
            newSize = .init(width: limit, height: limit / ratio)
        } else {
            newSize = .init(width: limit * ratio, height: limit)
        }

        let newFrame = CGRect(origin: .zero, size: newSize)
        let imageView = UIImageView(frame: newFrame)
        imageView.contentMode = .scaleAspectFit
        imageView.image = self

        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)

        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)

        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()

        return result.pngData()
    }
}
