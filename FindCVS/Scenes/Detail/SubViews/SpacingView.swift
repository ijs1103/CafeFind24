//
//  SpacingView.swift
//  FindCVS
//
//  Created by 이주상 on 2023/04/28.
//

import UIKit

final class SpacingView: UIView {
    init() {
        super.init(frame: .zero)
        self.backgroundColor = UIColor(displayP3Red: 229/255, green: 229/255, blue: 233/255, alpha: 1)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
