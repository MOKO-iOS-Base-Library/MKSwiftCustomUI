//
//  MKUIAdaptor.swift
//  YourProject
//
//  Created by YourName on 2024/3/27.
//

import UIKit

import MKBaseSwiftModule

@MainActor public struct MKSwiftUIAdaptor {
    // MARK: - Button Factory
    public static func createRoundedButton(
        title: String,
        target: Any? = nil,
        action: Selector? = nil
    ) -> UIButton {
        let button = UIButton(type: .custom)
        button.backgroundColor = MKColor.navBar
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = MKFont.font(15)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 6
        
        if let target = target, let action = action {
            button.addTarget(target, action: action, for: .touchUpInside)
        }
        
        return button
    }
    
    // MARK: - Label Factory
    public static func createNormalLabel(
        font:UIFont = MKFont.font(15),
        text: String = ""
    ) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = MKColor.defaultText
        label.font = font
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }
    
    // MARK: - TextField Factory
    public static func createTextField(
        text: String = "",
        placeholder: String = "",
        textType: MKSwiftTextFieldType = .normal,
        textColor: UIColor = MKColor.defaultText,
        textAlignment: NSTextAlignment = .left,
        maxLen: Int = 0
    ) -> MKSwiftTextField {
        let textField = MKSwiftTextField(textFieldType: textType)
        textField.text = text
        textField.placeholder = placeholder
        textField.textColor = textColor
        textField.font = MKFont.font(15)
        textField.textAlignment = textAlignment
        textField.maxLength = maxLen
        
        textField.layer.masksToBounds = true
        textField.layer.borderColor = MKColor.line.cgColor
        textField.layer.borderWidth = 0.5
        textField.layer.cornerRadius = 6
        
        return textField
    }
    
    // MARK: - Attributed String
    public static func createAttributedString(
        strings: [String],
        fonts: [UIFont],
        colors: [UIColor]
    ) -> NSAttributedString {
        guard !strings.isEmpty,
              strings.count == fonts.count,
              strings.count == colors.count else {
            return NSAttributedString(string: "")
        }

        let combinedString = strings.joined()
        let attributedString = NSMutableAttributedString(string: combinedString)

        var position = 0
        for (index, string) in strings.enumerated() {
            let nsString = string as NSString
            let range = NSRange(location: position, length: nsString.length)
            attributedString.addAttribute(.font, value: fonts[index], range: range)
            attributedString.addAttribute(.foregroundColor, value: colors[index], range: range)
            position += nsString.length
        }

        return attributedString
    }
    
    // MARK: - Text Size Calculation
    public static func calculateTextSize(
        attributedString: NSAttributedString,
        maxWidth: CGFloat = .greatestFiniteMagnitude,
        maxHeight: CGFloat = .greatestFiniteMagnitude
    ) -> CGSize {
        guard attributedString.length > 0 else {
            return .zero
        }
        
        let constraintSize = CGSize(width: maxWidth, height: maxHeight)
        let boundingRect = attributedString.boundingRect(
            with: constraintSize,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )
        
        return CGSize(
            width: ceil(boundingRect.width),
            height: ceil(boundingRect.height)
        )
    }
    
    public static func strHeight(forAttributedString string: NSAttributedString, viewWidth: CGFloat) -> CGFloat {
        guard string.length > 0 else {
            return 0
        }
        
        let size = string.boundingRect(
            with: CGSize(width: viewWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        ).size
        
        return ceil(size.height)
    }
}

// MARK: - Usage Examples
/*
// 1. Create a button
let button = MKUIAdaptor.createRoundedButton(
    title: "Submit",
    target: self,
    action: #selector(buttonTapped)
)

// 2. Create a label
let label = MKUIAdaptor.createLabel(
    text: "Hello World",
    textColor: .darkGray,
    fontSize: 16
)

// 3. Create attributed string
let attributedText = MKUIAdaptor.createAttributedString(
    strings: ["Hello", "World"],
    fonts: [MKUIAdaptor.font(size: 14), MKUIAdaptor.font(size: 18, weight: .bold)],
    colors: [.black, .red]
)

// 4. Calculate text size
let textSize = MKUIAdaptor.calculateTextSize(
    attributedString: attributedText,
    maxWidth: 200
)
*/
