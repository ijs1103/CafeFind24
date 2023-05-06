//
//  SearchBarView.swift
//  FindCVS
//
//  Created by 이주상 on 2023/05/02.
//

import UIKit
import SnapKit

protocol SearchBarViewDelegate: AnyObject {
    func didTapSearchBarView()
}

final class SearchBarView: UIView {
    
    weak var delegate: SearchBarViewDelegate?
    
    private lazy var searchBarIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "magnifyingglass")
        imageView.tintColor = .black
        return imageView
    }()
    
    private lazy var placeholder: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.text = "내 주변 카페를 검색해보세요."
        return label
    }()
    
    init() {
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SearchBarView {
    private func setupView() {
        backgroundColor = .secondarySystemBackground
        [ searchBarIcon, placeholder ].forEach { addSubview($0) }
        searchBarIcon.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16.0)
            $0.centerY.equalToSuperview()
        }
        placeholder.snp.makeConstraints {
            $0.leading.equalTo(searchBarIcon.snp.trailing).offset(16.0)
            $0.centerY.equalToSuperview()
        }
        layer.cornerRadius = 8.0
        layer.masksToBounds = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapSearchBarView))
        addGestureRecognizer(tapGestureRecognizer)
    }
    @objc private func didTapSearchBarView() {
        delegate?.didTapSearchBarView()
    }
}
