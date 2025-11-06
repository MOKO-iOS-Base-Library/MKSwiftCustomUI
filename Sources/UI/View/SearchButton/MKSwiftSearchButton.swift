//
//  MKSwiftSearchButton.swift
//  MKBaseSwiftModule
//
//  Created by aa on 2024/3/11.
//

import UIKit
import SnapKit

import MKBaseSwiftModule

// MARK: - Data Model
public class MKSwiftSearchButtonDataModel {
    /// 显示的标题
    public var placeholder: String?
    
    /// 显示的搜索关键字(设备名称、MAC地址的一部分或者全部字段)
    public var searchKey: String?
    
    /// 过滤的RSSI值
    public var searchRssi: Int = 0
    
    /// 过滤的最小RSSI值，当searchRssi == minSearchRssi时，不显示searchRssi搜索条件
    public var minSearchRssi: Int = 0
    
    public init() {}
}

// MARK: - Delegate Protocol
public protocol MKSwiftSearchButtonDelegate: AnyObject {
    /// 搜索按钮点击事件
    func mk_scanSearchButtonMethod()
    
    /// 搜索按钮右侧清除按钮点击事件
    func mk_scanSearchButtonClearMethod()
}

// MARK: - Main Button Class
public class MKSwiftSearchButton: UIControl {
    
    // MARK: - UI Components
    private lazy var searchIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = moduleIcon(name: "mk_swift_searchGrayIcon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = MKColor.rgb(220, 220, 220)
        label.textAlignment = .left
        label.font = MKFont.font(15)
        label.text = "Edit Filter"
        return label
    }()
    
    private lazy var searchLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkText
        label.textAlignment = .left
        label.font = MKFont.font(15)
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private lazy var clearButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(moduleIcon(name: "mk_swift_clearButtonIcon"), for: .normal)
        button.addTarget(self, action: #selector(clearButtonPressed), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Properties
    public weak var delegate: MKSwiftSearchButtonDelegate?
    
    public var dataModel: MKSwiftSearchButtonDataModel? {
        didSet {
            updateUI()
        }
    }
    
    // MARK: - Initialization
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("MKSwiftSearchButton deallocated")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        backgroundColor = .white
        layer.masksToBounds = true
        layer.cornerRadius = 4.0
        
        addSubview(searchIcon)
        addSubview(titleLabel)
        addSubview(searchLabel)
        addSubview(clearButton)
        
        addTarget(self, action: #selector(searchButtonPressed), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        searchIcon.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.width.equalTo(22)
            make.centerY.equalToSuperview()
            make.height.equalTo(22)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(searchIcon.snp.right).offset(10)
            make.right.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
            make.height.equalTo(20)
        }
        
        searchLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.right.equalTo(clearButton.snp.left).offset(-10)
            make.centerY.equalToSuperview()
            make.height.equalTo(20)
        }
        
        clearButton.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.width.equalTo(45)
            make.centerY.equalToSuperview()
            make.height.equalToSuperview()
        }
    }
    
    // MARK: - Private Methods
    private func updateUI() {
        guard let dataModel = dataModel else { return }
        
        titleLabel.text = dataModel.placeholder?.isEmpty == false ? dataModel.placeholder : "Edit Filter"
        
        var conditions: [String] = []
        
        if let searchKey = dataModel.searchKey, !searchKey.isEmpty {
            conditions.append(searchKey)
        }
        
        if dataModel.searchRssi > dataModel.minSearchRssi {
            conditions.append("\(dataModel.searchRssi)dBm")
        }
        
        if conditions.isEmpty {
            titleLabel.isHidden = false
            searchIcon.isHidden = false
            searchLabel.isHidden = true
            clearButton.isHidden = true
            return
        }
        
        titleLabel.isHidden = true
        searchIcon.isHidden = true
        searchLabel.isHidden = false
        clearButton.isHidden = false
        
        let title = conditions.joined(separator: ";")
        searchLabel.text = title
    }
    
    // MARK: - Button Actions
    @objc private func clearButtonPressed() {
        titleLabel.isHidden = false
        searchIcon.isHidden = false
        searchLabel.isHidden = true
        clearButton.isHidden = true
        
        delegate?.mk_scanSearchButtonClearMethod()
    }
    
    @objc private func searchButtonPressed() {
        delegate?.mk_scanSearchButtonMethod()
    }
}
