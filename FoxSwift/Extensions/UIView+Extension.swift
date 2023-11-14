//
//  UIView + Extensions.swift
//  DV1
//
//  Created by chen shen yi on 2023/10/30.
//

import UIKit

extension Array where Element: UIView {
    
    @discardableResult
    func removeSuper() -> Self {
        forEach { $0.removeFromSuperview() }
        
        return self
    }
    
    @discardableResult
    func addTo(view: UIView) -> Self {
        removeSuper().forEach { view.addSubview($0) }
        return self
    }
    
    @discardableResult
    func turnOffAutoresizing() -> Self {
        forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        return self
    }
    
    
    // MARK: - Horizontal Arrange
    @discardableResult
    func horizontalArrange(constants: [CGFloat?], inView view: UIView? = nil) -> Self {
        
        if isEmpty { return self }
        
        let isInView = view == nil ? 0 : 1
        
        if constants.onSize(relativeTo: self, constant: 2 * isInView - 1,
                            ArrayName: "Constants") == nil
        {
            return self
        }
        
        if let view, let firstConstant = constants.first! {
            first!.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                            constant: firstConstant).isActive = true
        }
        if let view, let lastConstant = constants.last! {
            view.trailingAnchor.constraint(equalTo: last!.trailingAnchor,
                                           constant: lastConstant).isActive = true
        }
        
        zip(zip(self[0...], self[1...]), constants[isInView...])
            .filter { views, constant in constant != nil }
            .map { views, constant in
                views.1.leadingAnchor.constraint(equalTo: views.0.trailingAnchor,
                                                 constant: constant!)
            }.forEach { $0.isActive = true }
        
        return self
    }
    
    @discardableResult
    func horizontalArrange(constant: CGFloat, inView view: UIView? = nil) -> Self {
        let count = count - 1 + (view == nil ? 0 : 2)
        
        return horizontalArrange(constants: [CGFloat](repeating: constant, count: count),
                                 inView: view)
    }
    
    // MARK: - Vertical Arrange
    @discardableResult
    func verticalArrange(constants: [CGFloat?], inView view: UIView? = nil) -> Self {
        
        if isEmpty { return self }
        
        let isInView = view == nil ? 0 : 1
        
        if constants.onSize(relativeTo: self, constant: 2 * isInView - 1,
                            ArrayName: "Constants") == nil
        {
            return self
        }
        
        if let view, let firstConstant = constants.first! {
            first!.topAnchor.constraint(equalTo: view.topAnchor,
                                        constant: firstConstant).isActive = true
        }
        if let view, let lastConstant = constants.last! {
            view.bottomAnchor.constraint(equalTo: last!.bottomAnchor,
                                         constant: lastConstant).isActive = true
        }
        
        zip(zip(self[0...], self[1...]), constants[isInView...])
            .filter { views, constant in constant != nil }
            .map { views, constant in
                views.1.topAnchor.constraint(equalTo: views.0.bottomAnchor,
                                             constant: constant!)
            }.forEach { $0.isActive = true }
        
        return self
    }
    
    @discardableResult
    func verticalArrange(constant: CGFloat, inView view: UIView? = nil) -> Self {
        let count = count - 1 + (view == nil ? 0 : 2)
        
        return verticalArrange(constants: [CGFloat](repeating: constant, count: count),
                               inView: view)
    }
    
    // MARK: - Horizontal Align
    @discardableResult
    func alignLeading(toView view: UIView? = nil) -> Self {
        
        if isEmpty { return self }
        
        if let view {
            first!.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        }
        
        zip(self[0...], self[1...])
            .map { views in
                views.1.leadingAnchor.constraint(equalTo: views.0.leadingAnchor)
            }.forEach { $0.isActive = true }
        
        return self
    }
    
    @discardableResult
    func alignTrailing(toView view: UIView? = nil) -> Self {
        
        if isEmpty { return self }
        
        if let view {
            first!.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        }
        
        zip(self[0...], self[1...])
            .map { views in
                views.1.trailingAnchor.constraint(equalTo: views.0.trailingAnchor)
            }.forEach { $0.isActive = true }
        
        return self
    }
    
    @discardableResult
    func alignCenterX(toView view: UIView? = nil) -> Self {
        
        if isEmpty { return self }
        
        if let view {
            first!.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        }
        
        zip(self[0...], self[1...])
            .map { views in
                views.1.centerXAnchor.constraint(equalTo: views.0.centerXAnchor)
            }.forEach { $0.isActive = true }
        
        return self
    }
    
    // MARK: - Vertical Align
    @discardableResult
    func alignTop(toView view: UIView? = nil) -> Self {
        
        if isEmpty { return self }
        
        if let view {
            first!.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        }
        
        zip(self[0...], self[1...])
            .map { views in
                views.1.topAnchor.constraint(equalTo: views.0.topAnchor)
            }.forEach { $0.isActive = true }
        
        return self
    }
    
    @discardableResult
    func alignBottom(toView view: UIView? = nil) -> Self {
        
        if isEmpty { return self }
        
        if let view {
            first!.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        }
        
        zip(self[0...], self[1...])
            .map { views in
                views.1.bottomAnchor.constraint(equalTo: views.0.bottomAnchor)
            }.forEach { $0.isActive = true }
        
        return self
    }
    
    @discardableResult
    func alignCenterY(toView view: UIView? = nil) -> Self {
        
        if isEmpty { return self }
        
        if let view {
            first!.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        }
        
        zip(self[0...], self[1...])
            .map { views in
                views.1.centerYAnchor.constraint(equalTo: views.0.centerYAnchor)
            }.forEach { $0.isActive = true }
        
        return self
    }
    
    // MARK: - Set Height
    @discardableResult
    func setHeight(toConstant constant: CGFloat) -> Self {
        
        if isEmpty { return self }
        
        forEach { $0.heightAnchor.constraint(equalToConstant: constant).isActive = true }
        
        return self
    }
    
    func setHeight(toConstants constants: [CGFloat]) -> Self {
        guard constants.onSize(relativeTo: self, constant: 0,
                            ArrayName: "Constants") != nil else
        {
            return self
        }
        
        zip(self, constants).forEach { view, constant in
            view.heightAnchor.constraint(equalToConstant: constant).isActive = true
        }
        
        return self
    }
    
    @discardableResult
    func sameHeight() -> Self {
        if count<2 { return self }
        
        zip(self[0...], self[1...])
            .map { views in
                views.1.heightAnchor.constraint(equalTo: views.0.heightAnchor)
            }.forEach { $0.isActive = true }
        
        return self
    }
    
    // MARK: - Set Width
    @discardableResult
    func setWidth(toConstant constant: CGFloat) -> Self {
        
        if isEmpty { return self }
        
        forEach { $0.widthAnchor.constraint(equalToConstant: constant).isActive = true }
        
        return self
    }
    
    func setWidth(toConstants constants: [CGFloat]) -> Self {
        guard constants.onSize(relativeTo: self, constant: 0,
                            ArrayName: "Constants") != nil else
        {
            return self
        }
        
        zip(self, constants).forEach { view, constant in
            view.widthAnchor.constraint(equalToConstant: constant).isActive = true
        }
        
        return self
    }
    
    @discardableResult
    func sameWidth() -> Self {
        if count<2 { return self }
        
        zip(self[0...], self[1...])
            .map { views in
                views.1.widthAnchor.constraint(equalTo: views.0.widthAnchor)
            }.forEach { $0.isActive = true }
        
        return self
    }
}

extension Array {
    
    func onSize(expected num: Int, ArrayName: String) -> Self? {
        if count != num {
            print(ArrayName, "is expected \(num) elements, but get \(count).")
            return nil
        }
        return self
    }
    
    func onSize(relativeTo array: [some Any], constant: Int, ArrayName: String) -> Self? {
        onSize(expected: array.count + constant, ArrayName: ArrayName)
    }
}

