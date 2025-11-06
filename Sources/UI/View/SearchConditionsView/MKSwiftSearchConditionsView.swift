//
//  MKSwiftSearchConditionsView.swift
//  MKBaseSwiftModule
//
//  Created by aa on 2024/3/11.
//

import UIKit

import MKBaseSwiftModule

public class MKSwiftSearchConditionsView: UIView {
    
    // MARK: - Constants
    private let offsetX: CGFloat = 10.0
    private let backViewHeight: CGFloat = 200.0
    private let signalIconWidth: CGFloat = 17.0
    private let signalIconHeight: CGFloat = 15.0
    
    // MARK: - UI Components
    private lazy var backView: UIView = {
        let view = UIView(frame: CGRect(x: offsetX,
                                       y: -backViewHeight,
                                       width: UIScreen.main.bounds.width - 2 * offsetX,
                                       height: backViewHeight))
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var textField: UITextField = {
        let field = UITextField(frame: CGRect(x: offsetX,
                                             y: offsetX,
                                             width: UIScreen.main.bounds.width - 4 * offsetX,
                                             height: 30))
        field.borderStyle = .none
        field.font = MKFont.font(13)
        field.textColor = .darkText
        field.placeholder = "Device name or mac address"
        field.clearButtonMode = .whileEditing
        field.layer.masksToBounds = true
        field.layer.borderColor = UIColor.blue.cgColor
        field.layer.borderWidth = 0.5
        field.layer.cornerRadius = 4.0
        return field
    }()
    
    private lazy var signalIcon: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: offsetX,
                                                 y: offsetX * 3 + 30,
                                                 width: signalIconWidth,
                                                 height: signalIconHeight))
        imageView.image = moduleIcon(name: "mk_swift_wifisignalIcon")
        return imageView
    }()
    
    private lazy var rssiLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: offsetX + signalIconWidth + 5,
                                          y: offsetX * 3 + 30,
                                          width: 35,
                                          height: signalIconHeight))
        label.textColor = .darkText
        label.textAlignment = .left
        label.font = MKFont.font(12)
        label.text = "RSSI:"
        return label
    }()
    
    private lazy var slider: UISlider = {
        let postionX = offsetX + signalIconWidth + 10 + 35
        let slider = UISlider(frame: CGRect(x: postionX,
                                           y: offsetX * 3 + 30,
                                           width: UIScreen.main.bounds.width - postionX - 3 * offsetX - 5 - 55,
                                           height: signalIconHeight))
        slider.maximumValue = 0
        slider.minimumValue = -100
        slider.value = -100
        slider.addTarget(self, action: #selector(rssiValueChanged), for: .valueChanged)
        return slider
    }()
    
    private lazy var rssiValueLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: UIScreen.main.bounds.width - 2 * offsetX - 55,
                                          y: offsetX * 3 + 30,
                                          width: 55,
                                          height: signalIconHeight))
        label.textColor = .darkText
        label.textAlignment = .left
        label.font = MKFont.font(12)
        label.text = "-100dBm"
        return label
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton(frame: CGRect(x: offsetX,
                                            y: backViewHeight - 45 - offsetX,
                                            width: UIScreen.main.bounds.width - 4 * offsetX,
                                            height: 45))
        button.backgroundColor = .blue
        button.setTitle("DONE", for: .normal)
        button.titleLabel?.font = MKFont.font(16)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 4.0
        button.addTarget(self, action: #selector(doneButtonPressed), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Properties
    private var searchBlock: ((String, Int) -> Void)?
    
    // MARK: - Initialization
    public override init(frame: CGRect) {
        super.init(frame: UIScreen.main.bounds)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("MKSwiftSearchConditionsView deallocated")
    }
    
    // MARK: - Public Methods
    public static func show(searchKey: String? = nil,
                           rssi: Int,
                           minRssi: Int,
                           searchBlock: @escaping (String?, Int) -> Void) {
        let view = MKSwiftSearchConditionsView()
        view.showView(with: searchKey, rssiValue: rssi, minSearchRssi: minRssi, searchBlock: searchBlock)
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        backgroundColor = UIColor(white: 0, alpha: 0.1)
        addSubview(backView)
        backView.addSubview(textField)
        backView.addSubview(signalIcon)
        backView.addSubview(rssiLabel)
        backView.addSubview(slider)
        backView.addSubview(rssiValueLabel)
        backView.addSubview(doneButton)
        addTapGesture()
    }
    
    private func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        tapGesture.numberOfTouchesRequired = 1
        tapGesture.numberOfTapsRequired = 1
        tapGesture.delegate = self
        addGestureRecognizer(tapGesture)
    }
    
    private func showView(with searchKey: String?,
                         rssiValue: Int,
                         minSearchRssi: Int,
                         searchBlock: @escaping (String?, Int) -> Void) {
        
        MKApp.window?.addSubview(self)
        self.searchBlock = searchBlock
        
        if let searchKey = searchKey, !searchKey.isEmpty {
            textField.text = searchKey
        }
        
        slider.minimumValue = Float(minSearchRssi)
        slider.value = Float(rssiValue)
        rssiValueLabel.text = "\(rssiValue)dBm"
        
        UIView.animate(withDuration: 0.25) {
            self.backView.transform = CGAffineTransform(translationX: 0, y: self.backViewHeight + MKLayout.topBarHeight)
        } completion: { _ in
            self.textField.becomeFirstResponder()
        }
    }
    
    @objc private func rssiValueChanged() {
        rssiValueLabel.text = String(format: "%.0fdBm", slider.value)
    }
    
    @objc private func dismiss() {
        textField.resignFirstResponder()
        UIView.animate(withDuration: 0.25) {
            self.backView.transform = CGAffineTransform(translationX: 0, y: -self.backViewHeight)
        } completion: { _ in
            self.removeFromSuperview()
        }
    }
    
    @objc private func doneButtonPressed() {
        textField.resignFirstResponder()
        UIView.animate(withDuration: 0.25) {
            self.backView.transform = CGAffineTransform(translationX: 0, y: -self.backViewHeight)
        } completion: { _ in
            let rssiValue = Int(self.slider.value)
            self.searchBlock?(self.textField.text ?? "", rssiValue)
            self.removeFromSuperview()
        }
    }
}

// MARK: - UIGestureRecognizerDelegate
extension MKSwiftSearchConditionsView: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view == self
    }
}
