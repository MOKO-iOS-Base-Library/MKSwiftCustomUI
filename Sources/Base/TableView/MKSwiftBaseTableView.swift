//
//  MKSwiftBaseTableView.swift
//  MKBaseSwiftModule
//
//  Created by aa on 2024/3/6.
//

import UIKit

open class MKSwiftBaseTableView:UITableView {
    public override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style);
        if #available(iOS 15.0, tvOS 15, *) {
            self.sectionHeaderTopPadding = 0;
        }
        self.separatorStyle = .none;
        self.contentInsetAdjustmentBehavior = .never;
        self.backgroundColor = .white;
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
