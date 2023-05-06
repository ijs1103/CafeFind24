//
//  LikeTableViewCell.swift
//  FindCVS
//
//  Created by 이주상 on 2023/05/01.
//

import UIKit

protocol LikeTableViewCellDelegate: AnyObject {
    func didTapOptionButton(id: String, kakaoUrl: String)
}

final class LikeTableViewCell: UITableViewCell {
    
    static let identifier = "LikeTableViewCell"
    
    weak var delegate: LikeTableViewCellDelegate?
    
    private var id: String = ""
    
    private var kakaoUrl: String = ""
    
    private lazy var optionButton: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "arrowshape.turn.up.forward.fill")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemBrown
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapOptionButton))
        imageView.addGestureRecognizer(tapGestureRecognizer)
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18.0, weight: .bold)
        return label
    }()
    
    private lazy var addressLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12.0, weight: .semibold)
        label.textColor = .secondaryLabel
        return label
    }()

    func update(cafe: likedCafe) {
        id = cafe.id
        kakaoUrl = cafe.kakaoUrl
        titleLabel.text = cafe.title
        addressLabel.text = cafe.addressName
        setupViews()
    }

}

extension LikeTableViewCell {
    private func setupViews() {
        [ titleLabel, optionButton, addressLabel ].forEach {
            addSubview($0)
        }
        
        let spacing: CGFloat = 16.0
        
        titleLabel.snp.makeConstraints {
            $0.leading.top.equalToSuperview().inset(spacing)
        }
        
        optionButton.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.top)
            $0.trailing.equalToSuperview().inset(spacing)
            $0.width.equalTo(40.0)
            $0.height.equalTo(40.0)
        }
        
        addressLabel.snp.makeConstraints {
            $0.leading.equalTo(titleLabel.snp.leading)
            $0.top.equalTo(titleLabel.snp.bottom).offset(spacing)
            $0.bottom.equalToSuperview().inset(spacing)
        }
    }

    @objc private func didTapOptionButton() {
        delegate?.didTapOptionButton(id: id, kakaoUrl: kakaoUrl)
    }
}
