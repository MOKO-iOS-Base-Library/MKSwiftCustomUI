//
//  MKSwiftDeviceInfoCell.swift
//  MKBaseSwiftModule
//
//  Created by aa on 2024/4/10.
//

import UIKit
import SnapKit

import MKBaseSwiftModule

// MARK: - Cell Model
public class MKSwiftDeviceInfoCellModel {
    public var leftMsg: String = ""
    public var rightMsg: String = ""
    
    public init() {}
    
    public func cellHeightWithContentWidth(_ width: CGFloat) -> CGFloat {
        let leftSize = leftMsg.size(withFont: MKFont.font(15), maxSize: CGSize(width: (width / 2 - 15 - 5), height: .greatestFiniteMagnitude))
        
        let rightSize = rightMsg.size(withFont: MKFont.font(15), maxSize: CGSize(width: (width / 2 - 15 - 5), height: .greatestFiniteMagnitude))
        
        let height = max(leftSize.height, rightSize.height)
        return max(44, height + 20)
    }
}

// MARK: - Cell Implementation
public class MKSwiftDeviceInfoCell: MKSwiftBaseCell {
    
    // MARK: - Properties
    public var dataModel: MKSwiftDeviceInfoCellModel? {
        didSet {
            updateContent()
        }
    }
    
    // MARK: - Class Methods
    public class func initCellWithTableView(_ tableView: UITableView) -> MKSwiftDeviceInfoCell {
        let identifier = "MKSwiftDeviceInfoCellIdenty"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? MKSwiftDeviceInfoCell
        if cell == nil {
            cell = MKSwiftDeviceInfoCell(style: .default, reuseIdentifier: identifier)
        }
        return cell!
    }
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(msgLabel)
        contentView.addSubview(rightMsgLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        let leftSize = msgLabel.text?.size(withFont: msgLabel.font, maxSize: CGSize(width: (contentView.frame.width / 2 - 15 - 5), height: .greatestFiniteMagnitude))
        
        msgLabel.snp.remakeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.right.equalTo(contentView.snp.centerX).offset(-5)
            make.centerY.equalToSuperview()
            make.height.equalTo(leftSize?.height ?? MKFont.font(15).lineHeight)
        }
        
        let rightSize = rightMsgLabel.text?.size(withFont: rightMsgLabel.font, maxSize: CGSize(width: (contentView.frame.width / 2 - 15 - 5), height: .greatestFiniteMagnitude))
        
        rightMsgLabel.snp.remakeConstraints { make in
            make.right.equalToSuperview().offset(-15)
            make.left.equalTo(contentView.snp.centerX).offset(5)
            make.centerY.equalToSuperview()
            make.height.equalTo(rightSize?.height ?? MKFont.font(15).lineHeight)
        }
    }
    
    // MARK: - UI Setup
    
    // MARK: - Update UI
    private func updateContent() {
        guard let dataModel = dataModel else { return }
        
        msgLabel.text = dataModel.leftMsg
        rightMsgLabel.text = dataModel.rightMsg
        
        setNeedsLayout()
    }
    
    // MARK: - Lazy
    private lazy var msgLabel: UILabel = {
        let msgLabel = MKSwiftUIAdaptor.createNormalLabel()
        msgLabel.numberOfLines = 0
        return msgLabel
    }()
    private lazy var rightMsgLabel: UILabel = {
        let rightMsgLabel = MKSwiftUIAdaptor.createNormalLabel(font: MKFont.font(13))
        rightMsgLabel.numberOfLines = 0
        return rightMsgLabel
    }()
}
