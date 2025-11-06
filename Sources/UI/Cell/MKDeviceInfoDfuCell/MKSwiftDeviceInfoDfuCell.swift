//
//  MKSwiftDeviceInfoDfuCell.swift
//  MKBaseSwiftModule
//
//  Created by aa on 2024/3/27.
//

import UIKit
import SnapKit

import MKBaseSwiftModule

// MARK: - Cell Model
public class MKSwiftDeviceInfoDfuCellModel {
    public var index: Int = 0
    public var leftMsg: String = ""
    public var rightMsg: String = ""
    public var rightButtonTitle: String = ""
    
    public init() {}
}

// MARK: - Cell Delegate
public protocol MKSwiftDeviceInfoDfuCellDelegate: AnyObject {
    func mk_textButtonCell_buttonAction(_ index: Int)
}

// MARK: - Cell Implementation
public class MKSwiftDeviceInfoDfuCell: MKSwiftBaseCell {
    
    // MARK: - Properties
    public var dataModel: MKSwiftDeviceInfoDfuCellModel? {
        didSet {
            updateContent()
        }
    }
    
    public weak var delegate: MKSwiftDeviceInfoDfuCellDelegate?
    
    // MARK: - Class Methods
    public class func initCellWithTableView(_ tableView: UITableView) -> MKSwiftDeviceInfoDfuCell {
        let identifier = "MKSwiftDeviceInfoDfuCellIdenty"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? MKSwiftDeviceInfoDfuCell
        if cell == nil {
            cell = MKSwiftDeviceInfoDfuCell(style: .default, reuseIdentifier: identifier)
        }
        return cell!
    }
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(msgLabel)
        contentView.addSubview(rightMsgLabel)
        contentView.addSubview(rightButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        msgLabel.snp.remakeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.right.equalTo(contentView.snp.centerX).offset(-5)
            make.centerY.equalToSuperview()
            make.height.equalTo(msgLabel.font.lineHeight)
        }
        
        rightButton.snp.remakeConstraints { make in
            make.right.equalToSuperview().offset(-15)
            make.width.equalTo(50)
            make.centerY.equalToSuperview()
            make.height.equalTo(35)
        }
        
        rightMsgLabel.snp.remakeConstraints { make in
            make.left.equalTo(contentView.snp.centerX).offset(10)
            make.right.equalTo(rightButton.snp.left).offset(-10)
            make.centerY.equalToSuperview()
            make.height.equalTo(rightMsgLabel.font.lineHeight)
        }
    }
    
    // MARK: - Actions
    @objc private func rightButtonPressed() {
        delegate?.mk_textButtonCell_buttonAction(dataModel?.index ?? 0)
    }
    
    
    // MARK: - Update UI
    private func updateContent() {
        guard let dataModel = dataModel else { return }
        
        msgLabel.text = dataModel.leftMsg
        rightMsgLabel.text = dataModel.rightMsg
        rightButton.setTitle(dataModel.rightButtonTitle, for: .normal)
        
        setNeedsLayout()
    }
    
    // MARK: - UI Components
    private lazy var msgLabel: UILabel = {
        return MKSwiftUIAdaptor.createNormalLabel()
    }()
    private lazy var rightMsgLabel: UILabel = {
        let rightMsgLabel = UILabel()
        rightMsgLabel.textColor = MKColor.fromHex(0x808080)
        rightMsgLabel.font = MKFont.font(13)
        rightMsgLabel.textAlignment = .right
        return rightMsgLabel
    }()
    private lazy var rightButton: UIButton = {
        let rightButton = MKSwiftUIAdaptor.createRoundedButton(title: "",
                                                               target: self,
                                                               action: #selector(rightButtonPressed))
        rightButton.titleLabel?.font = MKFont.font(12)
        return rightButton
    }()
}
