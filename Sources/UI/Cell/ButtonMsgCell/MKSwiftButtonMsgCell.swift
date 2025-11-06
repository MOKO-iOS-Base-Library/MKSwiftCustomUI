//
//  File.swift
//  MKBaseSwiftModule
//
//  Created by aa on 2025/6/4.
//

import UIKit
import SnapKit

import MKBaseSwiftModule

// MARK: - Cell Model
public class MKSwiftButtonMsgCellModel {
    // Cell top configuration
    public var index: Int = 0
    public var contentColor: UIColor = .white
    
    // Left label configuration
    public var msg: String = ""
    public var msgColor: UIColor = MKColor.defaultText
    public var msgFont: UIFont = MKFont.font(15)
    
    // Right button configuration
    public var buttonEnable: Bool = true
    public var buttonTitle: String = ""
    public var buttonBackColor: UIColor = MKColor.navBar
    public var buttonTitleColor: UIColor = .white
    public var buttonLabelFont: UIFont = MKFont.font(15)
    
    // Bottom label configuration
    public var noteMsg: String = ""
    public var noteMsgColor: UIColor = MKColor.defaultText
    public var noteMsgFont: UIFont = MKFont.font(12)
    
    public init() {}
    
    public func cellHeightWithContentWidth(_ width: CGFloat) -> CGFloat {
        let maxMsgWidth = width - 3 * 15 - 130 // offset_X = 15, selectButtonWidth = 130
        let msgSize = msg.size(withFont: msgFont, maxSize: CGSize(width: maxMsgWidth, height: .greatestFiniteMagnitude))
        
        guard !noteMsg.isEmpty else {
            return max(msgSize.height + 2 * 15, 50) // No note content
        }
        
        let noteSize = noteMsg.size(withFont: noteMsgFont, maxSize: CGSize(width: (width - 2 * 15), height: .greatestFiniteMagnitude))
        
        return max(msgSize.height + 2 * 15, 50) + noteSize.height + 10
    }
}

// MARK: - Cell Delegate
public protocol MKSwiftButtonMsgCellDelegate: AnyObject {
    func mk_buttonMsgCellButtonPressed(_ index: Int)
}

// MARK: - Cell Implementation
public class MKSwiftButtonMsgCell: MKSwiftBaseCell {
    // MARK: - Properties
    public var dataModel: MKSwiftButtonMsgCellModel? {
        didSet {
            updateContent()
        }
    }
    
    public weak var delegate: MKSwiftButtonMsgCellDelegate?
    
    // MARK: - Class Methods
    public class func initCellWithTableView(_ tableView: UITableView) -> MKSwiftButtonMsgCell {
        let identifier = "MKSwiftButtonMsgCellIdenty"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? MKSwiftButtonMsgCell
        if cell == nil {
            cell = MKSwiftButtonMsgCell(style: .default, reuseIdentifier: identifier)
        }
        return cell!
    }
    
    // MARK: - Constants
    private let offset_X: CGFloat = 15
    private let selectButtonWidth: CGFloat = 130
    private let selectButtonHeight: CGFloat = 30
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(msgLabel)
        contentView.addSubview(selectedButton)
        contentView.addSubview(noteLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        let hasNote = !(noteLabel.text?.isEmpty ?? true)
        let msgSize = self.msgSize()
        
        msgLabel.snp.remakeConstraints { make in
            make.left.equalToSuperview().offset(offset_X)
            make.width.equalTo(msgSize.width)
            
            if hasNote {
                make.top.equalToSuperview().offset(offset_X)
            } else {
                make.centerY.equalToSuperview()
            }
            
            make.height.equalTo(msgSize.height)
        }
        
        selectedButton.snp.remakeConstraints { make in
            make.right.equalToSuperview().offset(-offset_X)
            make.width.equalTo(selectButtonWidth)
            make.centerY.equalTo(msgLabel.snp.centerY)
            make.height.equalTo(selectButtonHeight)
        }
        
        let noteSize = self.noteSize()
        noteLabel.snp.remakeConstraints { make in
            make.left.equalToSuperview().offset(offset_X)
            make.right.equalToSuperview().offset(-offset_X)
            make.bottom.equalToSuperview().offset(-offset_X)
            make.height.equalTo(noteSize.height)
        }
    }
    
    // MARK: - Actions
    @objc private func selectedButtonPressed() {
        delegate?.mk_buttonMsgCellButtonPressed(dataModel?.index ?? 0)
    }
    
    // MARK: - Helper Methods
    private func msgSize() -> CGSize {
        guard let text = msgLabel.text, !text.isEmpty else {
            return .zero
        }
        
        let maxMsgWidth = contentView.frame.width - 3 * offset_X - selectButtonWidth
        let size = text.size(withFont: msgLabel.font, maxSize: CGSize(width: maxMsgWidth, height: .greatestFiniteMagnitude))
        
        return CGSize(width: maxMsgWidth, height: size.height)
    }
    
    private func noteSize() -> CGSize {
        guard let text = noteLabel.text, !text.isEmpty else {
            return .zero
        }
        
        let width = contentView.frame.width - 2 * offset_X
        let size = text.size(withFont: noteLabel.font, maxSize: CGSize(width: width, height: .greatestFiniteMagnitude))
        
        return CGSize(width: width, height: size.height)
    }
    
    // MARK: - UI Setup
    private func updateContent() {
        guard let dataModel = dataModel else { return }
        
        contentView.backgroundColor = dataModel.contentColor
        msgLabel.text = dataModel.msg
        msgLabel.font = dataModel.msgFont
        msgLabel.textColor = dataModel.msgColor
        
        selectedButton.isEnabled = dataModel.buttonEnable
        selectedButton.setTitle(dataModel.buttonTitle, for: .normal)
        selectedButton.titleLabel?.font = dataModel.buttonLabelFont
        selectedButton.backgroundColor = dataModel.buttonBackColor
        selectedButton.setTitleColor(dataModel.buttonTitleColor, for: .normal)
        
        noteLabel.text = dataModel.noteMsg
        noteLabel.font = dataModel.noteMsgFont
        noteLabel.textColor = dataModel.noteMsgColor
        
        setNeedsLayout()
    }
    
    // MARK: - Lazy
    private lazy var msgLabel: UILabel = {
        let msgLabel = MKSwiftUIAdaptor.createNormalLabel()
        msgLabel.numberOfLines = 0
        return msgLabel
    }()
    private lazy var selectedButton: UIButton = {
        let selectedButton = MKSwiftUIAdaptor.createRoundedButton(title: "",
                                                                  target: self,
                                                                  action: #selector(selectedButtonPressed))
        return selectedButton
    }()
    private lazy var noteLabel: UILabel = {
        let noteLabel = MKSwiftUIAdaptor.createNormalLabel(font: MKFont.font(12))
        noteLabel.numberOfLines = 0
        return noteLabel
    }()
}
