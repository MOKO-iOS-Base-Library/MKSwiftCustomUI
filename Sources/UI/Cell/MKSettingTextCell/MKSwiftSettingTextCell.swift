//
//  MKSwiftSettingTextCell.swift
//  MKBaseSwiftModule
//
//  Created by aa on 2024/3/29.
//

import UIKit
import SnapKit

import MKBaseSwiftModule

// MARK: - Cell Model
public class MKSwiftSettingTextCellModel {
    public var contentColor: UIColor = .white
    
    // Left label and icon
    public var leftIcon: UIImage?
    public var leftMsgTextFont: UIFont = MKFont.font(15)
    public var leftMsgTextColor: UIColor = MKColor.defaultText
    public var leftMsg: String = ""
    
    public init() {}
}

// MARK: - Cell Implementation
public class MKSwiftSettingTextCell: MKSwiftBaseCell {
    
    // MARK: - Properties
    public var dataModel: MKSwiftSettingTextCellModel? {
        didSet {
            updateContent()
        }
    }
    
    // MARK: - Class Methods
    public class func initCellWithTableView(_ tableView: UITableView) -> MKSwiftSettingTextCell {
        let identifier = "MKSwiftSettingTextCellIdenty"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? MKSwiftSettingTextCell
        if cell == nil {
            cell = MKSwiftSettingTextCell(style: .default, reuseIdentifier: identifier)
        }
        return cell!
    }
    
    private var leftIcon: UIImageView?
    private let offset_X: CGFloat = 15
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(leftMsgLabel)
        contentView.addSubview(rightIcon)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        if let leftIcon = leftIcon {
            leftIcon.snp.remakeConstraints { make in
                make.left.equalToSuperview().offset(offset_X)
                make.width.equalTo(leftIcon.image!.size.width)
                make.centerY.equalTo(leftMsgLabel.snp.centerY)
                make.height.equalTo(leftIcon.image!.size.height)
            }
        }
        
        leftMsgLabel.snp.remakeConstraints { make in
            if let leftIcon = leftIcon {
                make.left.equalTo(leftIcon.snp.right).offset(3)
            } else {
                make.left.equalToSuperview().offset(offset_X)
            }
            make.right.equalTo(rightIcon.snp.left).offset(-5)
            make.centerY.equalToSuperview()
            make.height.equalTo(leftMsgLabel.font.lineHeight)
        }
        
        rightIcon.snp.remakeConstraints { make in
            make.right.equalToSuperview().offset(-15)
            make.width.equalTo(8)
            make.centerY.equalToSuperview()
            make.height.equalTo(14)
        }
    }
    
    // MARK: - Update UI
    private func updateContent() {
        guard let dataModel = dataModel else { return }
        
        contentView.backgroundColor = dataModel.contentColor
        leftMsgLabel.text = dataModel.leftMsg
        leftMsgLabel.textColor = dataModel.leftMsgTextColor
        leftMsgLabel.font = dataModel.leftMsgTextFont
        
        // Handle left icon
        leftIcon?.removeFromSuperview()
        leftIcon = nil
        
        if let icon = dataModel.leftIcon {
            leftIcon = UIImageView(image: icon)
            contentView.addSubview(leftIcon!)
        }
        
        setNeedsLayout()
    }
    
    // MARK: - UI Components
    
    private lazy var leftMsgLabel: UILabel = {
        let leftMsgLabel = MKSwiftUIAdaptor.createNormalLabel()
        leftMsgLabel.numberOfLines = 0
        return leftMsgLabel
    }()
    private lazy var rightIcon: UIImageView = {
        let rightIcon = UIImageView()
        rightIcon.image = moduleIcon(name: "mk_swift_goNextButton")
        return rightIcon
    }()
}
