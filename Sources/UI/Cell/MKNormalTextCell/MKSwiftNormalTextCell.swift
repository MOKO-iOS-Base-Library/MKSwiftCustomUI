//
//  MKSwiftNormalTextCell.swift
//  MKBaseSwiftModule
//
//  Created by aa on 2024/4/9.
//

import UIKit
import SnapKit

import MKBaseSwiftModule

// MARK: - Cell Model
public class MKSwiftNormalTextCellModel {
    public var methodName: String = ""
    public var contentColor: UIColor = .white
    
    // Left label and icon
    public var leftIcon: UIImage?
    public var leftMsgTextFont: UIFont = MKFont.font(15)
    public var leftMsgTextColor: UIColor = MKColor.defaultText
    public var leftMsg: String = ""
    
    // Right label
    public var rightMsgTextFont: UIFont = MKFont.font(13)
    public var rightMsgTextColor: UIColor = MKColor.fromHex(0x808080)
    public var rightMsg: String = ""
    public var showRightIcon: Bool = false
    
    // Bottom label
    public var noteMsg: String = ""
    public var noteMsgColor: UIColor = MKColor.defaultText
    public var noteMsgFont: UIFont = MKFont.font(12)

    private let offsetX: CGFloat = 15

    public func cellHeightWithContentWidth(_ width: CGFloat) -> CGFloat {
        let maxMsgWidth: CGFloat
        if let icon = leftIcon {
            maxMsgWidth = width / 2 - offsetX - 3 - icon.size.width - 3
        } else {
            maxMsgWidth = width / 2 - offsetX - 3
        }

        let msgSize = leftMsg.size(withFont: leftMsgTextFont, maxSize: CGSize(width: maxMsgWidth, height: .greatestFiniteMagnitude))

        guard !noteMsg.isEmpty else {
            return max(msgSize.height + 2 * offsetX, 50)
        }

        let noteSize = noteMsg.size(withFont: noteMsgFont, maxSize: CGSize(width: (width - 2 * offsetX), height: .greatestFiniteMagnitude))

        return max(msgSize.height + 2 * offsetX, 50) + noteSize.height + 10
    }
    
    public init() {}  
}

// MARK: - Cell Implementation
public class MKSwiftNormalTextCell: MKSwiftBaseCell {
    
    // MARK: - Properties
    public var dataModel: MKSwiftNormalTextCellModel? {
        didSet {
            updateContent()
        }
    }
    
    // MARK: - Class Methods
    public class func initCellWithTableView(_ tableView: UITableView) -> MKSwiftNormalTextCell {
        let identifier = "MKSwiftNormalTextCellIdenty"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? MKSwiftNormalTextCell
        if cell == nil {
            cell = MKSwiftNormalTextCell(style: .default, reuseIdentifier: identifier)
        }
        return cell!
    }
    
    // MARK: - UI Components
    private var leftIcon: UIImageView?
    
    private let offsetX: CGFloat = 15
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(leftMsgLabel)
        contentView.addSubview(rightMsgLabel)
        contentView.addSubview(rightIcon)
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
        
        leftMsgLabel.snp.remakeConstraints { make in
            if let leftIcon = leftIcon {
                make.left.equalTo(leftIcon.snp.right).offset(3)
            } else {
                make.left.equalToSuperview().offset(offsetX)
            }
            make.right.equalTo(contentView.snp.centerX).offset(-3)
            
            if hasNote {
                make.top.equalToSuperview().offset(offsetX)
            } else {
                make.centerY.equalToSuperview()
            }
            make.height.equalTo(msgSize.height)
        }
        
        if let leftIcon = leftIcon, let imageSize = leftIcon.image?.size {
            leftIcon.snp.remakeConstraints { make in
                make.left.equalToSuperview().offset(offsetX)
                make.width.equalTo(imageSize.width)
                make.centerY.equalTo(leftMsgLabel.snp.centerY)
                make.height.equalTo(imageSize.height)
            }
        }
        
        rightIcon.snp.remakeConstraints { make in
            make.right.equalToSuperview().offset(-15)
            make.width.equalTo(8)
            make.centerY.equalToSuperview()
            make.height.equalTo(14)
        }
        
        rightMsgLabel.snp.remakeConstraints { make in
            if dataModel?.showRightIcon == true {
                make.right.equalTo(rightIcon.snp.left).offset(-2)
            } else {
                make.right.equalToSuperview().offset(-15)
            }
            make.left.equalTo(contentView.snp.centerX).offset(-2)
            make.centerY.equalTo(leftMsgLabel.snp.centerY)
            make.height.equalTo(rightMsgLabel.font.lineHeight)
        }
        
        let noteSize = self.noteSize()
        noteLabel.snp.remakeConstraints { make in
            make.left.equalToSuperview().offset(offsetX)
            make.right.equalToSuperview().offset(-offsetX)
            make.bottom.equalToSuperview().offset(-offsetX)
            make.height.equalTo(noteSize.height)
        }
    }
    
    // MARK: - Helper Methods
    private func msgSize() -> CGSize {
        guard let text = leftMsgLabel.text, !text.isEmpty else {
            return .zero
        }

        var maxMsgWidth = contentView.frame.width / 2 - offsetX - 3
        if let leftIcon = leftIcon, let imageSize = leftIcon.image?.size {
            maxMsgWidth -= imageSize.width + 3
        }

        return text.size(withFont: leftMsgLabel.font, maxSize: CGSize(width: maxMsgWidth, height: .greatestFiniteMagnitude))
    }

    private func noteSize() -> CGSize {
        guard let text = noteLabel.text, !text.isEmpty else {
            return .zero
        }

        let width = contentView.frame.width - 2 * offsetX
        return text.size(withFont: noteLabel.font, maxSize: CGSize(width: width, height: .greatestFiniteMagnitude))
    }
    
    // MARK: - UI Setup
    
    private func updateContent() {
        guard let dataModel = dataModel else { return }
        
        contentView.backgroundColor = dataModel.contentColor
        leftMsgLabel.text = dataModel.leftMsg
        leftMsgLabel.textColor = dataModel.leftMsgTextColor
        leftMsgLabel.font = dataModel.leftMsgTextFont
        
        rightMsgLabel.text = dataModel.rightMsg
        rightMsgLabel.textColor = dataModel.rightMsgTextColor
        rightMsgLabel.font = dataModel.rightMsgTextFont
        
        rightIcon.isHidden = !dataModel.showRightIcon
        
        // Handle left icon
        leftIcon?.removeFromSuperview()
        leftIcon = nil
        
        if let icon = dataModel.leftIcon {
            let imageView = UIImageView(image: icon)
            leftIcon = imageView
            contentView.addSubview(imageView)
        }
        
        noteLabel.text = dataModel.noteMsg
        noteLabel.font = dataModel.noteMsgFont
        noteLabel.textColor = dataModel.noteMsgColor
        
        setNeedsLayout()
    }
    
    private lazy var leftMsgLabel: UILabel = {
        let leftMsgLabel = MKSwiftUIAdaptor.createNormalLabel()
        leftMsgLabel.numberOfLines = 0
        return leftMsgLabel
    }()
    private lazy var rightMsgLabel: UILabel = {
        let rightMsgLabel = UILabel()
        rightMsgLabel.textColor = MKColor.fromHex(0x808080)
        rightMsgLabel.textAlignment = .right
        rightMsgLabel.font = MKFont.font(13)
        return rightMsgLabel
    }()
    private lazy var rightIcon: UIImageView = {
        let rightIcon = UIImageView()
        rightIcon.image = moduleIcon(name: "mk_swift_goNextButton")
        rightIcon.isHidden = true
        return rightIcon
    }()
    private lazy var noteLabel: UILabel = {
        let noteLabel = MKSwiftUIAdaptor.createNormalLabel(font: MKFont.font(12))
        noteLabel.numberOfLines = 0
        return noteLabel
    }()
}
