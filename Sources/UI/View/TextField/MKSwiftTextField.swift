import UIKit

import MKBaseSwiftModule

// MARK: - MKSwiftTextField

public enum MKSwiftTextFieldType: Int {
    case normal
    case realNumberOnly
    case letterOnly
    case realNumberOrLetter
    case hexCharOnly
    case uuidMode
}

public class MKSwiftTextField: UITextField {
    
    public var maxLength: Int = 0
    public var textType: MKSwiftTextFieldType = .normal {
        didSet {
            currentTextType = textType
            keyboardType = getKeyboardType()
            text = ""
        }
    }
    public var textChangedBlock: ((String) -> Void)?
    
    
    
    private var currentTextType: MKSwiftTextFieldType = .normal
    private var inputLen: Int = 0
    
    public init(textFieldType: MKSwiftTextFieldType) {
        super.init(frame: .zero)
        currentTextType = textFieldType
        keyboardType = getKeyboardType()
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(textFieldDidBeginEditingNotification(_:)),
            name: UITextField.textDidBeginEditingNotification,
            object: self
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(textFieldChanged(_:)),
            name: UITextField.textDidChangeNotification,
            object: self
        )
        
        autocorrectionType = .no
        autocapitalizationType = .none
        textColor = MKColor.defaultText
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Override Methods
    
    public override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        let allowedActions: [Selector] = [
            #selector(paste(_:)),
            #selector(copy(_:)),
            #selector(cut(_:)),
            #selector(select(_:)),
            #selector(selectAll(_:))
        ]
        
        return allowedActions.contains(action) ? true : super.canPerformAction(action, withSender: sender)
    }
    
    public override func delete(_ sender: Any?) {
        // Required to prevent crash when delete is called from UIMenuController
        print(sender as Any)
    }
    
    public override func drawPlaceholder(in rect: CGRect) {
        guard let placeholder = placeholder, let font = font else { return }
        
        let placeholderSize = (placeholder as NSString).size(withAttributes: [.font: font])
        let drawRect = CGRect(
            x: 0,
            y: (rect.size.height - placeholderSize.height) / 2,
            width: rect.size.width,
            height: rect.size.height
        )
        
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: MKColor.rgb(220, 220, 220),
            .font: font
        ]
        
        placeholder.draw(in: drawRect, withAttributes: attributes)
    }
    
    // MARK: - Notification Methods
    
    @objc private func textFieldDidBeginEditingNotification(_ notification: Notification) {
        // Handle begin editing if needed
    }
    
    @objc private func textFieldChanged(_ notification: Notification) {
        guard let text = self.text else {
            self.text = ""
            textChangedBlock?("")
            return
        }
        
        if !text.isEmpty {
            if maxLength > 0 && text.count > maxLength && currentTextType != .uuidMode {
                self.text = String(text.prefix(maxLength))
                textChangedBlock?(self.text ?? "")
                return
            }
            
            let inputString = String(text.suffix(1))
            let legal = validation(inputString)
            self.text = legal ? text : String(text.dropLast())
            
            if currentTextType != .uuidMode {
                textChangedBlock?(self.text ?? "")
                return
            }
            
            self.text = self.text?.uppercased()
            
            // UUID mode specific handling
            if let currentText = self.text, currentText.count > inputLen {
                if currentText.count == 9 || currentText.count == 14 || currentText.count == 19 || currentText.count == 24 {
                    var mutableString = currentText
                    mutableString.insert("-", at: mutableString.index(mutableString.startIndex, offsetBy: currentText.count - 1))
                    self.text = mutableString
                    textChangedBlock?(self.text ?? "")
                }
                
                if let currentText = self.text, currentText.count >= 36 {
                    self.text = String(currentText.prefix(36))
                    textChangedBlock?(self.text ?? "")
                }
                
                inputLen = self.text?.count ?? 0
                textChangedBlock?(self.text ?? "")
            } else if let currentText = self.text, currentText.count < inputLen {
                if currentText.count == 9 || currentText.count == 14 || currentText.count == 19 || currentText.count == 24 {
                    self.text = String(currentText.dropLast())
                    textChangedBlock?(self.text ?? "")
                }
                inputLen = self.text?.count ?? 0
                textChangedBlock?(self.text ?? "")
            }
        } else {
            self.text = ""
            textChangedBlock?("")
        }
    }
    
    // MARK: - Private Methods
    
    private func getKeyboardType() -> UIKeyboardType {
        return currentTextType == .realNumberOnly ? .numberPad : .asciiCapable
    }
    
    private func validation(_ inputString: String) -> Bool {
        guard !inputString.isEmpty else { return false }
        
        switch currentTextType {
        case .normal:
            return true
        case .realNumberOnly:
            return inputString.range(of: "^[0-9]*$", options: .regularExpression) != nil
        case .letterOnly:
            return inputString.range(of: "^[a-zA-Z]*$", options: .regularExpression) != nil
        case .realNumberOrLetter:
            return inputString.range(of: "^[a-zA-Z0-9]*$", options: .regularExpression) != nil
        case .hexCharOnly, .uuidMode:
            return inputString.range(of: "^[a-fA-F0-9]*$", options: .regularExpression) != nil
        }
    }
}
