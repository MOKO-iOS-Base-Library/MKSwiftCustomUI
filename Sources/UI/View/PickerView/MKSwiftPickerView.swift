//
//  MKSwiftPickerView.swift
//  MKBaseSwiftModule
//
//  Created by aa on 2024/3/11.
//

import UIKit

import MKBaseSwiftModule

public class MKSwiftPickerView: UIView {
    
    // MARK: - Public Methods
    public func showPickView(with dataList: [String],
                           selectedRow: Int = 0,
                           selectionHandler: @escaping (Int) -> Void) {
        guard !dataList.isEmpty, selectedRow < dataList.count else {
            print("Invalid data for picker view")
            return
        }
        
        self.dataList = dataList
        self.currentRow = selectedRow
        self.selectionHandler = selectionHandler
        
        MKApp.window?.addSubview(self)
        pickerView.reloadAllComponents()
        pickerView.selectRow(currentRow, inComponent: 0, animated: false)
        
        UIView.animate(withDuration: animationDuration) {
            self.bottomView.transform = CGAffineTransform(translationX: 0, y: -self.pickerViewHeight)
        }
    }
    
    @objc public func dismiss() {
        UIView.animate(withDuration: animationDuration, animations: {
            self.bottomView.transform = .identity
        }) { _ in
            self.removeFromSuperview()
        }
    }
    
    // MARK: - Constants
    private let animationDuration: TimeInterval = 0.3
    private let pickerViewHeight: CGFloat = 270
    private let pickerViewRowHeight: CGFloat = 30
    
    // MARK: - UI Components
    private lazy var bottomView: UIView = {
        let view = UIView(frame: CGRect(x: 0,
                                       y: UIScreen.main.bounds.height,
                                       width: UIScreen.main.bounds.width,
                                       height: pickerViewHeight))
        view.backgroundColor = MKColor.rgb(244, 244, 244)
        
        let topView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        topView.backgroundColor = .white
        view.addSubview(topView)
        
        let cancelButton = UIButton(type: .custom)
        cancelButton.frame = CGRect(x: 10, y: 10, width: 60, height: 30)
        cancelButton.backgroundColor = .clear
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(.darkText, for: .normal)
        cancelButton.titleLabel?.font = MKFont.font(16)
        cancelButton.addTarget(self, action: #selector(cancelButtonPressed), for: .touchUpInside)
        topView.addSubview(cancelButton)
        
        let confirmButton = UIButton(type: .custom)
        confirmButton.frame = CGRect(x: UIScreen.main.bounds.width - 80, y: 10, width: 70, height: 30)
        confirmButton.backgroundColor = .clear
        confirmButton.setTitle("Confirm", for: .normal)
        confirmButton.setTitleColor(.darkText, for: .normal)
        confirmButton.titleLabel?.font = MKFont.font(16)
        confirmButton.addTarget(self, action: #selector(confirmButtonPressed), for: .touchUpInside)
        topView.addSubview(confirmButton)
        
        return view
    }()
    
    private lazy var pickerView: UIPickerView = {
        let picker = UIPickerView(frame: CGRect(x: 10,
                                               y: pickerViewHeight - 216,
                                               width: UIScreen.main.bounds.width - 20,
                                               height: 216))
        picker.dataSource = self
        picker.delegate = self
        picker.backgroundColor = .clear
        return picker
    }()
    
    // MARK: - Properties
    private var dataList: [String] = []
    private var currentRow: Int = 0
    private var selectionHandler: ((Int) -> Void)?
    
    // MARK: - Initialization
    public override init(frame: CGRect) {
        super.init(frame: UIScreen.main.bounds)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("MKSwiftPickerView deallocated")
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupView() {
        backgroundColor = UIColor(white: 0, alpha: 0.5)
        addSubview(bottomView)
        bottomView.addSubview(pickerView)
        addTapGesture()
        
        NotificationCenter.default.addObserver(self,
                                             selector: #selector(dismiss),
                                             name: Notification.Name("mk_swift_dismissPickView"),
                                             object: nil)
    }
    
    // MARK: - Private Methods
    private func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        tapGesture.numberOfTapsRequired = 1
        addGestureRecognizer(tapGesture)
        isUserInteractionEnabled = true
    }
    
    @objc private func cancelButtonPressed() {
        dismiss()
    }
    
    @objc private func confirmButtonPressed() {
        selectionHandler?(currentRow)
        dismiss()
    }
}

// MARK: - UIPickerViewDataSource & UIPickerViewDelegate
extension MKSwiftPickerView: UIPickerViewDataSource, UIPickerViewDelegate {
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataList.count
    }
    
    public func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return pickerViewRowHeight
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dataList[row]
    }
    
    public func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.darkText,
            .font: MKFont.font(15)
        ]
        return NSAttributedString(string: dataList[row], attributes: attributes)
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentRow = row
    }
}
