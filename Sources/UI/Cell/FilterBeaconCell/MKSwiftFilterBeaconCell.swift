//
//  MKSwiftFilterBeaconCell.swift
//  MKBaseSwiftModule
//
//  Created by aa on 2024/4/10.
//

import UIKit
import SnapKit

import MKBaseSwiftModule

public class MKSwiftFilterBeaconCellModel {
    public var index: Int = 0
    public var msg: String = ""
    public var minValue: String = ""
    public var maxValue: String = ""
    
    public init() {}
}

public protocol MKSwiftFilterBeaconCellDelegate: AnyObject {
    func mk_beaconMinValueChanged(_ value: String, index: Int)
    func mk_beaconMaxValueChanged(_ value: String, index: Int)
}

public class MKSwiftFilterBeaconCell: MKSwiftBaseCell {
    public var dataModel: MKSwiftFilterBeaconCellModel? {
        didSet {
            updateContent()
        }
    }
    
    public weak var delegate: MKSwiftFilterBeaconCellDelegate?
    
    // MARK: - Class Methods
    public class func initCellWithTableView(_ tableView: UITableView) -> MKSwiftFilterBeaconCell {
        let identifier = "MKSwiftFilterBeaconCellIdenty"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? MKSwiftFilterBeaconCell
        if cell == nil {
            cell = MKSwiftFilterBeaconCell(style: .default, reuseIdentifier: identifier)
        }
        return cell!
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(msgLabel)
        contentView.addSubview(minLabel)
        contentView.addSubview(minTextField)
        contentView.addSubview(centerLabel)
        contentView.addSubview(maxLabel)
        contentView.addSubview(maxTextField)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        msgLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.top.equalToSuperview().offset(5)
            make.height.equalTo(MKFont.font(15).lineHeight)
        }
        
        minLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.width.equalTo(50)
            make.centerY.equalTo(minTextField)
            make.height.equalTo(MKFont.font(15).lineHeight)
        }
        
        minTextField.snp.makeConstraints { make in
            make.left.equalTo(minLabel.snp.right).offset(5)
            make.width.equalTo(80)
            make.top.equalTo(msgLabel.snp.bottom).offset(5)
            make.height.equalTo(30)
        }
        
        centerLabel.snp.makeConstraints { make in
            make.left.equalTo(minTextField.snp.right).offset(10)
            make.width.equalTo(30)
            make.centerY.equalTo(minTextField)
            make.height.equalTo(MKFont.font(15).lineHeight)
        }
        
        maxLabel.snp.makeConstraints { make in
            make.left.equalTo(centerLabel.snp.right).offset(10)
            make.width.equalTo(50)
            make.centerY.equalTo(minTextField)
            make.height.equalTo(MKFont.font(15).lineHeight)
        }
        
        maxTextField.snp.makeConstraints { make in
            make.left.equalTo(maxLabel.snp.right).offset(5)
            make.width.equalTo(80)
            make.centerY.equalTo(minTextField)
            make.height.equalTo(30)
        }
    }
    
    //MARK: - Private method
    private func updateContent() {
        guard let dataModel = dataModel else { return }
        msgLabel.text = dataModel.msg
        minTextField.text = dataModel.minValue
        maxTextField.text = dataModel.maxValue
    }
    
    //MARK: - Lazy method
    private lazy var msgLabel: UILabel = {
        return MKSwiftUIAdaptor.createNormalLabel()
    }()
    
    private lazy var minLabel: UILabel = {
        return MKSwiftUIAdaptor.createNormalLabel(text: "Min")
    }()
    
    private lazy var minTextField: MKSwiftTextField = {
        let textField = MKSwiftUIAdaptor.createTextField(placeholder: "0~65535",
                                                         textType: .realNumberOnly,
                                                         maxLen: 5)
        textField.textChangedBlock = { [weak self] text in
            guard let self = self, let dataModel = self.dataModel else { return }
            self.delegate?.mk_beaconMinValueChanged(text, index: dataModel.index)
        }
        return textField
    }()
    
    private lazy var centerLabel: UILabel = {
        return MKSwiftUIAdaptor.createNormalLabel(text: "~")
    }()
    
    private lazy var maxLabel: UILabel = {
        return MKSwiftUIAdaptor.createNormalLabel(text: "Max")
    }()
    
    private lazy var maxTextField: MKSwiftTextField = {
        let textField = MKSwiftUIAdaptor.createTextField(placeholder: "0~65535",
                                                         textType: .realNumberOnly,
                                                         maxLen: 5)
        textField.textChangedBlock = { [weak self] text in
            guard let self = self, let dataModel = self.dataModel else { return }
            self.delegate?.mk_beaconMaxValueChanged(text, index: dataModel.index)
        }
        return textField
    }()
}
