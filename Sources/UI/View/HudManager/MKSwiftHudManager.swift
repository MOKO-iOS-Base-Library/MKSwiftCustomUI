//
//  File.swift
//  MKBaseSwiftModule
//
//  Created by aa on 2025/6/6.
//

import UIKit

import MKBaseSwiftModule

@MainActor public final class MKSwiftHudManager {
    
    // MARK: - Shared Instance
    
    public static let shared = MKSwiftHudManager()
    private init() {}
    
    // MARK: - Properties
    
    private weak var inView: UIView?
    private var progressHUD: MKSwiftProgressHUD?
    
    // MARK: - Public Methods
    
    public func showHUD(with title: String, in view: UIView?, isPenetration: Bool) {
        // Remove existing HUD if present
        progressHUD?.hide(animated: false)
        progressHUD?.removeFromSuperview()
        progressHUD = nil
        
        inView = view
        let baseView = view ?? MKApp.window
        
        guard let baseView = baseView else { return }
        
        let hud = MKSwiftProgressHUD(view: baseView)
        hud.isUserInteractionEnabled = !isPenetration
        hud.removeFromSuperViewOnHide = true
        hud.bezelView.layer.cornerRadius = 5.0
        hud.bezelView.color = UIColor(white: 0.0, alpha: 0.75)
        hud.label.text = title
        
        if let inView = inView {
            inView.addSubview(hud)
        } else {
            MKApp.window?.addSubview(hud)
        }
        
        progressHUD = hud
        hud.show(animated: true)
    }
    
    public func hide() {
        inView?.isUserInteractionEnabled = true
        progressHUD?.hide(animated: true)
        progressHUD = nil
    }
    
    // MARK: - Non-isolated methods for background queue access
    
    public nonisolated func showHUDAsync(with title: String, in view: UIView?, isPenetration: Bool) {
        Task { @MainActor in
            self.showHUD(with: title, in: view, isPenetration: isPenetration)
        }
    }
    
    public nonisolated func hideAsync() {
        Task { @MainActor in
            self.hide()
        }
    }
}
