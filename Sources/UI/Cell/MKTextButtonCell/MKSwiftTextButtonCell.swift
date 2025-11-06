//
//  MKSwiftTextButtonCell.swift
//  MKBaseSwiftModule
//
//  Created by aa on 2024/4/10.
//

import UIKit
import SnapKit

import MKBaseSwiftModule

// MARK: - Model

private let offsetX: CGFloat = 15
private let selectButtonWidth: CGFloat = 130
private let selectButtonHeight: CGFloat = 30

public class MKSwiftTextButtonCellModel {
    // MARK: Cell Top Configuration
    public var index: Int = 0
    public var contentColor: UIColor = .white
    
    // MARK: Left Label Configuration
    public var msg: String = ""
    public var msgColor: UIColor = MKColor.defaultText
    public var msgFont: UIFont = MKFont.font(15)
    
    // MARK: Right Button Configuration
    public var buttonEnable: Bool = true
    public var dataList: [String] = []
    public var dataListIndex: Int = 0
    public var buttonBackColor: UIColor = MKColor.fromHex(0x2F84D0)
    public var buttonTitleColor: UIColor = .white
    public var buttonLabelFont: UIFont = MKFont.font(15)
    
    // MARK: Bottom Label Configuration
    public var noteMsg: String = ""
    public var noteMsgColor: UIColor = MKColor.defaultText
    public var noteMsgFont: UIFont = MKFont.font(12)
    
    public init() {}
    
    public func cellHeightWithContentWidth(_ width: CGFloat) -> CGFloat {
        let msgFont = self.msgFont
        let msgWidth = width - 3 * offsetX - selectButtonWidth  // Changed offset_X to offsetX
        let msgSize = msg.size(
            withFont: msgFont,
            maxSize: CGSize(width: msgWidth, height: .greatestFiniteMagnitude)
        )
        
        if noteMsg.isEmpty {  // Changed the optional check since noteMsg is non-optional
            // No bottom note content
            return max(msgSize.height + 2 * offsetX, 50.0)  // Changed offset_X to offsetX
        }
        
        // Has bottom note
        let noteFont = self.noteMsgFont
        let noteSize = noteMsg.size(
            withFont: noteFont,
            maxSize: CGSize(width: width - 2 * offsetX, height: .greatestFiniteMagnitude)  // Changed offset_X to offsetX
        )
        
        return max(msgSize.height + 2 * offsetX, 50.0) + noteSize.height + 10.0  // Changed offset_X to offsetX
    }
}

// MARK: - Protocol

public protocol MKSwiftTextButtonCellDelegate: AnyObject {
    func MKSwiftTextButtonCellSelected(index: Int, dataListIndex: Int, value: String)
}

// MARK: - Cell

public class MKSwiftTextButtonCell: MKSwiftBaseCell {
    public var dataModel: MKSwiftTextButtonCellModel? {
        didSet {
            updateContent()
        }
    }
    
    public weak var delegate: MKSwiftTextButtonCellDelegate?
    
    // MARK: - Class Methods
    public class func initCellWithTableView(_ tableView: UITableView) -> MKSwiftTextButtonCell {
        let identifier = "MKSwiftTextButtonCellIdenty"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? MKSwiftTextButtonCell
        if cell == nil {
            cell = MKSwiftTextButtonCell(style: .default, reuseIdentifier: identifier)
        }
        return cell!
    }
    
    private let offsetX: CGFloat = 15
    private let selectButtonWidth: CGFloat = 130
    private let selectButtonHeight: CGFloat = 30
    
    // MARK: Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(msgLabel)
        contentView.addSubview(selectedButton)
        contentView.addSubview(noteLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        
        selectedButton.snp.remakeConstraints { make in
            make.right.equalTo(-offsetX)
            make.width.equalTo(selectButtonWidth)
            make.centerY.equalTo(msgLabel)
            make.height.equalTo(selectButtonHeight)
        }
        
        let noteSize = noteSize()
        noteLabel.snp.remakeConstraints { make in
            make.left.equalTo(offsetX)
            make.right.equalTo(-offsetX)
            make.bottom.equalTo(-offsetX)
            make.height.equalTo(noteSize.height)
        }
    }
    
    // MARK: Actions
    @objc private func selectedButtonPressed() {
        NotificationCenter.default.post(name: Notification.Name("MKTextFieldNeedHiddenKeyboard"), object: nil)
        
        guard let dataModel = dataModel, !dataModel.dataList.isEmpty else { return }
        
        var selectedRow = 0
        if let currentTitle = selectedButton.titleLabel?.text,
           let index = dataModel.dataList.firstIndex(of: currentTitle) {
            selectedRow = index
        }
        
        let pickerView = MKSwiftPickerView()
        pickerView.showPickView(
            with: dataModel.dataList,
            selectedRow: selectedRow
        ) { [weak self] currentRow in
            guard let self = self else { return }
            self.selectedButton.setTitle(dataModel.dataList[currentRow], for: .normal)
            self.delegate?.MKSwiftTextButtonCellSelected(
                index: dataModel.index,
                dataListIndex: currentRow,
                value: dataModel.dataList[currentRow]
            )
        }
    }
    
    // MARK: Private Methods
    
    private func updateContent() {
        guard let dataModel = dataModel else { return }
        
        contentView.backgroundColor = dataModel.contentColor
        msgLabel.text = dataModel.msg
        msgLabel.font = dataModel.msgFont
        msgLabel.textColor = dataModel.msgColor
        selectedButton.isEnabled = dataModel.buttonEnable
        
        if dataModel.dataList.indices.contains(dataModel.dataListIndex) {
            selectedButton.setTitle(dataModel.dataList[dataModel.dataListIndex], for: .normal)
        }
        
        selectedButton.titleLabel?.font = dataModel.buttonLabelFont
        selectedButton.backgroundColor = dataModel.buttonBackColor
        selectedButton.setTitleColor(dataModel.buttonTitleColor, for: .normal)
        
        noteLabel.text = dataModel.noteMsg
        noteLabel.font = dataModel.noteMsgFont
        noteLabel.textColor = dataModel.noteMsgColor
        
        setNeedsLayout()
    }
    
    private func msgSize() -> CGSize {
        guard let dataModel = dataModel, !dataModel.msg.isEmpty else {
            return .zero
        }
        
        let maxMsgWidth = contentView.frame.width - 3 * offsetX - selectButtonWidth
        return dataModel.msg.size(withFont: dataModel.msgFont, maxSize: CGSize(width: maxMsgWidth, height: .greatestFiniteMagnitude))
    }
    
    private func noteSize() -> CGSize {
        guard let dataModel = dataModel, !dataModel.noteMsg.isEmpty else {
            return .zero
        }
        
        let width = contentView.frame.width - 2 * offsetX
        return dataModel.noteMsg.size(withFont: dataModel.noteMsgFont, maxSize: CGSize(width: width, height: .greatestFiniteMagnitude))
    }
    
    // MARK: UI Components
    private lazy var msgLabel: UILabel = {
        let label = MKSwiftUIAdaptor.createNormalLabel()
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var selectedButton: UIButton = {
        let button = MKSwiftUIAdaptor.createRoundedButton(title: "",
                                                          target: self,
                                                          action: #selector(selectedButtonPressed))
        return button
    }()
    
    private lazy var noteLabel: UILabel = {
        let label = MKSwiftUIAdaptor.createNormalLabel(font: MKFont.font(12))
        label.numberOfLines = 0
        return label
    }()
}
