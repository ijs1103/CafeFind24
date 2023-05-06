//
//  DetailTableViewCell.swift
//  FindCVS
//
//  Created by 이주상 on 2023/04/27.
//

import UIKit
import Toast

enum DetailTableViewCellKind: Int {
    case address = 0, phone, category
    var hasCopyButton: Bool {
        switch self {
        case .address, .phone:
            return true
        case .category:
            return false
        }
    }
    var image: UIImage {
        switch self {
        case .address:
            return UIImage(systemName: "mappin.circle")!
        case .phone:
            return UIImage(systemName: "phone.circle")!
        case .category:
            return UIImage(systemName: "c.circle")!
        }
    }
}

final class DetailTableViewCell: UITableViewCell {
    
    static let identifier = "DetailTableViewCell"
    
    private lazy var iconImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .gray
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14.0, weight: .semibold)
        label.textColor = .darkGray
        return label
    }()
    
    private lazy var copyButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "doc.on.doc"), for: .normal)
        button.tintColor = .systemGreen
        button.addTarget(self, action: #selector(didTapCopy), for: .touchUpInside)
        return button
    }()
    
    func update(text: String, kind: DetailTableViewCellKind) {
        setupViews(kind.hasCopyButton)
        iconImage.image = kind.image
        titleLabel.text = text
    }
}

extension DetailTableViewCell {
    private func setupViews(_ hasCopyButton: Bool) {
        
        backgroundColor = .white
        
        [ iconImage, titleLabel ].forEach {
            addSubview($0)
        }
        
        let spacing: CGFloat = 8.0
        
        iconImage.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(spacing)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(32.0)
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(iconImage.snp.trailing).offset(spacing)
        }
        
        if hasCopyButton {
            addSubview(copyButton)
            copyButton.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.trailing.equalToSuperview().inset(spacing)
                $0.width.height.equalTo(40.0)
            }
        }
    }
    @objc private func didTapCopy() {
        UIPasteboard.general.string = titleLabel.text
        self.makeToast("복사 되었습니다.", duration: 1.0, position: .bottom)
    }
}

