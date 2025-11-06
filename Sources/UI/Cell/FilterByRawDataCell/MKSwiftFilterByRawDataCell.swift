//
//  MKSwiftFilterByRawDataCell.swift
//  MKBaseSwiftModule
//
//  Created by aa on 2024/4/10.
//

import UIKit
import SnapKit

import MKBaseSwiftModule

public class MKSwiftFilterByRawDataCellModel {
    public var index: Int = 0
    public var msg: String = ""
    public var contentColor: UIColor = .white
    public var dataType: String = ""
    public var minIndex: String = ""
    public var maxIndex: String = ""
    public var rawData: String = ""
    public var rawDataMaxBytes: Int = 29
    public var dataTypePlaceHolder: String = ""
    public var minTextFieldPlaceHolder: String = ""
    public var maxTextFieldPlaceHolder: String = ""
    public var rawTextFieldPlaceHolder: String = ""
    
    public init() {}
    
    public func validParamsSuccess() -> Bool {
        // Use String.isHexadecimal constant with matchesRegex method
        guard dataType.count == 2, dataType.matchesRegex(String.isHexadecimal) else {
            return false
        }
        
        if minIndex.isEmpty && maxIndex.isEmpty {
            return validRawDatas()
        }
        
        // Use String.isRealNumbers constant with matchesRegex method
        guard !minIndex.isEmpty, minIndex.count <= 2, minIndex.matchesRegex(String.isRealNumbers),
              let minValue = Int(minIndex), minValue >= 0, minValue <= rawDataMaxBytes else {
            return false
        }
        
        if minValue == 0 {
            if (maxIndex.isEmpty || (Int(maxIndex) == 0)) && validRawDatas() {
                return true
            }
            return false
        }
        
        guard !maxIndex.isEmpty, maxIndex.count <= 2, maxIndex.matchesRegex(String.isRealNumbers),
              let maxValue = Int(maxIndex), maxValue >= 0, maxValue <= rawDataMaxBytes,
              maxValue >= minValue else {
            return false
        }
        
        guard MKValid.isStringValid(rawData), rawData.count <= rawDataMaxBytes * 2,
              rawData.matchesRegex(String.isHexadecimal) else {
            return false
        }
        
        let totalLen = (maxValue - minValue + 1) * 2
        return rawData.count == totalLen
    }
    
    public func validRawDatas() -> Bool {
        guard MKValid.isStringValid(rawData), rawData.count <= rawDataMaxBytes * 2,
              rawData.matchesRegex(String.isHexadecimal) else {
            return false
        }
        return rawData.count % 2 == 0
    }
}

public enum MKFilterByRawDataTextType: Int {
    case dataType
    case minIndex
    case maxIndex
    case rawDataType
}

public protocol MKSwiftFilterByRawDataCellDelegate: AnyObject {
    func mk_rawFilterDataChanged(_ textType: MKFilterByRawDataTextType, index: Int, textValue: String)
}

public class MKSwiftFilterByRawDataCell: MKSwiftBaseCell {
    public var dataModel: MKSwiftFilterByRawDataCellModel? {
        didSet {
            updateContent()
        }
    }
    
    public weak var delegate: MKSwiftFilterByRawDataCellDelegate?
    
    // MARK: - Class Methods
    public class func initCellWithTableView(_ tableView: UITableView) -> MKSwiftFilterByRawDataCell {
        let identifier = "MKSwiftFilterByRawDataCellIdenty"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? MKSwiftFilterByRawDataCell
        if cell == nil {
            cell = MKSwiftFilterByRawDataCell(style: .default, reuseIdentifier: identifier)
        }
        return cell!
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(msgLabel)
        contentView.addSubview(typeTextField)
        contentView.addSubview(minTextField)
        contentView.addSubview(maxTextField)
        contentView.addSubview(characterLabel)
        contentView.addSubview(unitLabel)
        contentView.addSubview(rawDataField)
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
        setupUI()
    }
    
    private func setupUI() {
        msgLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.top.equalToSuperview().offset(5)
            make.height.equalTo(MKFont.font(15).lineHeight)
        }
        
        typeTextField.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.width.equalTo(70)
            make.top.equalTo(msgLabel.snp.bottom).offset(5)
            make.height.equalTo(30)
        }
        
        minTextField.snp.makeConstraints { make in
            make.left.equalTo(typeTextField.snp.right).offset(20)
            make.width.equalTo(40)
            make.centerY.equalTo(typeTextField)
            make.height.equalTo(typeTextField)
        }
        
        characterLabel.snp.makeConstraints { make in
            make.left.equalTo(minTextField.snp.right).offset(5)
            make.width.equalTo(20)
            make.centerY.equalTo(typeTextField)
            make.height.equalTo(typeTextField)
        }
        
        maxTextField.snp.makeConstraints { make in
            make.left.equalTo(characterLabel.snp.right).offset(5)
            make.width.equalTo(40)
            make.centerY.equalTo(typeTextField)
            make.height.equalTo(typeTextField)
        }
        
        unitLabel.snp.makeConstraints { make in
            make.left.equalTo(maxTextField.snp.right).offset(3)
            make.width.equalTo(40)
            make.centerY.equalTo(typeTextField)
            make.height.equalTo(typeTextField)
        }
        
        rawDataField.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.top.equalTo(typeTextField.snp.bottom).offset(15)
            make.bottom.equalToSuperview().offset(-5)
        }
    }
    
    //MARK: - Event method
    @objc private func textFieldHiddenKeyboard() {
        [typeTextField, minTextField, maxTextField, rawDataField].forEach {
            $0.resignFirstResponder()
        }
    }
    
    private func textFieldValueChanged(_ text: String, textType: MKFilterByRawDataTextType) {
        guard let dataModel = dataModel else { return }
        delegate?.mk_rawFilterDataChanged(textType, index: dataModel.index, textValue: text)
    }
    
    //MARK: - Private method
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(textFieldHiddenKeyboard),
            name: Notification.Name("MKTextFieldNeedHiddenKeyboard"),
            object: nil
        )
    }
    
    private func updateContent() {
        guard let dataModel = dataModel else { return }
        msgLabel.text = dataModel.msg
        contentView.backgroundColor = dataModel.contentColor
        typeTextField.text = dataModel.dataType
        typeTextField.placeholder = dataModel.dataTypePlaceHolder
        minTextField.text = dataModel.minIndex
        minTextField.placeholder = dataModel.minTextFieldPlaceHolder
        maxTextField.text = dataModel.maxIndex
        maxTextField.placeholder = dataModel.maxTextFieldPlaceHolder
        rawDataField.text = dataModel.rawData
        rawDataField.placeholder = dataModel.rawTextFieldPlaceHolder
        rawDataField.maxLength = dataModel.rawDataMaxBytes * 2
    }
    
    //MARK: - Lazy method
    private lazy var msgLabel: UILabel = {
        return MKSwiftUIAdaptor.createNormalLabel()
    }()
    
    private lazy var typeTextField: MKSwiftTextField = {
        let textField = MKSwiftUIAdaptor.createTextField(placeholder: "",
                                                         textType: .hexCharOnly,
                                                         maxLen: 2)
        textField.font = MKFont.font(13)
        textField.textChangedBlock = { [weak self] text in
            self?.textFieldValueChanged(text, textType: .dataType)
        }
        return textField
    }()
    
    private lazy var minTextField: MKSwiftTextField = {
        let textField = MKSwiftUIAdaptor.createTextField(placeholder: "",
                                                         textType: .realNumberOnly,
                                                         maxLen: 2)
        textField.font = MKFont.font(13)
        textField.textChangedBlock = { [weak self] text in
            self?.textFieldValueChanged(text, textType: .minIndex)
        }
        return textField
    }()
    
    private lazy var maxTextField: MKSwiftTextField = {
        let textField = MKSwiftUIAdaptor.createTextField(placeholder: "",
                                                         textType: .realNumberOnly,
                                                         maxLen: 2)
        textField.font = MKFont.font(13)
        textField.textChangedBlock = { [weak self] text in
            self?.textFieldValueChanged(text, textType: .maxIndex)
        }
        return textField
    }()
    
    private lazy var characterLabel: UILabel = {
        return MKSwiftUIAdaptor.createNormalLabel(font: MKFont.font(20),text: "~")
    }()
    
    private lazy var unitLabel: UILabel = {
        return MKSwiftUIAdaptor.createNormalLabel(font: MKFont.font(13),text: "Byte")
    }()
    
    private lazy var rawDataField: MKSwiftTextField = {
        let textField = MKSwiftUIAdaptor.createTextField(placeholder: "",
                                                         textType: .hexCharOnly)
        textField.font = MKFont.font(13)
        textField.textChangedBlock = { [weak self] text in
            self?.textFieldValueChanged(text, textType: .rawDataType)
        }
        return textField
    }()
}
