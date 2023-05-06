//
//  PopularCafeCollectionViewCell.swift
//  FindCVS
//
//  Created by 이주상 on 2023/05/02.
//

import UIKit
import SnapKit

protocol PopularCafeCollectionViewCellDelegate: AnyObject {
    func didTapKeywordButton(keyword: String?)
}

final class PopularCafeCollectionViewCell: UICollectionViewCell {
    static let identifier = "PopularCafeCollectionViewCell"

    weak var delegate: PopularCafeCollectionViewCellDelegate?

    private lazy var keywordButton: KeywordButton = {
        let button = KeywordButton()
        var config = UIButton.Configuration.filled()
        config.contentInsets = NSDirectionalEdgeInsets.init(top: 5, leading: 10, bottom: 5, trailing: 10)
        config.baseBackgroundColor = .brown
        config.buttonSize = .small
        config.background.cornerRadius = 16.0
        button.configuration = config
        button.addTarget(self, action: #selector(didTapKeywordButton), for: .touchUpInside)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    func updateKeyword(_ keyword: String) {
        keywordButton.keyword = keyword
        keywordButton.setTitle(keyword, for: .normal)
    }
}

extension PopularCafeCollectionViewCell {

    private func setupView() {
        addSubview(keywordButton)
        keywordButton.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }

    @objc private func didTapKeywordButton(_ sender: KeywordButton) {
        delegate?.didTapKeywordButton(keyword: sender.keyword)
    }
}
