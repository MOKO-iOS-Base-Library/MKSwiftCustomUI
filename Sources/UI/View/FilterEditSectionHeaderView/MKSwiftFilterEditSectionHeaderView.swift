//
//  MKSwiftFilterEditSectionHeaderView.swift
//  MKBaseSwiftModule
//
//  Created by aa on 2024/4/11.
//

import UIKit
import SnapKit

import MKBaseSwiftModule

// MARK: - Data Model
public class MKSwiftFilterEditSectionHeaderViewModel {
    /// sectionHeader所在index
    public var index: Int = 0
    public var msg: String?
    public var contentColor: UIColor?
    
    public init() {}
}

// MARK: - Delegate Protocol
public protocol MKSwiftFilterEditSectionHeaderViewDelegate: AnyObject {
    /// 加号点击事件
    func mk_filterEditSectionHeaderView_addButtonPressed(index: Int)
    
    /// 减号点击事件
    func mk_filterEditSectionHeaderView_subButtonPressed(index: Int)
}

// MARK: - Header View
public class MKSwiftFilterEditSectionHeaderView: UITableViewHeaderFooterView {
    
    // MARK: - UI Components
    private lazy var msgLabel: UILabel = {
        let label = UILabel()
        label.textColor = MKColor.defaultText
        label.font = MKFont.font(14)
        label.textAlignment = .left
        return label
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(moduleIcon(name: "mk_swift_addIcon"), for: .normal)
        button.addTarget(self, action: #selector(addButtonPressed), for: .touchUpInside)
        return button
    }()
    
    private lazy var subButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(moduleIcon(name: "mk_swift_subIcon"), for: .normal)
        button.addTarget(self, action: #selector(subButtonPressed), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Properties
    public weak var delegate: MKSwiftFilterEditSectionHeaderViewDelegate?
    
    public var dataModel: MKSwiftFilterEditSectionHeaderViewModel? {
        didSet {
            updateUI()
        }
    }
    
    // MARK: - Initialization
    public override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Class Method
    public static func dequeueHeader(with tableView: UITableView) -> MKSwiftFilterEditSectionHeaderView {
        let identifier = String(describing: self)
        if let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: identifier) as? MKSwiftFilterEditSectionHeaderView {
            return header
        }
        return MKSwiftFilterEditSectionHeaderView(reuseIdentifier: identifier)
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        contentView.backgroundColor = MKColor.rgb(242, 242, 242)
        contentView.addSubview(msgLabel)
        contentView.addSubview(addButton)
        contentView.addSubview(subButton)
    }
    
    private func setupConstraints() {
        subButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-15)
            make.width.height.equalTo(30)
            make.centerY.equalToSuperview()
        }
        
        addButton.snp.makeConstraints { make in
            make.right.equalTo(subButton.snp.left).offset(-15)
            make.width.height.equalTo(30)
            make.centerY.equalToSuperview()
        }
        
        msgLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.right.equalTo(addButton.snp.left).offset(-15)
            make.centerY.equalToSuperview()
            make.height.equalTo(MKFont.font(14).lineHeight)
        }
    }
    
    private func updateUI() {
        guard let dataModel = dataModel else {
            msgLabel.text = nil
            return
        }
        
        contentView.backgroundColor = dataModel.contentColor ?? MKColor.rgb(242, 242, 242)
        msgLabel.text = dataModel.msg
    }
    
    // MARK: - Button Actions
    @objc private func addButtonPressed() {
        guard let index = dataModel?.index else { return }
        delegate?.mk_filterEditSectionHeaderView_addButtonPressed(index: index)
    }
    
    @objc private func subButtonPressed() {
        guard let index = dataModel?.index else { return }
        delegate?.mk_filterEditSectionHeaderView_subButtonPressed(index: index)
    }
}
