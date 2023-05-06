//
//  SearchCollectionViewHeader.swift
//  FindCVS
//
//  Created by 이주상 on 2023/05/02.
//

import UIKit
import SnapKit

final class SearchCollectionViewHeader: UICollectionReusableView {
    static let identifier = "SearchCollectionViewHeader"

    private lazy var label: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "SystemForeground")
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    func updateTitle(_ title: String) {
        label.text = title
    }
}

extension SearchCollectionViewHeader {
    private func setupView() {
        addSubview(label)
        label.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
    }
}
