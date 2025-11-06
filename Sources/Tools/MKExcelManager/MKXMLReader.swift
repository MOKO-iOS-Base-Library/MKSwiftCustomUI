//
//  MKXMLReader.swift
//  MKBaseSwiftModule
//
//  Created by aa on 2025/7/6.
//

import Foundation

public struct XMLReaderOptions: OptionSet, Sendable {
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let processNamespaces: XMLReaderOptions = XMLReaderOptions(rawValue: 1 << 0)
    public static let reportNamespacePrefixes: XMLReaderOptions = XMLReaderOptions(rawValue: 1 << 1)
    public static let resolveExternalEntities: XMLReaderOptions = XMLReaderOptions(rawValue: 1 << 2)
}

public class MKXMLReader: NSObject {
    // MARK: - Constants
    private let textNodeKey = "text"
    private let attributePrefix = "@"
    
    // MARK: - Properties
    private var dictionaryStack: [NSMutableDictionary] = []
    private var textInProgress = NSMutableString()
    private var errorPointer: NSError?
    
    // MARK: - Public Methods
    
    public static func dictionary(forXMLData data: Data) throws -> [String: Any] {
        let reader = MKXMLReader()
        return try reader.object(with: data, options: [])
    }
    
    public static func dictionary(forXMLString string: String) throws -> [String: Any] {
        guard let data = string.data(using: .utf8) else {
            throw NSError(domain: "MKXMLReaderError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert string to data"])
        }
        return try dictionary(forXMLData: data)
    }
    
    public static func dictionary(forXMLData data: Data, options: XMLReaderOptions) throws -> [String: Any] {
        let reader = MKXMLReader()
        return try reader.object(with: data, options: options)
    }
    
    public static func dictionary(forXMLString string: String, options: XMLReaderOptions) throws -> [String: Any] {
        guard let data = string.data(using: .utf8) else {
            throw NSError(domain: "MKXMLReaderError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert string to data"])
        }
        return try dictionary(forXMLData: data, options: options)
    }
    
    // MARK: - Parsing
    
    private func object(with data: Data, options: XMLReaderOptions) throws -> [String: Any] {
        // Clear any old data
        dictionaryStack.removeAll()
        textInProgress = NSMutableString()
        
        // Initialize stack with fresh dictionary
        dictionaryStack.append(NSMutableDictionary())
        
        // Parse XML
        let parser = XMLParser(data: data)
        parser.shouldProcessNamespaces = options.contains(.processNamespaces)
        parser.shouldReportNamespacePrefixes = options.contains(.reportNamespacePrefixes)
        parser.shouldResolveExternalEntities = options.contains(.resolveExternalEntities)
        
        parser.delegate = self
        let success = parser.parse()
        
        // Return root dictionary on success
        if success, let resultDict = dictionaryStack.first as? [String: Any] {
            return resultDict
        }
        
        if let error = errorPointer {
            throw error
        } else {
            throw NSError(domain: "MKXMLReaderError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to parse XML"])
        }
    }
}

// MARK: - XMLParserDelegate
extension MKXMLReader: XMLParserDelegate {
    public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        // Get dictionary for current level in stack
        guard let parentDict = dictionaryStack.last else { return }
        
        // Create child dictionary for new element
        let childDict = NSMutableDictionary(dictionary: attributeDict)
        
        // If there's already an item for this key, create an array
        if let existingValue = parentDict[elementName] {
            var array: NSMutableArray
            if let existingArray = existingValue as? NSMutableArray {
                array = existingArray
            } else {
                array = NSMutableArray()
                array.add(existingValue)
                parentDict[elementName] = array
            }
            array.add(childDict)
        } else {
            // No existing value, update dictionary
            parentDict[elementName] = childDict
        }
        
        // Update stack
        dictionaryStack.append(childDict)
    }
    
    public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        // Update parent dict with text info
        guard let dictInProgress = dictionaryStack.last else { return }
        
        // Set text property
        if textInProgress.length > 0 {
            let trimmedString = textInProgress.trimmingCharacters(in: .whitespacesAndNewlines)
            dictInProgress[textNodeKey] = NSMutableString(string: trimmedString)
            
            // Reset text
            textInProgress = NSMutableString()
        }
        
        // Pop current dict
        dictionaryStack.removeLast()
    }
    
    public func parser(_ parser: XMLParser, foundCharacters string: String) {
        // Build text value
        textInProgress.append(string)
    }
    
    public func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        // Set error pointer to parser's error object
        errorPointer = parseError as NSError
    }
}
