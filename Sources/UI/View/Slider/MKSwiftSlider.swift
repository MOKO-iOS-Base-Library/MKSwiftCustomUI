//
//  MKSwiftSlider.swift
//  MKBaseSwiftModule
//
//  Created by aa on 2024/3/11.
//

import UIKit

public class MKSwiftSlider: UISlider {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setThumbImage(moduleIcon(name: "mk_swift_sliderThumbIcon"), for: .normal)
        self.setThumbImage(moduleIcon(name: "mk_swift_sliderThumbIcon"), for: .highlighted)
        self.setMinimumTrackImage(moduleIcon(name: "mk_swift_sliderMinimumTrackIcon"), for: .normal)
        self.setMaximumTrackImage(moduleIcon(name: "mk_swift_sliderMaximumTrackImage"), for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
