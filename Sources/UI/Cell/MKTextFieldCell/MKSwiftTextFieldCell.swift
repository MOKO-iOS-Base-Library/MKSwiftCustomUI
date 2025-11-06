//
//  MKSwiftTextFieldCell.swift
//  MKBaseSwiftModule
//
//  Created by aa on 2024/3/27.
//

import UIKit
import SnapKit

import MKBaseSwiftModule

// MARK: - Enums

public enum MKSwiftTextFieldCellType {
    case normal
    case topLine
}

// MARK: - Model

public class MKSwiftTextFieldCellModel {
    // MARK: Cell Top Configuration
    public var index: Int = 0
    public var contentColor: UIColor = .white
    
    // MARK: Left Label Configuration
    public var msg: String = ""
    public var msgColor: UIColor = MKColor.defaultText
    public var msgFont: UIFont = MKFont.font(15)
    
    // MARK: Right Label Configuration
    public var unit: String = ""
    public var unitColor: UIColor = MKColor.defaultText
    public var unitFont: UIFont = MKFont.font(13)
    
    // MARK: TextField Configuration
    public var textEnable: Bool = true
    public var cellType: MKSwiftTextFieldCellType = .normal
    public var textFieldValue: String = ""
    public var textPlaceholder: String = ""
    public var textAlignment: NSTextAlignment = .left
    public var textFieldTextColor: UIColor = MKColor.defaultText
    public var textFieldTextFont: UIFont = MKFont.font(15)
    public var textFieldType: MKSwiftTextFieldType = .normal
    public var maxLength: Int = 0
    public var clearButtonMode: UITextField.ViewMode = .never
    public var borderColor: UIColor = MKColor.fromHex(0xDEDEDE)
    
    // MARK: Bottom Label Configuration
    public var noteMsg: String = ""
    public var noteMsgColor: UIColor = MKColor.defaultText
    public var noteMsgFont: UIFont = MKFont.font(12)
    
    public init() {}
    
    private let offsetX: CGFloat = 15
    
    public func cellHeightWithContentWidth(_ width: CGFloat) -> CGFloat {
        let msgWidth = (width - 3 * offsetX) / 2
        let msgSize = msg.size(withFont: msgFont, maxSize: CGSize(width: msgWidth, height: .greatestFiniteMagnitude))
        
        guard !noteMsg.isEmpty else {
            return max(msgSize.height + 2 * offsetX, 50)
        }
        
        let noteSize = noteMsg.size(withFont: noteMsgFont, maxSize: CGSize(width: width - 2 * offsetX, height: .greatestFiniteMagnitude))
        return max(msgSize.height + 2 * offsetX, 50) + noteSize.height + 10
    }
}

// MARK: - Protocol

public protocol MKSwiftTextFieldCellDelegate: AnyObject {
    func mkDeviceTextCellValueChanged(_ index: Int, textValue: String)
}

// MARK: - Cell

public class MKSwiftTextFieldCell: MKSwiftBaseCell {
    
    // MARK: Properties
    public var dataModel: MKSwiftTextFieldCellModel? {
        didSet {
            updateContent()
        }
    }
    
    public weak var delegate: MKSwiftTextFieldCellDelegate?
    
    // MARK: - Class Methods
    public class func initCellWithTableView(_ tableView: UITableView) -> MKSwiftTextFieldCell {
        let identifier = "MKSwiftTextFieldCellIdenty"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? MKSwiftTextFieldCell
        if cell == nil {
            cell = MKSwiftTextFieldCell(style: .default, reuseIdentifier: identifier)
        }
        return cell!
    }
    
    private let offsetX: CGFloat = 15
    private let textBorderViewHeight: CGFloat = 35
    private let unitLabelWidth: CGFloat = 70
    
    // MARK: Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(msgLabel)
        contentView.addSubview(unitLabel)
        contentView.addSubview(noteLabel)
        setupNotifications()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        let hasNote = !dataModel!.noteMsg.isEmpty
        let msgSize = msgSize()
        
        msgLabel.snp.remakeConstraints { make in
            make.left.equalTo(offsetX)
            make.width.equalTo(msgSize.width)
            if hasNote {
                make.top.equalTo(offsetX)
            } else {
                make.centerY.equalToSuperview()
            }
            make.height.equalTo(msgSize.height)
        }
        
        textField.snp.remakeConstraints { make in
            make.left.equalTo(5)
            make.right.equalTo(-5)
            make.top.equalTo(2)
            make.bottom.equalTo(0)
        }
        
        unitLabel.snp.remakeConstraints { make in
            make.right.equalTo(-offsetX)
            make.width.equalTo(unitLabelWidth)
            make.centerY.equalTo(msgLabel)
            make.height.equalToSuperview()
        }
        
        let noteSize = noteSize()
        noteLabel.snp.remakeConstraints { make in
            make.left.equalTo(offsetX)
            make.right.equalTo(-offsetX)
            make.bottom.equalTo(-offsetX)
            make.height.equalTo(noteSize.height)
        }
        
        textBorderView.snp.remakeConstraints { make in
            make.left.equalTo(msgLabel.snp.right).offset(offsetX)
            if !dataModel!.unit.isEmpty {
                make.right.equalTo(unitLabel.snp.left).offset(-5)
            } else {
                make.right.equalTo(-offsetX)
            }
            make.centerY.equalTo(msgLabel)
            make.height.equalTo(textBorderViewHeight)
        }
    }
    
    // MARK: Actions
    private func textFieldValueChanged(_ textValue: String) {
        guard let dataModel = dataModel else { return }
        delegate?.mkDeviceTextCellValueChanged(dataModel.index, textValue: textValue)
    }
    
    @objc private func needHiddenKeyboard() {
        textField.resignFirstResponder()
    }
    
    // MARK: Private Methods
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(needHiddenKeyboard),
            name: NSNotification.Name("MKTextFieldNeedHiddenKeyboard"),
            object: nil
        )
    }
    
    private func updateContent() {
        guard let dataModel = dataModel else { return }
        
        contentView.backgroundColor = dataModel.contentColor
        unitLabel.text = dataModel.unit
        unitLabel.font = dataModel.unitFont
        unitLabel.textColor = dataModel.unitColor
        unitLabel.isHidden = dataModel.unit.isEmpty
        msgLabel.text = dataModel.msg
        msgLabel.font = dataModel.msgFont
        msgLabel.textColor = dataModel.msgColor
        noteLabel.text = dataModel.noteMsg
        noteLabel.font = dataModel.noteMsgFont
        noteLabel.textColor = dataModel.noteMsgColor
        
        setupTextField()
    }
    
    private func setupTextField() {
        guard let dataModel = dataModel else { return }
        
        textField.removeFromSuperview()
        textBorderView.removeFromSuperview()
        
        textField.textType = dataModel.textFieldType
        textField.maxLength = dataModel.maxLength
        textField.placeholder = dataModel.textPlaceholder
        textField.text = dataModel.textFieldValue
        textField.font = dataModel.textFieldTextFont
        textField.textColor = dataModel.textFieldTextColor
        textField.textAlignment = dataModel.textAlignment
        textField.clearButtonMode = dataModel.clearButtonMode
        textField.isEnabled = dataModel.textEnable
        
        textBorderView.layer.cornerRadius = dataModel.cellType == .normal ? 6 : 0
        if dataModel.cellType == .normal {
            textBorderView.layer.borderColor = dataModel.borderColor.cgColor
        }
        
        if dataModel.cellType == .topLine {
            let topLine = UIView()
            topLine.backgroundColor = MKColor.fromHex(0xDEDEDE)
            textBorderView.addSubview(topLine)
            topLine.snp.makeConstraints { make in
                make.left.right.top.equalToSuperview()
                make.height.equalTo(2)
            }
        }
        
        contentView.addSubview(textBorderView)
        textBorderView.addSubview(textField)
        
        setNeedsLayout()
    }
    
    private func msgSize() -> CGSize {
        guard let dataModel = dataModel, !dataModel.msg.isEmpty else {
            return .zero
        }
        
        let maxMsgWidth = (contentView.frame.width - 3 * offsetX) / 2
        return dataModel.msg.size(withFont: dataModel.msgFont, maxSize: CGSize(width: maxMsgWidth, height: .greatestFiniteMagnitude))
    }
    
    private func noteSize() -> CGSize {
        guard let dataModel = dataModel, !dataModel.noteMsg.isEmpty else {
            return .zero
        }
        
        let width = contentView.frame.width - 30
        return dataModel.noteMsg.size(withFont: dataModel.noteMsgFont, maxSize: CGSize(width: width, height: .greatestFiniteMagnitude))
    }
    
    // MARK: UI Components
    private lazy var msgLabel: UILabel = {
        let label = UILabel()
        label.textColor = MKColor.defaultText
        label.textAlignment = .left
        label.font = MKFont.font(15)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var textBorderView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.masksToBounds = true
        view.layer.borderWidth = 0.5
        view.layer.borderColor = MKColor.fromHex(0xDEDEDE).cgColor
        return view
    }()
    
    private lazy var textField: MKSwiftTextField = {
        let field = MKSwiftTextField(textFieldType: .normal)
        field.borderStyle = .none
        field.textChangedBlock = { [weak self] text in
            self?.textFieldValueChanged(text)
        }
        return field
    }()
    
    private lazy var unitLabel: UILabel = {
        let label = UILabel()
        label.textColor = MKColor.defaultText
        label.textAlignment = .left
        label.font = MKFont.font(13)
        return label
    }()
    
    private lazy var noteLabel: UILabel = {
        let label = UILabel()
        label.textColor = MKColor.defaultText
        label.font = MKFont.font(12)
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
}
