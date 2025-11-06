//
//  File.swift
//  MKBaseSwiftModule
//
//  Created by aa on 2025/5/30.
//

import UIKit

import MKBaseSwiftModule

public extension UIScrollView {
    // MARK: - Convenience Scroll Methods
    
    func mk_scrollToTop(animated: Bool = true) {
        var offset = contentOffset
        offset.y = -contentInset.top
        setContentOffset(offset, animated: animated)
    }
    
    func mk_scrollToBottom(animated: Bool = true) {
        var offset = contentOffset
        offset.y = max(-contentInset.top, contentSize.height - bounds.height + contentInset.bottom)
        setContentOffset(offset, animated: animated)
    }
    
    func mk_scrollToLeft(animated: Bool = true) {
        var offset = contentOffset
        offset.x = -contentInset.left
        setContentOffset(offset, animated: animated)
    }
    
    func mk_scrollToRight(animated: Bool = true) {
        var offset = contentOffset
        offset.x = max(-contentInset.left, contentSize.width - bounds.width + contentInset.right)
        setContentOffset(offset, animated: animated)
    }
    
    // MARK: - Touch Handling
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        next?.touchesMoved(touches, with: event)
        super.touchesMoved(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        next?.touchesEnded(touches, with: event)
        super.touchesEnded(touches, with: event)
    }
}

public extension UISegmentedControl {
    func mk_setTintColor(_ tintColor: UIColor) {
        let tintColorImage = image(with: tintColor)
        let bgColor = backgroundColor ?? .clear
        
        // Background images
        setBackgroundImage(image(with: bgColor), for: .normal, barMetrics: .default)
        setBackgroundImage(tintColorImage, for: .selected, barMetrics: .default)
        setBackgroundImage(image(with: tintColor.withAlphaComponent(0.2)), for: .highlighted, barMetrics: .default)
        setBackgroundImage(tintColorImage, for: [.selected, .highlighted], barMetrics: .default)
        
        // Text attributes
        setTitleTextAttributes([.foregroundColor: tintColor], for: .normal)
        setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        
        // Divider image
        setDividerImage(tintColorImage, forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        
        // Border
        layer.borderWidth = 1
        layer.borderColor = tintColor.cgColor
    }
    
    private func image(with color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }
}
