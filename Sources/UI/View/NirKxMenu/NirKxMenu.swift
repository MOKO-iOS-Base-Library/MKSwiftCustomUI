//
//  File.swift
//  MKBaseSwiftModule
//
//  Created by aa on 2025/6/11.
//

import UIKit

import MKBaseSwiftModule

// MARK: - Public Interface

public struct KxMenuConfiguration: Sendable {
    public var arrowSize: CGFloat
    public var marginXSpacing: CGFloat
    public var marginYSpacing: CGFloat
    public var intervalSpacing: CGFloat
    public var menuCornerRadius: CGFloat
    public var maskToBackground: Bool
    public var shadowOfMenu: Bool
    public var hasSeperatorLine: Bool
    public var seperatorLineHasInsets: Bool
    public var textColor: NirColor
    public var menuBackgroundColor: NirColor
    
    public struct NirColor: Sendable {
        public var red: CGFloat
        public var green: CGFloat
        public var blue: CGFloat
        
        public static let defaultText = NirColor(red: 0, green: 0, blue: 0)
        public static let darkGray = NirColor(red: 0.2, green: 0.2, blue: 0.2)
        public static let white = NirColor(red: 1, green: 1, blue: 1)
        
        public init(red: CGFloat, green: CGFloat, blue: CGFloat) {
            self.red = red
            self.green = green
            self.blue = blue
        }
        
        var uiColor: UIColor {
            return UIColor(red: red, green: green, blue: blue, alpha: 1)
        }
    }
    
    public init(
        arrowSize: CGFloat = 12,
        marginXSpacing: CGFloat = 10,
        marginYSpacing: CGFloat = 10,
        intervalSpacing: CGFloat = 8,
        menuCornerRadius: CGFloat = 6,
        maskToBackground: Bool = true,
        shadowOfMenu: Bool = true,
        hasSeperatorLine: Bool = true,
        seperatorLineHasInsets: Bool = false,
        textColor: NirColor = .defaultText,
        menuBackgroundColor: NirColor = .white
    ) {
        self.arrowSize = arrowSize
        self.marginXSpacing = marginXSpacing
        self.marginYSpacing = marginYSpacing
        self.intervalSpacing = intervalSpacing
        self.menuCornerRadius = menuCornerRadius
        self.maskToBackground = maskToBackground
        self.shadowOfMenu = shadowOfMenu
        self.hasSeperatorLine = hasSeperatorLine
        self.seperatorLineHasInsets = seperatorLineHasInsets
        self.textColor = textColor
        self.menuBackgroundColor = menuBackgroundColor
    }
}

public class KxMenuItem {
    public let image: UIImage?
    public let title: String
    public weak var target: AnyObject?
    public let action: Selector?
    public var alignment: NSTextAlignment = .center
    
    public init(title: String, image: UIImage? = nil, target: AnyObject? = nil, action: Selector? = nil) {
        assert(!title.isEmpty || image != nil, "Either title or image must be set")
        self.title = title
        self.image = image
        self.target = target
        self.action = action
    }
    
    public convenience init(title: String, image: UIImage? = nil, action: @escaping () -> Void) {
        let handler = ClosureHandler(closure: action)
        self.init(title: title, image: image, target: handler, action: #selector(ClosureHandler.invoke))
        objc_setAssociatedObject(self, &actionKey, handler, .OBJC_ASSOCIATION_RETAIN)
    }
    
    public var isEnabled: Bool {
        return target != nil && action != nil
    }
    
    public func performAction() {
        guard let target = target, let action = action else { return }
        
        if target.responds(to: action) {
            target.performSelector(onMainThread: action, with: self, waitUntilDone: true)
        }
    }
}

private class ClosureHandler {
    let closure: () -> Void
    
    init(closure: @escaping () -> Void) {
        self.closure = closure
    }
    
    @objc func invoke() {
        closure()
    }
}

nonisolated(unsafe) private var actionKey: UInt8 = 0

public enum KxMenu {
    public static let tintColor: UIColor = MKColor.defaultText
    public static let titleFont: UIFont = MKFont.font(15)
    
    @MainActor public static func showMenu(
        in view: UIView,
        fromRect rect: CGRect,
        menuItems: [KxMenuItem],
        with configuration: KxMenuConfiguration = KxMenuConfiguration()
    ) {
        KxMenuController.shared.showMenu(in: view, fromRect: rect, menuItems: menuItems, with: configuration)
    }
    
    @MainActor public static func dismissMenu() {
        KxMenuController.shared.dismissMenu()
    }
}

// MARK: - Private Implementation

private class KxMenuController: @unchecked Sendable {
    @MainActor static let shared = KxMenuController()
    private var menuView: KxMenuView?
    private var orientationObserver: NSObjectProtocol?
    
    private init() {}
    
    deinit {
        stopObserving()
    }
    
    @MainActor func showMenu(in view: UIView, fromRect rect: CGRect, menuItems: [KxMenuItem], with configuration: KxMenuConfiguration) {
        assert(!menuItems.isEmpty, "Menu items must not be empty")
        
        menuView?.dismiss(animated: false)
        menuView = nil
        
        startObserving()
        
        menuView = KxMenuView(configuration: configuration)
        menuView?.show(in: view, from: rect, items: menuItems)
    }
    
    @MainActor func dismissMenu() {
        menuView?.dismiss(animated: true)
        menuView = nil
        stopObserving()
    }
    
    private func startObserving() {
        // iOS 16+ 使用新的方向通知
        if #available(iOS 16.0, *) {
            orientationObserver = NotificationCenter.default.addObserver(
                forName: UIDevice.orientationDidChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self else { return }
                Task { @MainActor in
                    self.dismissMenu()
                }
            }
        }
        // iOS 14-15
        else {
            orientationObserver = NotificationCenter.default.addObserver(
                forName: UIDevice.orientationDidChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self else { return }
                Task { @MainActor in
                    self.dismissMenu()
                }
            }
        }
    }
    
    private func stopObserving() {
        if let observer = orientationObserver {
            NotificationCenter.default.removeObserver(observer)
            orientationObserver = nil
        }
    }
}

private class KxMenuView: UIView {
    private enum ArrowDirection {
        case up, down, left, right, none
    }
    
    private let configuration: KxMenuConfiguration
    private var arrowDirection: ArrowDirection = .none
    private var arrowPosition: CGFloat = 0
    private var contentView: UIView!
    private var menuItems: [KxMenuItem] = []
    private weak var overlay: KxMenuOverlay?
    
    init(configuration: KxMenuConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
        backgroundColor = .clear
        isOpaque = true
        alpha = 0
        
        if configuration.shadowOfMenu {
            layer.shadowOpacity = 0.5
            layer.shadowOffset = CGSize(width: 2, height: 2)
            layer.shadowRadius = 2
            layer.shadowColor = UIColor.black.cgColor
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show(in view: UIView, from rect: CGRect, items: [KxMenuItem]) {
        menuItems = items
        contentView = makeContentView()
        addSubview(contentView)
        
        setupFrame(in: view, from: rect)
        
        let overlay = KxMenuOverlay(frame: view.bounds, maskSetting: configuration.maskToBackground, menuView: self)
        self.overlay = overlay
        overlay.addSubview(self)
        view.addSubview(overlay)
        
        contentView.isHidden = true
        let toFrame = frame
        frame = CGRect(origin: arrowPoint, size: CGSize(width: 1, height: 1))
        
        UIView.animate(withDuration: 0.2) {
            self.alpha = 1
            self.frame = toFrame
        } completion: { _ in
            self.contentView.isHidden = false
        }
    }
    
    func dismiss(animated: Bool) {
        guard let overlay = overlay else { return }
        
        if !animated {
            overlay.removeFromSuperview()
            self.removeFromSuperview()
            return
        }
        
        contentView.isHidden = true
        
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0
            overlay.alpha = 0
        }) { _ in
            overlay.removeFromSuperview()
            self.removeFromSuperview()
        }
    }
    
    private func setupFrame(in view: UIView, from fromRect: CGRect) {
        let contentSize = contentView.frame.size
        
        let outerWidth = view.bounds.width
        let outerHeight = view.bounds.height
        
        let rectX0 = fromRect.origin.x
        let rectX1 = fromRect.origin.x + fromRect.width
        let rectXM = fromRect.origin.x + fromRect.width * 0.5
        let rectY0 = fromRect.origin.y
        let rectY1 = fromRect.origin.y + fromRect.height
        let rectYM = fromRect.origin.y + fromRect.height * 0.5
        
        let widthPlusArrow = contentSize.width + configuration.arrowSize
        let heightPlusArrow = contentSize.height + configuration.arrowSize
        let widthHalf = contentSize.width * 0.5
        let heightHalf = contentSize.height * 0.5
        
        let kMargin: CGFloat = 5.0
        
        if heightPlusArrow < (outerHeight - rectY1) {
            arrowDirection = .up
            var point = CGPoint(x: rectXM - widthHalf, y: rectY1)
            
            if point.x < kMargin {
                point.x = kMargin
            }
            
            if (point.x + contentSize.width + kMargin) > outerWidth {
                point.x = outerWidth - contentSize.width - kMargin
            }
            
            arrowPosition = rectXM - point.x
            contentView.frame = CGRect(x: 0, y: configuration.arrowSize, width: contentSize.width, height: contentSize.height)
            
            self.frame = CGRect(
                x: point.x,
                y: point.y,
                width: contentSize.width,
                height: contentSize.height + configuration.arrowSize
            )
        } else if heightPlusArrow < rectY0 {
            arrowDirection = .down
            var point = CGPoint(x: rectXM - widthHalf, y: rectY0 - heightPlusArrow)
            
            if point.x < kMargin {
                point.x = kMargin
            }
            
            if (point.x + contentSize.width + kMargin) > outerWidth {
                point.x = outerWidth - contentSize.width - kMargin
            }
            
            arrowPosition = rectXM - point.x
            contentView.frame = CGRect(origin: .zero, size: contentSize)
            
            self.frame = CGRect(
                x: point.x,
                y: point.y,
                width: contentSize.width,
                height: contentSize.height + configuration.arrowSize
            )
        } else if widthPlusArrow < (outerWidth - rectX1) {
            arrowDirection = .left
            var point = CGPoint(x: rectX1, y: rectYM - heightHalf)
            
            if point.y < kMargin {
                point.y = kMargin
            }
            
            if (point.y + contentSize.height + kMargin) > outerHeight {
                point.y = outerHeight - contentSize.height - kMargin
            }
            
            arrowPosition = rectYM - point.y
            contentView.frame = CGRect(x: configuration.arrowSize, y: 0, width: contentSize.width, height: contentSize.height)
            
            self.frame = CGRect(
                x: point.x,
                y: point.y,
                width: contentSize.width + configuration.arrowSize,
                height: contentSize.height
            )
        } else if widthPlusArrow < rectX0 {
            arrowDirection = .right
            var point = CGPoint(x: rectX0 - widthPlusArrow, y: rectYM - heightHalf)
            
            if point.y < kMargin {
                point.y = kMargin
            }
            
            if (point.y + contentSize.height + 5) > outerHeight {
                point.y = outerHeight - contentSize.height - kMargin
            }
            
            arrowPosition = rectYM - point.y
            contentView.frame = CGRect(origin: .zero, size: contentSize)
            
            self.frame = CGRect(
                x: point.x,
                y: point.y,
                width: contentSize.width + configuration.arrowSize,
                height: contentSize.height
            )
        } else {
            arrowDirection = .none
            self.frame = CGRect(
                x: (outerWidth - contentSize.width) * 0.5,
                y: (outerHeight - contentSize.height) * 0.5,
                width: contentSize.width,
                height: contentSize.height
            )
        }
    }
    
    private var arrowPoint: CGPoint {
        switch arrowDirection {
        case .up:
            return CGPoint(x: frame.minX + arrowPosition, y: frame.minY)
        case .down:
            return CGPoint(x: frame.minX + arrowPosition, y: frame.maxY)
        case .left:
            return CGPoint(x: frame.minX, y: frame.minY + arrowPosition)
        case .right:
            return CGPoint(x: frame.maxX, y: frame.minY + arrowPosition)
        case .none:
            return center
        }
    }
    
    private func makeContentView() -> UIView {
        subviews.forEach { $0.removeFromSuperview() }
        
        guard !menuItems.isEmpty else { return UIView() }
        
        // 统一行高参数
        let kMinMenuItemHeight: CGFloat = 44.0
        let kMinMenuItemWidth: CGFloat = 120.0
        let kMarginX = configuration.marginXSpacing
        let kMarginY = configuration.marginYSpacing
        
        let titleFont = KxMenu.titleFont
        
        // 计算最大宽度
        var maxItemWidth: CGFloat = kMinMenuItemWidth
        var maxItemHeight: CGFloat = kMinMenuItemHeight
        
        // 第一遍计算：确定最大宽度
        for menuItem in menuItems {
            let titleSize = menuItem.title.size(withAttributes: [.font: titleFont])
            let imageWidth = menuItem.image?.size.width ?? 0
            
            let itemWidth: CGFloat
            if menuItem.image != nil {
                itemWidth = imageWidth + configuration.intervalSpacing + titleSize.width + kMarginX * 3
            } else {
                itemWidth = titleSize.width + kMarginX * 2
            }
            
            maxItemWidth = max(maxItemWidth, itemWidth)
            maxItemHeight = max(maxItemHeight, titleSize.height + kMarginY * 2)
        }
        
        // 创建内容视图
        let contentView = UIView()
        contentView.backgroundColor = .clear
        contentView.layer.cornerRadius = configuration.menuCornerRadius
        contentView.layer.masksToBounds = true
        
        var itemY: CGFloat = 0
        
        // 第二遍：布局所有菜单项（移除第一行的额外间距）
        for (index, menuItem) in menuItems.enumerated() {
            let itemFrame = CGRect(x: 0, y: itemY, width: maxItemWidth, height: maxItemHeight)
            let itemView = UIView(frame: itemFrame)
            itemView.backgroundColor = .clear
            
            // 添加按钮
            if menuItem.isEnabled {
                let button = UIButton(type: .custom)
                button.tag = index
                button.frame = itemView.bounds
                button.addTarget(self, action: #selector(performAction(_:)), for: .touchUpInside)
                itemView.addSubview(button)
            }
            
            // 布局图片和文字
            var xOffset: CGFloat = kMarginX
            if let image = menuItem.image {
                let imageView = UIImageView(image: image)
                let imageHeight = min(image.size.height, maxItemHeight - kMarginY * 2)
                let imageWidth = image.size.width * (imageHeight / image.size.height)
                imageView.frame = CGRect(x: xOffset,
                                       y: (maxItemHeight - imageHeight) / 2,
                                       width: imageWidth,
                                       height: imageHeight)
                imageView.contentMode = .scaleAspectFit
                itemView.addSubview(imageView)
                xOffset += imageWidth + configuration.intervalSpacing
            }
            
            let titleLabel = UILabel()
            titleLabel.text = menuItem.title
            titleLabel.font = titleFont
            titleLabel.textColor = configuration.textColor.uiColor
            titleLabel.textAlignment = menuItem.alignment
            titleLabel.frame = CGRect(x: xOffset,
                                    y: 0,
                                    width: maxItemWidth - xOffset - kMarginX,
                                    height: maxItemHeight)
            itemView.addSubview(titleLabel)
            
            // 添加分隔线
            if index < menuItems.count - 1 && configuration.hasSeperatorLine {
                let lineView = UIView()
                lineView.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
                let lineInset = configuration.seperatorLineHasInsets ? kMarginX : 0
                lineView.frame = CGRect(x: lineInset,
                                      y: maxItemHeight - 0.5,
                                      width: maxItemWidth - lineInset * 2,
                                      height: 0.5)
                itemView.addSubview(lineView)
            }
            
            contentView.addSubview(itemView)
            itemY += maxItemHeight
        }
        
        // 调整内容视图大小（确保没有多余高度）
        contentView.frame = CGRect(x: 0, y: 0,
                                 width: maxItemWidth,
                                 height: itemY)
        
        return contentView
    }
    
    @objc private func performAction(_ sender: UIButton) {
        dismiss(animated: true)
        let menuItem = menuItems[sender.tag]
        menuItem.performAction()
    }
    
    private static func gradientLine(size: CGSize) -> UIImage? {
        let locations: [CGFloat] = [0, 0.2, 0.5, 0.8, 1]
        let R: CGFloat = 0.890
        let G: CGFloat = 0.890
        let B: CGFloat = 0.890
        
        let components: [CGFloat] = [
            R, G, B, 1,
            R, G, B, 1,
            R, G, B, 1,
            R, G, B, 1,
            R, G, B, 1
        ]
        
        return gradientImage(size: size, locations: locations, components: components, count: 5)
    }
    
    private static func gradientImage(size: CGSize, locations: [CGFloat], components: [CGFloat], count: Int) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let gradient = CGGradient(
            colorSpace: colorSpace,
            colorComponents: components,
            locations: locations,
            count: count
        ) else { return nil }
        
        context.drawLinearGradient(
            gradient,
            start: CGPoint(x: 0, y: 0),
            end: CGPoint(x: size.width, y: 0),
            options: []
        )
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let R0 = configuration.menuBackgroundColor.red
        let G0 = configuration.menuBackgroundColor.green
        let B0 = configuration.menuBackgroundColor.blue
        
        let R1 = R0
        let G1 = G0
        let B1 = B0
        
        let X0 = rect.origin.x
        let X1 = rect.origin.x + rect.width
        let Y0 = rect.origin.y
        let Y1 = rect.origin.y + rect.height
        
        // Render arrow
        let arrowPath = UIBezierPath()
        let kEmbedFix: CGFloat = 3.0
        
        switch arrowDirection {
        case .up:
            let arrowXM = arrowPosition
            let arrowX0 = arrowXM - configuration.arrowSize
            let arrowX1 = arrowXM + configuration.arrowSize
            let arrowY0 = Y0
            let arrowY1 = Y0 + configuration.arrowSize + kEmbedFix
            
            arrowPath.move(to: CGPoint(x: arrowXM, y: arrowY0))
            arrowPath.addLine(to: CGPoint(x: arrowX1, y: arrowY1))
            arrowPath.addLine(to: CGPoint(x: arrowX0, y: arrowY1))
            arrowPath.addLine(to: CGPoint(x: arrowXM, y: arrowY0))
            
            UIColor(red: R0, green: G0, blue: B0, alpha: 1).set()
            
        case .down:
            let arrowXM = arrowPosition
            let arrowX0 = arrowXM - configuration.arrowSize
            let arrowX1 = arrowXM + configuration.arrowSize
            let arrowY0 = Y1 - configuration.arrowSize - kEmbedFix
            let arrowY1 = Y1
            
            arrowPath.move(to: CGPoint(x: arrowXM, y: arrowY1))
            arrowPath.addLine(to: CGPoint(x: arrowX1, y: arrowY0))
            arrowPath.addLine(to: CGPoint(x: arrowX0, y: arrowY0))
            arrowPath.addLine(to: CGPoint(x: arrowXM, y: arrowY1))
            
            UIColor(red: R1, green: G1, blue: B1, alpha: 1).set()
            
        case .left:
            let arrowYM = arrowPosition
            let arrowX0 = X0
            let arrowX1 = X0 + configuration.arrowSize + kEmbedFix
            let arrowY0 = arrowYM - configuration.arrowSize
            let arrowY1 = arrowYM + configuration.arrowSize
            
            arrowPath.move(to: CGPoint(x: arrowX0, y: arrowYM))
            arrowPath.addLine(to: CGPoint(x: arrowX1, y: arrowY0))
            arrowPath.addLine(to: CGPoint(x: arrowX1, y: arrowY1))
            arrowPath.addLine(to: CGPoint(x: arrowX0, y: arrowYM))
            
            UIColor(red: R0, green: G0, blue: B0, alpha: 1).set()
            
        case .right:
            let arrowYM = arrowPosition
            let arrowX0 = X1
            let arrowX1 = X1 - configuration.arrowSize - kEmbedFix
            let arrowY0 = arrowYM - configuration.arrowSize
            let arrowY1 = arrowYM + configuration.arrowSize
            
            arrowPath.move(to: CGPoint(x: arrowX0, y: arrowYM))
            arrowPath.addLine(to: CGPoint(x: arrowX1, y: arrowY0))
            arrowPath.addLine(to: CGPoint(x: arrowX1, y: arrowY1))
            arrowPath.addLine(to: CGPoint(x: arrowX0, y: arrowYM))
            
            UIColor(red: R1, green: G1, blue: B1, alpha: 1).set()
            
        case .none:
            break
        }
        
        arrowPath.fill()
        
        // Render body
        let bodyFrame = CGRect(x: X0, y: Y0, width: X1 - X0, height: Y1 - Y0)
        let borderPath = UIBezierPath(
            roundedRect: bodyFrame,
            cornerRadius: configuration.menuCornerRadius
        )
        
        let locations: [CGFloat] = [0, 1]
        let components: [CGFloat] = [
            R0, G0, B0, 1,
            R1, G1, B1, 1
        ]
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let gradient = CGGradient(
            colorSpace: colorSpace,
            colorComponents: components,
            locations: locations,
            count: locations.count
        ) else { return }
        
        borderPath.addClip()
        
        let start: CGPoint
        let end: CGPoint
        
        if arrowDirection == .left || arrowDirection == .right {
            start = CGPoint(x: X0, y: Y0)
            end = CGPoint(x: X1, y: Y0)
        } else {
            start = CGPoint(x: X0, y: Y0)
            end = CGPoint(x: X0, y: Y1)
        }
        
        context.drawLinearGradient(gradient, start: start, end: end, options: [])
    }
}

private class KxMenuOverlay: UIView {
    weak var menuView: KxMenuView?
    
    init(frame: CGRect, maskSetting: Bool, menuView: KxMenuView) {
        self.menuView = menuView
        super.init(frame: frame)
        backgroundColor = maskSetting ? UIColor.black.withAlphaComponent(0.17) : .clear
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapHandler)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func tapHandler() {
        menuView?.dismiss(animated: true)
    }
    
    func remove() {
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0
        }) { _ in
            self.removeFromSuperview()
        }
    }
}
