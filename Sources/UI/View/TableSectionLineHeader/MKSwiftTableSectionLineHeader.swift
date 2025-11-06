//
//  MKSwiftTableSectionHeaderView.swift
//  MKBaseSwiftModule
//
//  Created by aa on 2024/4/24.
//

import UIKit
import SnapKit

import MKBaseSwiftModule

// MARK: - Data Model
public class MKSwiftTableSectionLineHeaderModel {
    public var contentColor: UIColor?
    public var msgTextFont: UIFont = MKFont.font(15)
    public var msgTextColor: UIColor = MKColor.defaultText
    public var text: String?
    
    public init() {}
}

// MARK: - Header View
public class MKSwiftTableSectionLineHeader: UITableViewHeaderFooterView {
    
    // MARK: - Public Class Method
    public static func dequeueHeader(with tableView: UITableView) -> MKSwiftTableSectionLineHeader {
        let identifier = String(describing: self)
        if let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: identifier) as? MKSwiftTableSectionLineHeader {
            return header
        }
        return MKSwiftTableSectionLineHeader(reuseIdentifier: identifier)
    }
    
    // MARK: - Properties
    public var headerModel: MKSwiftTableSectionLineHeaderModel? {
        didSet {
            updateUI()
        }
    }
    
    // MARK: - Initialization
    public override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = MKColor.rgb(242, 242, 242)
        contentView.addSubview(msgLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        // 计算文本高度并更新约束
        let maxWidth = UIScreen.main.bounds.width - 30
        let size = headerModel?.text?.boundingRect(
            with: CGSize(width: maxWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: headerModel?.msgTextFont as Any],
            context: nil
        ).size
        
        msgLabel.snp.remakeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalToSuperview()
            make.height.equalTo(ceil(size?.height ?? 0))
        }
    }
    
    // MARK: - Private Methods
    
    private func updateUI() {
        guard let headerModel = headerModel else {
            msgLabel.text = nil
            return
        }
        
        contentView.backgroundColor = headerModel.contentColor ?? MKColor.rgb(242, 242, 242)
        
        if let text = headerModel.text, !text.isEmpty {
            msgLabel.text = text
            msgLabel.textColor = headerModel.msgTextColor
            msgLabel.font = headerModel.msgTextFont
        }
        setNeedsLayout()
    }
    
    // MARK: - UI Components
    private lazy var msgLabel: UILabel = {
        let label = UILabel()
        label.textColor = MKColor.defaultText
        label.font = MKFont.font(15)
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
}
