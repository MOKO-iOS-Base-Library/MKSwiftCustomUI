//
//  MKSwiftCustomNavigationBar.swift
//  MKSwiftCustomUI
//
//  对齐 OC MKCustomNavigationBar：隐藏系统 UINavigationBar，避免 iOS 15+ 左右按钮白色圆环。
//

import UIKit
import MKBaseSwiftModule

open class MKSwiftCustomNavigationBar: UIView {

    // MARK: - Public

    open var title: String? {
        didSet {
            titleLabel.isHidden = title?.isEmpty ?? true
            titleLabel.text = title
            setNeedsLayout()
        }
    }

    open var titleLabelColor: UIColor = .white {
        didSet { titleLabel.textColor = titleLabelColor }
    }

    open var titleLabelFont: UIFont = MKFont.font(18) {
        didSet {
            titleLabel.font = titleLabelFont
            setNeedsLayout()
        }
    }

    open var barBackgroundColor: UIColor? {
        didSet {
            backgroundImageView.isHidden = true
            backgroundView.isHidden = false
            backgroundView.backgroundColor = barBackgroundColor
        }
    }

    open var barBackgroundImage: UIImage? {
        didSet {
            backgroundView.isHidden = true
            backgroundImageView.isHidden = barBackgroundImage == nil
            backgroundImageView.image = barBackgroundImage
        }
    }

    open private(set) lazy var leftButton: UIButton = makeBarButton()
    open private(set) lazy var rightButton: UIButton = makeBarButton()
    open private(set) lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    // MARK: - Private

    private let backgroundView = UIView()
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isHidden = true
        return imageView
    }()
    private let bottomLine: UIView = {
        let line = UIView()
        line.backgroundColor = MKLine.color
        return line
    }()

    // MARK: - Init

    public static func make() -> MKSwiftCustomNavigationBar {
        MKSwiftCustomNavigationBar(frame: CGRect(x: 0, y: 0, width: MKScreen.width, height: MKLayout.topBarHeight))
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    // MARK: - Layout

    open override func layoutSubviews() {
        super.layoutSubviews()
        layoutBarItems()
    }

    open func setBottomLineHidden(_ hidden: Bool) {
        bottomLine.isHidden = hidden
    }

    open func setBackgroundAlpha(_ alpha: CGFloat) {
        backgroundView.alpha = alpha
        backgroundImageView.alpha = alpha
        bottomLine.alpha = alpha
    }

    open func setTintColor(_ color: UIColor) {
        leftButton.setTitleColor(color, for: .normal)
        rightButton.setTitleColor(color, for: .normal)
        titleLabel.textColor = color
    }

    // MARK: - Setup

    private func setupView() {
        backgroundColor = .clear
        backgroundView.backgroundColor = MKColor.navBar
        titleLabel.textColor = titleLabelColor
        titleLabel.font = titleLabelFont

        addSubview(backgroundView)
        addSubview(backgroundImageView)
        addSubview(leftButton)
        addSubview(titleLabel)
        addSubview(rightButton)
        addSubview(bottomLine)
    }

    private func layoutBarItems() {
        let top = MKLayout.statusBarHeight
        let leftMargin: CGFloat = 12
        let rightMargin: CGFloat = 12
        let buttonHeight = MKLayout.navigationBarHeight

        var leftWidth = measuredButtonWidth(leftButton)
        var rightWidth = measuredButtonWidth(rightButton)
        leftWidth = max(44, min(120, leftWidth))
        rightWidth = max(44, min(120, rightWidth))

        let titleMaxWidth = bounds.width - leftWidth - rightWidth - leftMargin - rightMargin - 10
        let titleWidth = min(titleMaxWidth, 200)

        backgroundView.frame = bounds
        backgroundImageView.frame = bounds
        leftButton.frame = CGRect(x: leftMargin, y: top, width: leftWidth, height: buttonHeight)
        rightButton.frame = CGRect(x: bounds.width - rightWidth - rightMargin, y: top, width: rightWidth, height: buttonHeight)
        titleLabel.frame = CGRect(x: (bounds.width - titleWidth) / 2, y: top, width: titleWidth, height: buttonHeight)
        bottomLine.frame = CGRect(x: 0, y: bounds.height - MKLine.height, width: bounds.width, height: MKLine.height)
    }

    private func measuredButtonWidth(_ button: UIButton) -> CGFloat {
        let title = button.title(for: .normal) ?? ""
        let image = button.image(for: .normal)
        let font = button.titleLabel?.font ?? MKFont.font(16)
        var width: CGFloat = 44

        if !title.isEmpty {
            let textWidth = (title as NSString).boundingRect(
                with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 44),
                options: .usesLineFragmentOrigin,
                attributes: [.font: font],
                context: nil
            ).width
            width = textWidth + 20
        }

        if let image, title.isEmpty {
            width = image.size.width + 20
        } else if let image, !title.isEmpty {
            let textWidth = (title as NSString).boundingRect(
                with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 44),
                options: .usesLineFragmentOrigin,
                attributes: [.font: font],
                context: nil
            ).width
            width = textWidth + image.size.width + 24
        }

        return width
    }

    /// iOS 15+ 默认 UIButton.Configuration 会在导航栏场景出现白色圆环，需显式关闭。
    private func makeBarButton() -> UIButton {
        let button = UIButton(type: .custom)
        button.backgroundColor = .clear
        button.imageView?.contentMode = .center
        button.titleLabel?.font = MKFont.font(15)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(UIColor.white.withAlphaComponent(0.4), for: .highlighted)
        if #available(iOS 15.0, *) {
            button.configuration = nil
        }
        return button
    }
}
