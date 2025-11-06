//
//  MKSwiftFilterNormalTextFieldCell.swift
//  MKBaseSwiftModule
//
//  Created by aa on 2024/4/11.
//

import UIKit
import SnapKit

import MKBaseSwiftModule

// MARK: - Cell Model
public class MKSwiftFilterNormalTextFieldCellModel {
    public var index: Int = 0
    public var msg: String = ""
    public var textFieldValue: String = ""
    public var textPlaceholder: String = ""
    public var textFieldType: MKSwiftTextFieldType = .normal
    public var maxLength: Int = 0
    
    public init() {}
}

// MARK: - Cell Delegate
public protocol MKSwiftFilterNormalTextFieldCellDelegate: AnyObject {
    func mk_filterNormalTextFieldValueChanged(_ text: String, index: Int)
}

// MARK: - Cell Implementation
public class MKSwiftFilterNormalTextFieldCell: MKSwiftBaseCell {
    
    // MARK: - Properties
    public var dataModel: MKSwiftFilterNormalTextFieldCellModel? {
        didSet {
            updateContent()
        }
    }
    
    public weak var delegate: MKSwiftFilterNormalTextFieldCellDelegate?
    
    // MARK: - Class Methods
    public class func initCellWithTableView(_ tableView: UITableView) -> MKSwiftFilterNormalTextFieldCell {
        let identifier = "MKSwiftFilterNormalTextFieldCellIdenty"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? MKSwiftFilterNormalTextFieldCell
        if cell == nil {
            cell = MKSwiftFilterNormalTextFieldCell(style: .default, reuseIdentifier: identifier)
        }
        return cell!
    }
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(msgLabel)
        contentView.addSubview(textField)
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
            make.height.equalTo(msgLabel.font.lineHeight)
        }
        
        textField.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.top.equalTo(msgLabel.snp.bottom).offset(5)
            make.bottom.equalToSuperview().offset(-5)
        }
    }
    
    // MARK: - Update UI
    private func updateContent() {
        guard let dataModel = dataModel else { return }
        
        msgLabel.text = dataModel.msg
        textField.textType = dataModel.textFieldType
        textField.placeholder = dataModel.textPlaceholder
        textField.text = dataModel.textFieldValue
        textField.maxLength = dataModel.maxLength
    }
    
    // MARK: - Lazy
    
    private lazy var msgLabel: UILabel = {
        return MKSwiftUIAdaptor.createNormalLabel()
    }()
    
    private lazy var textField: MKSwiftTextField = {
        let textField = MKSwiftUIAdaptor.createTextField(textType: .realNumberOnly)
        textField.textChangedBlock = { [weak self] text in
            guard let self = self else { return }
            self.delegate?.mk_filterNormalTextFieldValueChanged(text, index: self.dataModel?.index ?? 0)
        }
        return textField
    }()
}
