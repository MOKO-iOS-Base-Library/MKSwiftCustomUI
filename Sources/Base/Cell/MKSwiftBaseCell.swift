//
//  MKSwiftBaseCell.swift
//  MKBaseSwiftModule_Example
//
//  Created by aa on 2024/2/29.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import SnapKit
import UIKit

import MKBaseSwiftModule

/// 可继承的基础 UITableViewCell 类
open class MKSwiftBaseCell: UITableViewCell {
    
    // MARK: - 公开属性
    
    /// 当前 cell 的 indexPath（可选）
    open var indexPath: IndexPath?
    
    // MARK: - 初始化方法
    
    /// 主要初始化方法
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 生命周期
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        layoutLineView()
    }
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        // 重置 cell 状态
        indexPath = nil
    }
    
    // MARK: - 公开方法
    
    /// 配置单元格方法（子类可重写）
    open func configure(with data: Any?) {
        // 基础实现为空，子类重写
    }
    
    // MARK: - 私有属性和方法
    
    private lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = MKLine.color
        return view
    }()
    
    private func commonInit() {
        selectionStyle = .none
        contentView.backgroundColor = .white
        contentView.addSubview(lineView)
    }
    
    private func layoutLineView() {
        lineView.snp.remakeConstraints { make in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.bottom.equalToSuperview()
            make.height.equalTo(MKLine.height)
        }
    }
}
