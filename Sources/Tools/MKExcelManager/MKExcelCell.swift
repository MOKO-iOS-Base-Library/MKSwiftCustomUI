//
//  MKExcelCell.swift
//  MKBaseSwiftModule
//
//  Created by aa on 2025/7/6.
//

import Foundation

public class MKExcelCell {
    public var cellDic: [String: Any]? {
        get { return _cellDic }
        set {
            // 1. 先清空旧值
            _cellDic = nil
            
            // 2. 设置新值
            _cellDic = newValue
            
            // 3. 验证并刷新数据
            guard let dic = _cellDic, !dic.isEmpty else { return }
            refreshData()
        }
    }
    
    public private(set) var stringValueIndex: Int = 0
    public var stringValue: String? {
        get {
            return _stringValue
        }
        set {
            if indexAnalysisSuccess {
                _stringValue = newValue
            }
        }
    }
    public private(set) var column: String?
    public private(set) var row: Int = 0
    public private(set) var indexAnalysisSuccess: Bool = false
    private var _stringValue: String?
    private var _cellDic: [String: Any]?
    
    // Merged cell properties
    public var mergeCellColumAndRowStr: String?
    public var cellIsMerge: Bool = false
    public var mergeColumn: String?
    public var mergeRow: Int = 0
    
    public init() {}
    
    private func refreshData() {
        guard let cellDic = cellDic,
              let v = cellDic["v"] as? [String: Any] else { return }
        
        // Parse index
        if let text = v["text"] as? String, let index = Int(text) {
            stringValueIndex = index
            indexAnalysisSuccess = true
        }
        
        if let r = cellDic["r"] as? String {
            let rowStr = MKExcelCell.getNumber(from: r)
            row = Int(rowStr) ?? 0
            
            let columnStr = MKExcelCell.getLetter(from: r)
            column = columnStr
        }
    }
    
    public static func getNumber(from str: String) -> String {
        let nonDigitCharacterSet = CharacterSet.decimalDigits.inverted
        return str.components(separatedBy: nonDigitCharacterSet).joined()
    }
    
    public static func getLetter(from str: String) -> String {
        let numStr = getNumber(from: str)
        let letterStr = str.substring(from: 0, length: str.count - numStr.count)
        return letterStr
    }
}
