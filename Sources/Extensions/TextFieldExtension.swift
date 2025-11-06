//
//  File.swift
//  MKBaseSwiftModule
//
//  Created by aa on 2025/5/30.
//

import UIKit

import MKBaseSwiftModule

public extension UITextField {
    
    private enum AssociatedKeys {
        @MainActor static var prohibitedMethodsListKey: UInt8 = 0
    }
    
    /// List of prohibited methods (e.g., ["cut:", "copy:", "paste:"])
    var prohibitedMethodsList: [String]? {
        get {
            objc_getAssociatedObject(self, &AssociatedKeys.prohibitedMethodsListKey) as? [String]
        }
        set {
            objc_setAssociatedObject(
                self,
                &AssociatedKeys.prohibitedMethodsListKey,
                newValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
    
    static func swizzleInit() {
        let originalSelector = #selector(UITextField.init(frame:))
        let swizzledSelector = #selector(UITextField.mk_init(frame:))
        
        guard
            let originalMethod = class_getInstanceMethod(Self.self, originalSelector),
            let swizzledMethod = class_getInstanceMethod(Self.self, swizzledSelector)
        else { return }
        
        if class_addMethod(
            Self.self,
            originalSelector,
            method_getImplementation(swizzledMethod),
            method_getTypeEncoding(swizzledMethod)
        ) {
            class_replaceMethod(
                Self.self,
                swizzledSelector,
                method_getImplementation(originalMethod),
                method_getTypeEncoding(originalMethod)
            )
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }
    
    @objc private func mk_init(frame: CGRect) -> UITextField {
        let textField = mk_init(frame: frame)
        textField.autocorrectionType = .no
        return textField
    }
    
    // MARK: - Selection Methods
    
    /// Select all text
    func mk_selectAllText() {
        guard let range = textRange(from: beginningOfDocument, to: endOfDocument) else { return }
        selectedTextRange = range
    }
    
    /// Select text in specific range
    func mk_setSelectedRange(_ range: NSRange) {
        guard
            let start = position(from: beginningOfDocument, offset: range.location),
            let end = position(from: start, offset: range.length)
        else { return }
        
        selectedTextRange = textRange(from: start, to: end)
    }
    
    // MARK: - Override
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        guard let prohibitedMethods = prohibitedMethodsList, !prohibitedMethods.isEmpty else {
            return super.canPerformAction(action, withSender: sender)
        }
        
        let actionString = NSStringFromSelector(action)
        for method in prohibitedMethods {
            let comparisonString = method.contains(":") ? method : "\(method):"
            if actionString == comparisonString {
                return false
            }
        }
        
        return super.canPerformAction(action, withSender: sender)
    }
}

// Call this in AppDelegate to activate the swizzling
extension UITextField {
    static func enableSwizzling() {
        swizzleInit()
    }
}
