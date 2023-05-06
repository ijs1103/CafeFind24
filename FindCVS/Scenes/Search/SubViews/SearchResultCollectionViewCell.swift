//
//  SearchResultCollectionViewCell.swift
//  FindCVS
//
//  Created by 이주상 on 2023/05/02.
//

import UIKit

final class SearchResultCollectionViewCell: UICollectionViewCell {
    static let identifier = "SearchResultCollectionViewCell"
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .brown
        label.font = .systemFont(ofSize: 14.0, weight: .semibold)
        return label
    }()
    private lazy var addressLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12.0, weight: .medium)
        label.textColor = .secondaryLabel
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
    
    func update(title: String, address: String) {
        titleLabel.text = title
        addressLabel.text = address
    }
}

extension SearchResultCollectionViewCell {
    private func setupView() {
        [ titleLabel, addressLabel ].forEach { addSubview($0) }

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(16.0)
            $0.leading.equalToSuperview()
        }
        addressLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(10.0)
            $0.leading.equalToSuperview()
            $0.bottom.equalToSuperview().inset(16.0)
        }
    }
}
