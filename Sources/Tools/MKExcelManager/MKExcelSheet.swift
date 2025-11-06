//
//  MKExcelSheet.swift
//  MKBaseSwiftModule
//
//  Created by aa on 2025/7/6.
//

import Foundation

import MKBaseSwiftModule

public class MKExcelSheet {
    public var sheetId: Int = 0
    public var sheetName: String = ""
    public var cellArray: [MKExcelCell] = []
    
    public init() {}
    
    /// Get cell by column and row
    /// - Parameters:
    ///   - column: Column identifier (e.g., "A", "H")
    ///   - row: Row number (e.g., 1, 15)
    /// - Returns: The found cell or nil
    public func getCell(column: String, row: Int) -> MKExcelCell? {
        return cellArray.first { $0.column == column && $0.row == row }
    }
    
    /// Parse sheet data
    /// - Parameters:
    ///   - sheetDic: Sheet dictionary data
    ///   - sharedStringsArray: Shared strings array
    /// - Returns: Array of all cells in the sheet
    public static func analysisSheetData(sheetDic: [String: Any], sharedStringsArray: [String]) -> [MKExcelCell] {
        return getCellArray(sheetDic: sheetDic, sharedStringsArray: sharedStringsArray) ?? []
    }
    
    private static func getCellArray(sheetDic: [String: Any], sharedStringsArray: [String]) -> [MKExcelCell]? {
        guard !sharedStringsArray.isEmpty else { return nil }
        
        var oneSheetAllCellArray: [MKExcelCell]? = nil
        
        if let oneSheetData = sheetDic["oneSheetData"] as? [String: Any],
           let worksheet = oneSheetData["worksheet"] as? [String: Any] {
            
            var mergeCellInfoArray: [Any]? = nil
            
            if let mergeCells = worksheet["mergeCells"] as? [String: Any] {
                mergeCellInfoArray = mergeCells["mergeCell"] as? [Any]
            }
            
            if let sheetData = worksheet["sheetData"] as? [String: Any],
               let rows = sheetData["row"] as? [Any] {
                
                for rowItem in rows {
                    if oneSheetAllCellArray == nil {
                        oneSheetAllCellArray = []
                    }
                    
                    guard let oneRowDic = rowItem as? [String: Any] else { continue }
                    
                    if let c = oneRowDic["c"] {
                        if let cellDict = c as? [String: Any] {
                            // Single column case
                            handleCellData(cellDict: cellDict,
                                         sharedStringsArray: sharedStringsArray,
                                         mergeCellInfoArray: mergeCellInfoArray,
                                         cellArray: &oneSheetAllCellArray!)
                        } else if let cellArray = c as? [[String: Any]] {
                            // Multiple columns case
                            for cellDict in cellArray {
                                handleCellData(cellDict: cellDict,
                                             sharedStringsArray: sharedStringsArray,
                                             mergeCellInfoArray: mergeCellInfoArray,
                                             cellArray: &oneSheetAllCellArray!)
                            }
                        }
                    }
                }
            }
        }
        
        return oneSheetAllCellArray
    }
    
    private static func handleCellData(cellDict: [String: Any],
                                     sharedStringsArray: [String],
                                     mergeCellInfoArray: [Any]?,
                                     cellArray: inout [MKExcelCell]) {
        let cell = MKExcelCell()
        cell.cellDic = cellDict
        
        if cell.indexAnalysisSuccess, sharedStringsArray.count > cell.stringValueIndex {
            cell.stringValue = sharedStringsArray[cell.stringValueIndex]
        }
        
        let mergeCellColumAndRowStr = getMergeCellColumAndRowStr(cell: cell,
                                                                mergeCellInfoArray: mergeCellInfoArray)
        cell.mergeCellColumAndRowStr = mergeCellColumAndRowStr
        
        cellArray.append(cell)
    }
    
    private static func getMergeCellColumAndRowStr(cell: MKExcelCell, mergeCellInfoArray: Any?) -> String {
        guard let mergeCellInfoArray = mergeCellInfoArray else {
            return ""
        }
        if MKValid.isDictValid(mergeCellInfoArray) {
            return getMergeStr(mergeInfoDic: (mergeCellInfoArray as! [String:Any]), column: cell.column!, row: cell.row)
        }
        
        if !MKValid.isArrayValid(mergeCellInfoArray) {
            return ""
        }
        if let list = mergeCellInfoArray as? [Any] {
            for item in list {
                if let mergeInfoDic = item as? [String: Any] {
                    let value = getMergeStr(mergeInfoDic: mergeInfoDic, column: cell.column!, row: cell.row)
                    if !value.isEmpty {
                        return value
                    }
                }
            }
        }
        
        
        return ""
    }
    
    private static func getMergeStr(mergeInfoDic: [String: Any], column: String, row: Int) -> String {
        guard !mergeInfoDic.isEmpty else { return "" }
        
        guard let ref = mergeInfoDic["ref"] as? String, !ref.isEmpty else { return "" }
        
        let array = ref.components(separatedBy: ":")
        guard array.count == 2 else { return "" }
        
        let startStr = array[0]
        let endStr = array[1]
        
        guard let startRow = Int(MKExcelCell.getNumber(from: startStr)),
              let endRow = Int(MKExcelCell.getNumber(from: endStr)) else { return "" }
        
        let tempStartColumnStr = MKExcelCell.getLetter(from: startStr)
        let tempEndColumnStr = MKExcelCell.getLetter(from: endStr)
        
        if tempStartColumnStr == tempEndColumnStr {
            // Vertical merge
            if startRow <= row && endRow >= row {
                return startStr
            }
        } else {
            // Horizontal merge
            if startRow == row {
                if tempStartColumnStr <= column && tempEndColumnStr >= column {
                    return startStr
                }
            }
        }
        
        return ""
    }
}
