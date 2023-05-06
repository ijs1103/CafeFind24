//
//  LikedCafeBackgroundView.swift
//  FindCVS
//
//  Created by 이주상 on 2023/05/01.
//

import UIKit
import SnapKit

protocol LikedCafeBackgroundViewDelegate: AnyObject {
    func didTappedLikedCafeBackgroundView()
}

final class LikedCafeBackgroundView: UIView {
    
    weak var delegate: LikedCafeBackgroundViewDelegate?
    
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.text = "즐겨찾기 한 카페가 없습니다"
        label.textColor = .secondaryLabel
        label.font = UIFont.systemFont(ofSize: 24.0, weight: .bold)
        return label
    }()
    
    private lazy var findButton: UIButton = {
        let button = UIButton()
        var config = UIButton.Configuration.plain()
        config.contentInsets = NSDirectionalEdgeInsets.init(top: 5, leading: 10, bottom: 5, trailing: 10)
        config.baseBackgroundColor = .brown
        config.buttonSize = .small
        config.background.cornerRadius = 20.0
        config.background.strokeColor = .brown
        config.background.strokeWidth = 2.0
        config.title = "카페 둘러보기"
        button.configuration = config
        button.addTarget(self, action: #selector(didTapFindButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [ textLabel, findButton ])
        stackView.spacing = 16.0
        stackView.axis = .vertical
        stackView.alignment = .center
        return stackView
    }()
    
    init() {
        super.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
extension LikedCafeBackgroundView {
    private func setupViews() {
        addSubview(stackView)

        stackView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    @objc private func didTapFindButton() {
        delegate?.didTappedLikedCafeBackgroundView()
    }
}
