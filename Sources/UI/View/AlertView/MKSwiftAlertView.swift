//
//  MKSwiftAlertView.swift
//  MKBaseSwiftModule
//
//  Created by aa on 2024/3/13.
//

import UIKit

import MKBaseSwiftModule

// MKSwiftAlertViewAction.swift
public class MKSwiftAlertViewAction {
    public private(set) var title: String  // 外部可读，不可写
    public private(set) var handler: (() -> Void)
    
    public init(title: String, handler: @escaping () -> Void) {
        self.title = title
        self.handler = handler
    }
}

public class MKSwiftAlertViewTextField {
    // MARK: - Public Properties (Readonly)
    public private(set) var textValue: String
    public private(set) var placeholder: String
    public private(set) var textFieldType: MKSwiftTextFieldType
    public private(set) var maxLength: Int
    public private(set) var handler: ((String) -> Void)?
    
    public init(textValue: String = "",
                placeholder: String = "",
                textFieldType: MKSwiftTextFieldType = .normal,
                maxLength: Int = 0,
                handler: ((String) -> Void)? = nil) {
               self.textValue = textValue
               self.placeholder = placeholder
               self.textFieldType = textFieldType
               self.maxLength = maxLength
               self.handler = handler
           }
}

public class MKSwiftAlertView: UIView {
    
    // MARK: - Public Types
    public enum TextFieldType {
        case normal
        case uuidMode
    }
    
    // MARK: - Constants
    private struct Constants {
        static let buttonHeight: CGFloat = 44
        static let textFieldHeight: CGFloat = 40
        static let lineHeight: CGFloat = 0.5
        static let cornerRadius: CGFloat = 8
        static let centerViewOffsetX: CGFloat = 40
        static let msgLabelOffsetX: CGFloat = 20
        static let titleLabelOffsetY: CGFloat = 20
    }
    
    // MARK: - Data Stores
    private var actionList: [MKSwiftAlertViewAction] = []
    private var buttonList: [UIButton] = []
    private var textModelList: [MKSwiftAlertViewTextField] = []
    private var textFieldList: [UITextField] = []
    private var asciiStringList: [String] = []
    private var alertTitle: String = ""
    private var alertMessage: String = ""
    
    // MARK: - Initialization
    public override init(frame: CGRect) {
        super.init(frame: UIScreen.main.bounds)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = UIColor(white: 0, alpha: 0.3)
        addSubview(centerView)
    }
    
    deinit {
        print("MKSwiftAlertView销毁")
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Public Methods
    public func addAction(_ action: MKSwiftAlertViewAction) {
        guard actionList.count < 2 else { return }
        actionList.append(action)
    }
    
    public func addTextField(_ textModel: MKSwiftAlertViewTextField) {
        guard textModelList.count < 2 else { return }
        textModelList.append(textModel)
    }
    
    public func showAlert(title: String = "", message: String = "", notificationName: String? = nil) {
        guard !actionList.isEmpty, actionList.count <= 2 else { return }
        alertTitle = title
        alertMessage = message
        if let window = MKApp.window {
            window.addSubview(self)
        }
        
        if let notificationName = notificationName {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(dismiss),
                name: NSNotification.Name(rawValue: notificationName),
                object: nil
            )
        }
        
        setupUI()
    }
    
    @objc public func dismiss() {
        removeFromSuperview()
    }
    
    @objc private func buttonPressed(_ sender: UIButton) {
        guard sender.tag < actionList.count else { return }
        let action = actionList[sender.tag]
        action.handler()
        dismiss()
    }
    
    @objc private func textFieldValueChanged(_ sender: UITextField) {
        guard sender.tag < textModelList.count else { return }
        
        let textModel = textModelList[sender.tag]
        guard let inputValue = sender.text else { return }
        
        if inputValue.isEmpty {
            sender.text = ""
            asciiStringList[sender.tag] = ""
            textModel.handler?("")
            return
        }
        
        let strLen = inputValue.count
        let dataLen = inputValue.data(using: .utf8)?.count ?? 0
        
        if dataLen == strLen {
            // ASCII characters
            asciiStringList[sender.tag] = inputValue
        }
        
        let currentStr = asciiStringList[sender.tag]
        
        if textModel.textFieldType != .uuidMode && textModel.maxLength > 0 && currentStr.count > textModel.maxLength {
            let newText = String(currentStr.prefix(textModel.maxLength))
            sender.text = newText
            asciiStringList[sender.tag] = newText
            textModel.handler?(newText)
        } else {
            sender.text = currentStr
            textModel.handler?(currentStr)
        }
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        centerView.subviews.forEach { $0.removeFromSuperview() }
        textFieldView.subviews.forEach { $0.removeFromSuperview() }
        
        titleLabel.text = alertTitle
        centerView.addSubview(titleLabel)
        
        messageLabel.text = alertMessage
        centerView.addSubview(messageLabel)
        
        centerView.addSubview(textFieldView)
        centerView.addSubview(horizontalLine)
        
        buttonList.removeAll()
        textFieldList.removeAll()
        asciiStringList.removeAll()
        
        // Setup buttons
        for (index, action) in actionList.enumerated() {
            let button = createButton(title: action.title, index: index)
            centerView.addSubview(button)
            buttonList.append(button)
        }
        
        // Setup text fields
        for (index, textModel) in textModelList.enumerated() {
            let textField = createTextField(model: textModel, index: index)
            textFieldView.addSubview(textField)
            textFieldList.append(textField)
            asciiStringList.append(textModel.textValue)
        }
        
        setupConstraints()
        
        if let firstTextField = textFieldList.first {
            firstTextField.becomeFirstResponder()
        }
    }
    
    private func createButton(title: String, index: Int) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitleColor(UIColor.blue, for: .normal) // COLOR_BLUE_MARCROS
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        button.tag = index
        return button
    }
    
    private func createTextField(model: MKSwiftAlertViewTextField, index: Int) -> UITextField {
        let textField = UITextField()
        textField.textColor = .black // DEFAULT_TEXT_COLOR
        textField.font = UIFont.systemFont(ofSize: 13)
        textField.textAlignment = .left
        textField.placeholder = model.placeholder
        textField.text = model.textValue
        textField.tag = index
        textField.addTarget(self, action: #selector(textFieldValueChanged(_:)), for: .editingChanged)
        return textField
    }
    
    private func setupConstraints() {
        let messageHeight = calculateMessageHeight()
        let titleHeight = calculateTitleHeight()
        let textViewHeight = CGFloat(textFieldList.count) * Constants.textFieldHeight
        
        let centerViewHeight = (
            Constants.titleLabelOffsetY +
            messageHeight +
            titleHeight +
            textViewHeight +
            Constants.lineHeight +
            Constants.buttonHeight +
            20
        )
        
        centerView.snp.remakeConstraints { make in
            make.left.equalTo(Constants.centerViewOffsetX)
            make.right.equalTo(-Constants.centerViewOffsetX)
            
            if textFieldList.isEmpty {
                make.centerY.equalToSuperview()
            } else {
                make.centerY.equalToSuperview().offset(-90)
            }
            
            make.height.equalTo(centerViewHeight)
        }
        
        // Title label constraints
        titleLabel.snp.remakeConstraints { make in
            make.left.equalTo(5)
            make.right.equalTo(-5)
            make.top.equalTo(Constants.titleLabelOffsetY)
            
            if alertTitle.isEmpty {
                make.height.equalTo(0)
            } else {
                make.height.equalTo(titleLabel.font.lineHeight)
            }
        }
        
        // Message label constraints
        messageLabel.snp.remakeConstraints { make in
            make.left.equalTo(Constants.msgLabelOffsetX)
            make.right.equalTo(-Constants.msgLabelOffsetX)
            
            if alertTitle.isEmpty {
                make.top.equalTo(Constants.titleLabelOffsetY)
            } else {
                make.top.equalTo(titleLabel.snp.bottom).offset(10)
            }
            
            make.height.equalTo(messageHeight)
        }
        
        // Text field view constraints
        textFieldView.snp.remakeConstraints { make in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.top.equalTo(messageLabel.snp.bottom).offset(10)
            make.height.equalTo(textViewHeight)
        }
        
        // Text fields constraints
        for (index, textField) in textFieldList.enumerated() {
            if textFieldList.count == 1 {
                textField.snp.remakeConstraints { make in
                    make.edges.equalToSuperview()
                }
            } else if index == 0 {
                textField.snp.remakeConstraints { make in
                    make.left.right.top.equalToSuperview()
                    make.height.equalTo(Constants.textFieldHeight)
                }
                
                let lineView = UIView()
                lineView.backgroundColor = UIColor(red: 53/255, green: 53/255, blue: 53/255, alpha: 1)
                textFieldView.addSubview(lineView)
                
                lineView.snp.remakeConstraints { make in
                    make.left.right.equalToSuperview()
                    make.top.equalTo(textField.snp.bottom)
                    make.height.equalTo(Constants.lineHeight)
                }
            } else if index == 1 {
                textField.snp.remakeConstraints { make in
                    make.left.right.equalToSuperview()
                    make.top.equalTo(textFieldView.subviews[index - 1].snp.bottom)
                    make.height.equalTo(Constants.textFieldHeight)
                }
            }
        }
        
        // Horizontal line constraints
        horizontalLine.snp.remakeConstraints { make in
            make.left.right.equalToSuperview()
            
            if textFieldList.isEmpty {
                make.top.equalTo(messageLabel.snp.bottom).offset(20)
            } else {
                make.top.equalTo(textFieldView.snp.bottom).offset(10)
            }
            
            make.height.equalTo(Constants.lineHeight)
        }
        
        // Buttons constraints
        if buttonList.count == 1 {
            buttonList[0].snp.remakeConstraints { make in
                make.left.right.equalToSuperview()
                make.top.equalTo(horizontalLine.snp.bottom)
                make.bottom.equalToSuperview()
            }
        } else if buttonList.count == 2 {
            let verticalLine = UIView()
            verticalLine.backgroundColor = UIColor(red: 53/255, green: 53/255, blue: 53/255, alpha: 1)
            centerView.addSubview(verticalLine)
            
            verticalLine.snp.remakeConstraints { make in
                make.centerX.equalToSuperview()
                make.width.equalTo(Constants.lineHeight)
                make.top.equalTo(horizontalLine.snp.bottom)
                make.bottom.equalToSuperview()
            }
            
            buttonList[0].snp.remakeConstraints { make in
                make.left.equalToSuperview()
                make.right.equalTo(verticalLine.snp.left)
                make.top.equalTo(horizontalLine.snp.bottom)
                make.bottom.equalToSuperview()
            }
            
            buttonList[1].snp.remakeConstraints { make in
                make.left.equalTo(verticalLine.snp.right)
                make.right.equalToSuperview()
                make.top.equalTo(horizontalLine.snp.bottom)
                make.bottom.equalToSuperview()
            }
        }
    }
    
    private func calculateTitleHeight() -> CGFloat {
        guard !alertTitle.isEmpty else { return 0 }
        return titleLabel.font.lineHeight + 10
    }
    
    private func calculateMessageHeight() -> CGFloat {
        guard !alertMessage.isEmpty else { return 0 }
        
        let maxWidth = UIScreen.main.bounds.width - 2 * (Constants.centerViewOffsetX + Constants.msgLabelOffsetX)
        let size = NSString(string: alertMessage).boundingRect(
            with: CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [NSAttributedString.Key.font: messageLabel.font!],
            context: nil
        )
        
        return size.height
    }
    
    // MARK: - UI Components
    private lazy var centerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 234/255, green: 234/255, blue: 234/255, alpha: 1)
        view.layer.masksToBounds = true
        view.layer.cornerRadius = Constants.cornerRadius
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .black // DEFAULT_TEXT_COLOR
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .black // DEFAULT_TEXT_COLOR
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var textFieldView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.masksToBounds = true
        view.layer.borderWidth = Constants.lineHeight
        view.layer.borderColor = UIColor(red: 53/255, green: 53/255, blue: 53/255, alpha: 1).cgColor
        view.layer.cornerRadius = 6
        return view
    }()
    
    private lazy var horizontalLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 53/255, green: 53/255, blue: 53/255, alpha: 1)
        return view
    }()
}
