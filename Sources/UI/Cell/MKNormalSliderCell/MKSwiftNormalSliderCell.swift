//
//  MKSwiftNormalSliderCell.swift
//  MKBaseSwiftModule
//
//  Created by aa on 2024/3/28.
//

import UIKit
import SnapKit

import MKBaseSwiftModule

// MARK: - Cell Model
public class MKSwiftNormalSliderCellModel {
    // Cell top configuration
    public var index: Int = 0
    public var msg: NSAttributedString = NSAttributedString()
    public var contentColor: UIColor = .white
    
    // Right unit label configuration
    public var unit: String = "dBm"
    public var unitColor: UIColor = MKColor.defaultText
    public var unitFont: UIFont = MKFont.font(11)
    
    // Slider configuration
    public var sliderEnable: Bool = true
    public var sliderMinValue: Int = -127
    public var sliderMaxValue: Int = 0
    public var sliderValue: Int = 0
    
    // Bottom label configuration
    public var changed: Bool = false
    public var noteMsg: String = ""
    public var leftNoteMsg: String = ""
    public var rightNoteMsg: String = ""
    public var noteMsgColor: UIColor = MKColor.defaultText
    public var noteMsgFont: UIFont = MKFont.font(12)
    
    public init() {}
    
    public func cellHeightWithContentWidth(_ width: CGFloat) -> CGFloat {
        let msgHeight: CGFloat
        if !msg.string.isEmpty {
            msgHeight = String.size(with: msg.string,
                                  font: MKFont.font(15),
                                  maxSize: CGSize(width: width, height: .greatestFiniteMagnitude)).height
        } else {
            msgHeight = 0
        }
        
        let heightWithoutNote = msgHeight + 3 * 10 + 5 // offset_Y = 10
        guard changed || !noteMsg.isEmpty else {
            return max(heightWithoutNote, 55)
        }
        
        let tempNoteMsg = changed ?
            "\(leftNoteMsg) \(sliderValue)\(unit) \(rightNoteMsg)" :
            noteMsg
        
        let noteSize = tempNoteMsg.size(withFont: noteMsgFont, maxSize: CGSize(width: (width - 2 * 15), height: .greatestFiniteMagnitude))
        
        return max(heightWithoutNote, 55) + noteSize.height + 15
    }
}

// MARK: - Cell Delegate
public protocol MKSwiftNormalSliderCellDelegate: AnyObject {
    func mk_normalSliderValueChanged(_ value: Int, index: Int)
}

// MARK: - Cell Implementation
public class MKSwiftNormalSliderCell: MKSwiftBaseCell {
    
    // MARK: - Properties
    public var dataModel: MKSwiftNormalSliderCellModel? {
        didSet {
            updateContent()
        }
    }
    
    public weak var delegate: MKSwiftNormalSliderCellDelegate?
    
    // MARK: - Class Methods
    public class func initCellWithTableView(_ tableView: UITableView) -> MKSwiftNormalSliderCell {
        let identifier = "MKSwiftNormalSliderCellIdenty"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? MKSwiftNormalSliderCell
        if cell == nil {
            cell = MKSwiftNormalSliderCell(style: .default, reuseIdentifier: identifier)
        }
        return cell!
    }
    
    // MARK: - Constants
    private let offset_X: CGFloat = 15
    private let offset_Y: CGFloat = 10
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(msgLabel)
        contentView.addSubview(sliderValueLabel)
        contentView.addSubview(sliderView)
        contentView.addSubview(noteLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        msgLabel.snp.remakeConstraints { make in
            make.left.equalToSuperview().offset(offset_X)
            make.right.equalToSuperview().offset(-offset_X)
            make.top.equalToSuperview().offset(offset_Y)
            make.height.equalTo(msgLabelHeight())
        }
        
        sliderView.snp.remakeConstraints { make in
            make.left.equalToSuperview().offset(offset_X)
            make.right.equalTo(sliderValueLabel.snp.left).offset(-5)
            make.top.equalTo(msgLabel.snp.bottom).offset(5)
            make.height.equalTo(offset_Y)
        }
        
        sliderValueLabel.snp.remakeConstraints { make in
            make.right.equalToSuperview().offset(-offset_X)
            make.width.equalTo(70)
            make.centerY.equalTo(sliderView.snp.centerY)
            make.height.equalTo(sliderValueLabel.font.lineHeight)
        }
        
        noteLabel.snp.remakeConstraints { make in
            make.left.equalToSuperview().offset(offset_X)
            make.right.equalToSuperview().offset(-offset_X)
            make.bottom.equalToSuperview().offset(-offset_Y)
            make.height.equalTo(noteMsgSize().height)
        }
    }
    
    // MARK: - Actions
    @objc private func sliderValueChanged() {
        let value = Int(round(sliderView.value))
        sliderValueLabel.text = "\(value)\(dataModel?.unit ?? "")"
        
        if let model = dataModel, model.changed {
            noteLabel.text = "\(model.leftNoteMsg) \(value)\(model.unit) \(model.rightNoteMsg)"
        }
        
        delegate?.mk_normalSliderValueChanged(value, index: dataModel?.index ?? 0)
    }
    
    // MARK: - Helper Methods
    private func msgLabelHeight() -> CGFloat {
        guard let text = msgLabel.attributedText else { return 0 }
        return MKSwiftUIAdaptor.strHeight(forAttributedString: text, viewWidth: (contentView.frame.width - 30))
    }
    
    private func noteMsgSize() -> CGSize {
        guard let text = noteLabel.text, !text.isEmpty else {
            return .zero
        }
        
        let width = contentView.frame.width - 2 * offset_X
        return text.size(
            withFont: noteLabel.font,
            maxSize: CGSize(width: width, height: .greatestFiniteMagnitude)  // Changed offset_X to offsetX
        )
    }
    
    // MARK: - UI Setup
    private func updateContent() {
        guard let dataModel = dataModel else { return }
        
        contentView.backgroundColor = dataModel.contentColor
        msgLabel.attributedText = dataModel.msg
        sliderView.isEnabled = dataModel.sliderEnable
        sliderView.maximumValue = Float(dataModel.sliderMaxValue)
        sliderView.minimumValue = Float(dataModel.sliderMinValue)
        sliderView.value = Float(dataModel.sliderValue)
        sliderValueLabel.text = "\(dataModel.sliderValue)\(dataModel.unit)"
        sliderValueLabel.textColor = dataModel.unitColor
        sliderValueLabel.font = dataModel.unitFont
        
        if dataModel.changed {
            noteLabel.text = "\(dataModel.leftNoteMsg) \(dataModel.sliderValue)\(dataModel.unit) \(dataModel.rightNoteMsg)"
        } else {
            noteLabel.text = dataModel.noteMsg
        }
        
        noteLabel.font = dataModel.noteMsgFont
        noteLabel.textColor = dataModel.noteMsgColor
        
        setNeedsLayout()
    }
    
    // MARK: - Lazy
    private lazy var msgLabel: UILabel = {
        let msgLabel = MKSwiftUIAdaptor.createNormalLabel()
        msgLabel.numberOfLines = 0
        return msgLabel
    }()
    private lazy var sliderValueLabel: UILabel = {
        return MKSwiftUIAdaptor.createNormalLabel(font: MKFont.font(11))
    }()
    private lazy var sliderView: MKSwiftSlider = {
        let sliderView = MKSwiftSlider()
        sliderView.maximumValue = 0
        sliderView.minimumValue = -127
        sliderView.addTarget(self,
                             action: #selector(sliderValueChanged),
                             for: .valueChanged)
        return sliderView
    }()
    private lazy var noteLabel: UILabel = {
        let noteLabel = MKSwiftUIAdaptor.createNormalLabel(font: MKFont.font(12))
        noteLabel.numberOfLines = 0
        return noteLabel
    }()
}
