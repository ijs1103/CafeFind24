//
//  ProfileView.swift
//  FindCVS
//
//  Created by 이주상 on 2023/05/05.
//

import UIKit
import SnapKit

protocol ProfileViewDelegate: AnyObject {
    func didTapProfileView()
}

final class ProfileView: UIView {
    weak var delegate: ProfileViewDelegate?
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.tintColor = .gray
        imageView.layer.cornerRadius = 50
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private lazy var nicknameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [imageView, nicknameLabel])
        stackView.spacing = 16.0
        stackView.axis = .vertical
        stackView.alignment = .center
        return stackView
    }()
    init() {
        super.init(frame: .zero)
        setupViews()
        setupGesture()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateNickname(_ name: String) {
        nicknameLabel.text = name
    }
    func updateImage(_ image: UIImage) {
        imageView.image = image
    }
}

extension ProfileView {
    private func setupViews() {
        addSubview(stackView)
        imageView.snp.makeConstraints {
            $0.width.height.equalTo(100)
        }
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(8.0)
        }
    }
    private func setupGesture() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                          action: #selector(didTapProfileView))
        addGestureRecognizer(tapGestureRecognizer)
    }
    @objc private func didTapProfileView() {
        delegate?.didTapProfileView()
    }
}
