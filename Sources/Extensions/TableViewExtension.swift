//
//  File.swift
//  MKBaseSwiftModule
//
//  Created by aa on 2025/5/30.
//

import UIKit

import MKBaseSwiftModule

public extension UITableView {
    /// Perform batch updates with a closure
    func mk_update(with block: (UITableView) -> Void) {
        beginUpdates()
        block(self)
        endUpdates()
    }
    
    /// Scroll to specific row
    func mk_scrollToRow(_ row: Int, inSection section: Int, at position: UITableView.ScrollPosition, animated: Bool) {
        let indexPath = IndexPath(row: row, section: section)
        scrollToRow(at: indexPath, at: position, animated: animated)
    }
    
    // MARK: - Row Operations
    
    func mk_insertRow(_ row: Int, inSection section: Int, with animation: UITableView.RowAnimation) {
        let indexPath = IndexPath(row: row, section: section)
        insertRows(at: [indexPath], with: animation)
    }
    
    func mk_reloadRow(_ row: Int, inSection section: Int, with animation: UITableView.RowAnimation) {
        let indexPath = IndexPath(row: row, section: section)
        reloadRows(at: [indexPath], with: animation)
    }
    
    func mk_deleteRow(_ row: Int, inSection section: Int, with animation: UITableView.RowAnimation) {
        let indexPath = IndexPath(row: row, section: section)
        deleteRows(at: [indexPath], with: animation)
    }
    
    func mk_insertRow(at indexPath: IndexPath, with animation: UITableView.RowAnimation) {
        insertRows(at: [indexPath], with: animation)
    }
    
    func mk_reloadRow(at indexPath: IndexPath, with animation: UITableView.RowAnimation) {
        reloadRows(at: [indexPath], with: animation)
    }
    
    func mk_deleteRow(at indexPath: IndexPath, with animation: UITableView.RowAnimation) {
        deleteRows(at: [indexPath], with: animation)
    }
    
    // MARK: - Section Operations
    
    func mk_insertSection(_ section: Int, with animation: UITableView.RowAnimation) {
        insertSections(IndexSet(integer: section), with: animation)
    }
    
    func mk_deleteSection(_ section: Int, with animation: UITableView.RowAnimation) {
        deleteSections(IndexSet(integer: section), with: animation)
    }
    
    func mk_reloadSection(_ section: Int, with animation: UITableView.RowAnimation) {
        reloadSections(IndexSet(integer: section), with: animation)
    }
    
    /// Clear all selected rows
    func mk_clearSelectedRows(animated: Bool) {
        indexPathsForSelectedRows?.forEach {
            deselectRow(at: $0, animated: animated)
        }
    }
}
