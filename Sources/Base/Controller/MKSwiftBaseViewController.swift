//
//  MKSwiftBaseViewController.swift
//  MKBaseSwiftModule_Example
//
//  Created by aa on 2024/2/29.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit

import MKBaseSwiftModule

/// 基类控制器：使用自定义导航栏（对齐 OC `MKBaseViewController`），规避 iOS 15+ 系统导航栏按钮白色圆环。
open class MKSwiftBaseViewController: UIViewController, UIGestureRecognizerDelegate {

    // MARK: - Properties

    open var isPresented: Bool = false

    open var defaultTitle: String? {
        didSet { updateTitle() }
    }

    open var custom_naviBarColor: UIColor? = MKColor.navBar {
        didSet {
            customNavBar.barBackgroundColor = custom_naviBarColor
            updateStatusBarStyleIfNeeded()
        }
    }

    open var isRootViewController: Bool {
        navigationController?.viewControllers.first == self
    }

    open override var title: String? {
        didSet { updateTitle() }
    }

    private let customNavBar = MKSwiftCustomNavigationBar.make()

    /// 子类沿用原有 API，实际按钮在自定义导航栏上。
    open var leftButton: UIButton { customNavBar.leftButton }
    open var rightButton: UIButton { customNavBar.rightButton }
    open var titleLabel: UILabel { customNavBar.titleLabel }

    // MARK: - Lifecycle

    open override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCustomNavigationBar()
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        view.bringSubviewToFront(customNavBar)
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let statusTop = view.safeAreaInsets.top > 0 ? view.safeAreaInsets.top : MKLayout.statusBarHeight
        let barHeight = statusTop + MKLayout.navigationBarHeight
        customNavBar.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: barHeight)
    }

    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.interactivePopGestureRecognizer?.delegate = nil

        if !(navigationController?.viewControllers.contains(self) ?? false) {
            viewDidPopFromNavigationStack()
        }
    }

    /// 当控制器从导航栈中弹出销毁时的回调方法，子类可以重写此方法
    open func viewDidPopFromNavigationStack() {
        // 默认空实现，子类可以重写
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
        let resizedImage = image.resizableImage(withCapInsets: UIEdgeInsets(top: 2, left: 1, bottom: 2, right: 1))
        customNavBar.barBackgroundImage = resizedImage
        updateStatusBarStyleIfNeeded()
    }

    open func setNavTitleFont(_ font: UIFont) {
        customNavBar.titleLabelFont = font
    }

    open func setNavTitleColor(_ color: UIColor) {
        customNavBar.titleLabelColor = color
    }

    open class func isCurrentViewControllerVisible(_ viewController: UIViewController) -> Bool {
        viewController.isViewLoaded && viewController.view.window != nil
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
        !isRootViewController
    }

    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }

    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        gestureRecognizer is UIScreenEdgePanGestureRecognizer
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .systemBackground
    }

    private func setupCustomNavigationBar() {
        customNavBar.barBackgroundColor = custom_naviBarColor
        customNavBar.titleLabelColor = .white
        customNavBar.titleLabelFont = MKFont.font(18)
        updateTitle()

        if let backImage = moduleIcon(name: "mk_swift_back_button_white") {
            leftButton.setImage(backImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        leftButton.contentHorizontalAlignment = .left
        leftButton.titleLabel?.font = MKFont.font(16)
        leftButton.isHidden = false
        leftButton.addTarget(self, action: #selector(leftButtonMethod), for: .touchUpInside)

        rightButton.titleLabel?.font = MKFont.font(16)
        rightButton.addTarget(self, action: #selector(rightButtonMethod), for: .touchUpInside)

        view.addSubview(customNavBar)
        updateStatusBarStyleIfNeeded()
    }

    private func updateTitle() {
        let text = title ?? defaultTitle
        customNavBar.title = text
    }

    private func updateStatusBarStyleIfNeeded() {
        setNeedsStatusBarAppearanceUpdate()
    }

    open override var preferredStatusBarStyle: UIStatusBarStyle {
        let background = custom_naviBarColor ?? MKColor.navBar
        return (background.isDark) ? .lightContent : .darkContent
    }
}
