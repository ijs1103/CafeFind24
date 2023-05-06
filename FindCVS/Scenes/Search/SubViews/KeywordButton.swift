//
//  KeywordButton.swift
//  FindCVS
//
//  Created by 이주상 on 2023/05/02.
//

import UIKit

final class KeywordButton: UIButton {
    var keyword: String?

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
