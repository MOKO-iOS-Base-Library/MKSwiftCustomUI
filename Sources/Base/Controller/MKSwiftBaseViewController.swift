//
//  MKSwiftBaseViewController.swift
//  MKBaseSwiftModule_Example
//
//  Created by aa on 2024/2/29.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit

import MKBaseSwiftModule

open class MKSwiftBaseViewController: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: - Properties
    
    open var isPresented: Bool = false
    open var defaultTitle: String? {
        didSet {
            titleLabel.text = self.title ?? defaultTitle
        }
    }
    
    open var custom_naviBarColor: UIColor? = MKColor.navBar {
        didSet {
            updateNavigationBarAppearance()
        }
    }
    
    open var isRootViewController: Bool {
        return navigationController?.viewControllers.first == self
    }
    
    // MARK: - UI Components
    
    open private(set) lazy var titleLabel: UILabel = {
        let label = UILabel(frame: CGRect(
            x: 60.0,
            y: 7.0,
            width: MKScreen.width - 120.0,
            height: 30.0
        ))
        label.font = MKFont.font(20.0)
        label.textColor = .white
        label.textAlignment = .center
        label.backgroundColor = .clear
        return label
    }()
    
    open private(set) lazy var leftButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0.0, y: 2.0, width: 40.0, height: 40.0))
        button.setImage(moduleIcon(name: "mk_swift_back_button_white"), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(UIColor.white.withAlphaComponent(0.4), for: .highlighted)
        button.contentHorizontalAlignment = .left
        button.titleLabel?.font = MKFont.font(16.0)
        button.addTarget(self, action: #selector(leftButtonMethod), for: .touchUpInside)
        return button
    }()
    
    open private(set) lazy var rightButton: UIButton = {
        let button = UIButton(frame: CGRect(
            x: UIScreen.main.bounds.width - 40.0,
            y: 2.0,
            width: 40.0,
            height: 40.0
        ))
        button.titleLabel?.font = MKFont.font(16.0)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(UIColor.white.withAlphaComponent(0.4), for: .highlighted)
        button.addTarget(self, action: #selector(rightButtonMethod), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        
        // 检查当前控制器是否已从导航栈中移除
        if !(navigationController?.viewControllers.contains(self) ?? false) {
            // 调用专门的回调方法
            viewDidPopFromNavigationStack()
        }
    }
    
    /// 当控制器从导航栈中弹出销毁时的回调方法，子类可以重写此方法
    open func viewDidPopFromNavigationStack() {
        // 默认空实现，子类可以重写
        // 这里可以执行清理操作，如取消网络请求、释放资源等
    }
    
    // MARK: - Actions
    
    @objc open func leftButtonMethod() {
        if isPresented {
            dismiss(animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc open func rightButtonMethod() {
        // Subclasses should override
    }
    
    // MARK: - Public Methods
    
    open func setNavigationBarImage(_ image: UIImage) {
        edgesForExtendedLayout = []
        let resizedImage = image.resizableImage(withCapInsets: UIEdgeInsets(top: 2, left: 1, bottom: 2, right: 1))
        navigationController?.navigationBar.setBackgroundImage(resizedImage, for: .default)
    }
    
    open class func isCurrentViewControllerVisible(_ viewController: UIViewController) -> Bool {
        return viewController.isViewLoaded && viewController.view.window != nil
    }
    
    open func popToViewController(withClassName className: String) {
        guard let navController = navigationController else { return }
        
        if let targetVC = navController.viewControllers.first(where: { String(describing: type(of: $0)) == className }) {
            navController.popToViewController(targetVC, animated: true)
        } else {
            navController.popToRootViewController(animated: true)
        }
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return !isRootViewController
    }
    
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer is UIScreenEdgePanGestureRecognizer
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        setupNavigationItems()
    }
    
    private func setupNavigationItems() {
        // Left Button
        let leftBarButtonItem = UIBarButtonItem(customView: leftButton)
        navigationItem.leftBarButtonItem = leftBarButtonItem
        
        // Right Button
        let rightBarButtonItem = UIBarButtonItem(customView: rightButton)
        navigationItem.rightBarButtonItem = rightBarButtonItem
        
        // Title View
        navigationItem.titleView = titleLabel
    }
    
    private func setupNavigationBar() {
        updateNavigationBarAppearance()
    }
    
    private func updateNavigationBarAppearance() {
        guard let navBar = navigationController?.navigationBar else { return }
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = custom_naviBarColor
        
        // Set title color based on background darkness
        let isDarkColor = custom_naviBarColor?.isDark ?? true
        let textColor: UIColor = isDarkColor ? .white : .black
        
        appearance.titleTextAttributes = [.foregroundColor: textColor]
        navBar.tintColor = textColor
        
        navBar.standardAppearance = appearance
        navBar.scrollEdgeAppearance = appearance
        navBar.compactAppearance = appearance
        
        setNeedsStatusBarAppearanceUpdate()
    }
}
