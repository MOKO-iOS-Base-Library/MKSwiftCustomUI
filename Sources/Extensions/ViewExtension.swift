//
//  File.swift
//  MKBaseSwiftModule
//
//  Created by aa on 2025/5/30.
//

import UIKit

import Toast

import MKBaseSwiftModule

public extension UIView {
    
    // MARK: - Gesture Recognizers
        
    /// Adds a tap gesture recognizer to the view
    /// - Parameters:
    ///   - target: The target object to receive the action message
    ///   - selector: The action selector to be called
    @objc func mk_addTapAction(target: Any, selector: Selector) {
        let tapGestureRecognizer = UITapGestureRecognizer(target: target, action: selector)
        tapGestureRecognizer.numberOfTapsRequired = 1
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    
    /// Adds a long press gesture recognizer to the view
    /// - Parameters:
    ///   - target: The target object to receive the action message
    ///   - selector: The action selector to be called
    @objc func mk_addLongPressAction(target: Any, selector: Selector) {
        let recognizer = UILongPressGestureRecognizer(target: target, action: selector)
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(recognizer)
    }
    
    // MARK: - Toast
    
    /// Shows a toast message in the center of the view
    /// - Parameter message: The message to display
    func showCentralToast(_ message: String) {
        self.makeToast(message, duration: 0.8, position: .center)
    }
    
    // MARK: - Corner Radius
    
    /// Sets the corner radius of the view
    /// - Parameter cornerRadius: The radius to use for the rounded corners
    func setCornerRadius(_ cornerRadius: CGFloat) {
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = true
    }
    
    // MARK: - Snapshot
    
    /// Creates a snapshot image of the complete view hierarchy
    /// - Returns: An optional UIImage containing the snapshot
    func mk_snapshotImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0)
        defer { UIGraphicsEndImageContext() }
        layer.render(in: UIGraphicsGetCurrentContext()!)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    /// Creates a snapshot image of the complete view hierarchy
    /// - Parameter afterUpdates: A Boolean value that indicates whether the snapshot should be rendered after recent changes have been incorporated
    /// - Returns: An optional UIImage containing the snapshot
    func mk_snapshotImage(afterUpdates: Bool) -> UIImage? {
        if !responds(to: #selector(UIView.drawHierarchy(in:afterScreenUpdates:))) {
            return mk_snapshotImage()
        }
        
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0)
        defer { UIGraphicsEndImageContext() }
        drawHierarchy(in: bounds, afterScreenUpdates: afterUpdates)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    /// Creates a snapshot PDF of the complete view hierarchy
    /// - Returns: An optional Data object containing the PDF snapshot
    func mk_snapshotPDF() -> Data? {
        var bounds = self.bounds
        let data = NSMutableData()
        
        guard let consumer = CGDataConsumer(data: data as CFMutableData),
              let context = CGContext(consumer: consumer, mediaBox: &bounds, nil) else {
            return nil
        }
        
        context.beginPDFPage(nil)
        context.translateBy(x: 0, y: bounds.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        layer.render(in: context)
        context.endPDFPage()
        context.closePDF()
        
        return data as Data
    }
    
    // MARK: - Layer Effects
    
    /// Shortcut to set the view's layer shadow properties
    /// - Parameters:
    ///   - color: The shadow color
    ///   - offset: The shadow offset
    ///   - radius: The shadow radius
    func mk_setLayerShadow(color: UIColor?, offset: CGSize, radius: CGFloat) {
        layer.shadowColor = color?.cgColor
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.shadowOpacity = 1
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
    
    // MARK: - Subviews Management
    
    /// Removes all subviews from the view
    func mk_removeAllSubviews() {
        subviews.forEach { $0.removeFromSuperview() }
    }
    
    // MARK: - View Hierarchy
    
    /// Returns the view's view controller (may be nil)
    var mk_viewController: UIViewController? {
        var responder: UIResponder? = self
        while let current = responder {
            if let viewController = current as? UIViewController {
                return viewController
            }
            responder = current.next
        }
        return nil
    }
    
    /// Returns the visible alpha on screen, taking into account superview and window
    var mk_visibleAlpha: CGFloat {
        if self is UIWindow {
            return isHidden ? 0 : alpha
        }
        guard let _ = window else { return 0 }
        
        var alpha: CGFloat = 1
        var view: UIView? = self
        while let current = view {
            if current.isHidden {
                alpha = 0
                break
            }
            alpha *= current.alpha
            view = current.superview
        }
        return alpha
    }
    
    // MARK: - Coordinate Conversion
    
    /// Converts a point from the receiver's coordinate system to that of the specified view or window
    /// - Parameters:
    ///   - point: A point specified in the local coordinate system (bounds) of the receiver
    ///   - view: The view or window into whose coordinate system point is to be converted. If nil, converts to window base coordinates
    /// - Returns: The point converted to the coordinate system of view
    func mk_convertPoint(_ point: CGPoint, toViewOrWindow view: UIView?) -> CGPoint {
        guard let view = view else {
            if let window = self as? UIWindow {
                return window.convert(point, to: nil)
            } else {
                return convert(point, to: nil)
            }
        }
        
        let from = (self as? UIWindow) ?? window
        let to = (view as? UIWindow) ?? view.window
        
        if from == nil || to == nil || from == to {
            return convert(point, to: view)
        }
        
        var convertedPoint = convert(point, to: from)
        convertedPoint = to!.convert(convertedPoint, from: from!)
        convertedPoint = view.convert(convertedPoint, from: to!)
        return convertedPoint
    }
    
    /// Converts a point from the coordinate system of a given view or window to that of the receiver
    /// - Parameters:
    ///   - point: A point specified in the local coordinate system (bounds) of view
    ///   - view: The view or window with point in its coordinate system. If nil, converts from window base coordinates
    /// - Returns: The point converted to the local coordinate system (bounds) of the receiver
    func mk_convertPoint(_ point: CGPoint, fromViewOrWindow view: UIView?) -> CGPoint {
        guard let view = view else {
            if let window = self as? UIWindow {
                return window.convert(point, from: nil)
            } else {
                return convert(point, from: nil)
            }
        }
        
        let from = (view as? UIWindow) ?? view.window
        let to = (self as? UIWindow) ?? window
        
        if from == nil || to == nil || from == to {
            return convert(point, from: view)
        }
        
        var convertedPoint = from!.convert(point, from: view)
        convertedPoint = to!.convert(convertedPoint, from: from!)
        convertedPoint = convert(convertedPoint, from: to!)
        return convertedPoint
    }
    
    /// Converts a rectangle from the receiver's coordinate system to that of another view or window
    /// - Parameters:
    ///   - rect: A rectangle specified in the local coordinate system (bounds) of the receiver
    ///   - view: The view or window that is the target of the conversion operation. If nil, converts to window base coordinates
    /// - Returns: The converted rectangle
    func mk_convertRect(_ rect: CGRect, toViewOrWindow view: UIView?) -> CGRect {
        guard let view = view else {
            if let window = self as? UIWindow {
                return window.convert(rect, to: nil)
            } else {
                return convert(rect, to: nil)
            }
        }
        
        let from = (self as? UIWindow) ?? window
        let to = (view as? UIWindow) ?? view.window
        
        if from == nil || to == nil {
            return convert(rect, to: view)
        }
        
        if from == to {
            return convert(rect, to: view)
        }
        
        var convertedRect = convert(rect, to: from!)
        convertedRect = to!.convert(convertedRect, from: from!)
        convertedRect = view.convert(convertedRect, from: to!)
        return convertedRect
    }
    
    /// Converts a rectangle from the coordinate system of another view or window to that of the receiver
    /// - Parameters:
    ///   - rect: A rectangle specified in the local coordinate system (bounds) of view
    ///   - view: The view or window with rect in its coordinate system. If nil, converts from window base coordinates
    /// - Returns: The converted rectangle
    func mk_convertRect(_ rect: CGRect, fromViewOrWindow view: UIView?) -> CGRect {
        guard let view = view else {
            if let window = self as? UIWindow {
                return window.convert(rect, from: nil)
            } else {
                return convert(rect, from: nil)
            }
        }
        
        let from = (view as? UIWindow) ?? view.window
        let to = (self as? UIWindow) ?? window
        
        if (from == nil || to == nil) || (from == to) {
            return convert(rect, from: view)
        }
        
        var convertedRect = from!.convert(rect, from: view)
        convertedRect = to!.convert(convertedRect, from: from!)
        convertedRect = convert(convertedRect, from: to!)
        return convertedRect
    }
}
