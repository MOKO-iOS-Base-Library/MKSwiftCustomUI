//
//  MKExcelWorkbook.swift
//  MKBaseSwiftModule
//
//  Created by aa on 2025/7/6.
//

import Foundation
import libxlsxwriter
import ZIPFoundation

public class MKExcelWorkbook {
    // MARK: - Properties
    public var workbookName: String = ""
    public var sheetArray: [MKExcelSheet] = []
    
    private var originFileFolderPath: String = ""
    private var originFileName: String = ""
    
    // MARK: - Initialization
    
    public init(excelFilePathUrl: URL) throws {
        let analysisSuccess = analysisPathAndFileName(with: excelFilePathUrl.path)
        
        // Get original file data
        let data = try getOriginFileData(with: excelFilePathUrl)
        
        if analysisSuccess && !data.isEmpty {
            // Create temp folder
            let tempFolderPath = try getTempFolderPath(with: originFileFolderPath)
            
            let tempZipPath = tempFolderPath.appending("/MYCExcelWorkbookTemp.zip")
            
            try writeOriginFileTempZip(with: data, path: tempZipPath)
            
            // Unzip using ZIPFoundation
            let sourceURL = URL(fileURLWithPath: tempZipPath)
            let destinationURL = URL(fileURLWithPath: tempFolderPath)
            try FileManager.default.unzipItem(at: sourceURL, to: destinationURL)
            
            // Delete temp zip
            try deleteOriginTempZIP(with: tempZipPath)
            
            // Get shared strings
            let sharedStringsDic = try getSharedStrings(with: tempFolderPath)
            let stringValueArray = getSharedStringsValue(with: sharedStringsDic)
            
            // Get sheet dictionaries
            let sheetDictionaries = try getSheetXmlDicArray(with: tempFolderPath)
            
            var sheets: [MKExcelSheet] = []
            
            for sheetDic in sheetDictionaries {
                let sheet = MKExcelSheet()
                sheet.sheetId = sheetDic["sheetId"] as? Int ?? 0
                sheet.cellArray = MKExcelSheet.analysisSheetData(
                    sheetDic: sheetDic,
                    sharedStringsArray: stringValueArray
                )
                sheet.sheetName = try getSheetName(with: sheet.sheetId, path: tempFolderPath)
                sheets.append(sheet)
            }
            
            if !sheets.isEmpty {
                self.sheetArray = sheets
            }
            
            // Clean up
            try clearTempFile(with: tempFolderPath)
        }
    }
    
    // MARK: - Public Methods
    
    public func getSheet(with sheetName: String) -> MKExcelSheet? {
        return sheetArray.first { $0.sheetName == sheetName }
    }
    
    // MARK: - Private Methods
    
    private func analysisPathAndFileName(with path: String) -> Bool {
        self.workbookName = URL(fileURLWithPath: path).deletingPathExtension().lastPathComponent
        self.originFileFolderPath = URL(fileURLWithPath: path).deletingLastPathComponent().path
        
        let fileSuffix = URL(fileURLWithPath: path).pathExtension
        
        return !workbookName.isEmpty && !originFileFolderPath.isEmpty && fileSuffix == "xlsx"
    }
    
    private func getOriginFileData(with url: URL) throws -> Data {
        return try Data(contentsOf: url)
    }
    
    private func getTempFolderPath(with originFolderPath: String) throws -> String {
        let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
        let tempFolderPath = documentPath.appending("/MYCExcelAnalysisTemp")
        
        if !FileManager.default.fileExists(atPath: tempFolderPath) {
            try FileManager.default.createDirectory(
                atPath: tempFolderPath,
                withIntermediateDirectories: true,
                attributes: nil
            )
        }
        
        return tempFolderPath
    }
    
    private func writeOriginFileTempZip(with data: Data, path: String) throws {
        try data.write(to: URL(fileURLWithPath: path), options: .atomic)
    }
    
    private func deleteOriginTempZIP(with path: String) throws {
        try FileManager.default.removeItem(atPath: path)
    }
    
    private func getSharedStrings(with path: String) throws -> [String: Any] {
        let sharedStringsXmlPath = path.appending("/xl/sharedStrings.xml")
        let xmlData = try Data(contentsOf: URL(fileURLWithPath: sharedStringsXmlPath))
        
        return try MKXMLReader.dictionary(forXMLData: xmlData)
    }
    
    private func getSharedStringsValue(with sharedStringsDic: [String: Any]) -> [String] {
        var valueArray: [String] = []
        
        guard let sst = sharedStringsDic["sst"] as? [String: Any],
              let si = sst["si"] as? [[String: Any]] else {
            return valueArray
        }
        
        for oneStringValueDic in si {
            if let t = oneStringValueDic["t"] as? [String: Any],
               var oneStringValue = t["text"] as? String {
                oneStringValue = oneStringValue.replacingOccurrences(of: "\n", with: "")
                valueArray.append(oneStringValue)
            }
        }
        
        return valueArray
    }
    
    private func getSheetXmlDicArray(with path: String) throws -> [[String: Any]] {
        var xmlDicArray: [[String: Any]] = []
        let sheetsFolderPath = path.appending("/xl/worksheets/")
        
        let contents = try FileManager.default.contentsOfDirectory(atPath: sheetsFolderPath)
        
        for fileName in contents where fileName.hasSuffix(".xml") {
            let xmlPath = sheetsFolderPath.appending("/\(fileName)")
            let xmlData = try Data(contentsOf: URL(fileURLWithPath: xmlPath))
            
            let sheetId = Int(MKExcelCell.getNumber(from: fileName)) ?? 0
            let xmlDic = try MKXMLReader.dictionary(forXMLData: xmlData)
            
            let sheetDic: [String: Any] = [
                "sheetId": sheetId,
                "oneSheetData": xmlDic
            ]
            
            xmlDicArray.append(sheetDic)
        }
        
        return xmlDicArray
    }
    
    private func getSheetName(with sheetId: Int, path: String) throws -> String {
        let infoArray = try getSheetNameInfoArray(with: path)
        
        if let array = infoArray as? [[String: Any]] {
            for dic in array {
                if let oldSheetId = dic["sheetId"] as? Int,
                   oldSheetId == sheetId,
                   let name = dic["name"] as? String {
                    return name
                }
            }
        } else if let dic = infoArray as? [String: Any],
                  let oldSheetId = dic["sheetId"] as? Int,
                  oldSheetId == sheetId,
                  let name = dic["name"] as? String {
            return name
        }
        
        return ""
    }
    
    private func getSheetNameInfoArray(with path: String) throws -> Any {
        let workbookXmlPath = path.appending("/xl/workbook.xml")
        let xmlData = try Data(contentsOf: URL(fileURLWithPath: workbookXmlPath))
        let sheetNameInfoDic = try MKXMLReader.dictionary(forXMLData: xmlData)
        
        guard let workbook = sheetNameInfoDic["workbook"] as? [String: Any],
              let sheets = workbook["sheets"] as? [String: Any] else {
            return []
        }
        
        return sheets["sheet"] ?? []
    }
    
    private func clearTempFile(with path: String) throws {
        let pathsToRemove = [
            path.appending("/_rels"),
            path.appending("/[Content_Types].xml"),
            path.appending("/docProps"),
            path.appending("/xl"),
            path
        ]
        
        for pathToRemove in pathsToRemove {
            try? FileManager.default.removeItem(atPath: pathToRemove)
        }
    }
}
