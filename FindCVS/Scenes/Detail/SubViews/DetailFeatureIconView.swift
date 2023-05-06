//
//  DetailFeatureIconView.swift
//  FindCVS
//
//  Created by 이주상 on 2023/04/26.
//

import UIKit
import SnapKit

enum Feature {
    case call, webPage, findPath, share
    var featureText: String {
        switch self {
        case .call:
            return "전화"
        case .webPage:
            return "사이트"
        case .findPath:
            return "길찾기"
        case .share:
            return "공유"
        }
    }
    var featureImage: UIImage {
        switch self {
        case .call:
            return UIImage(systemName: "phone.fill")!
        case .webPage:
            return UIImage(systemName: "globe")!
        case .findPath:
            return UIImage(systemName: "car.fill")!
        case .share:
            return UIImage(systemName: "square.and.arrow.up")!
        }
    }
}

protocol DetailFeatureIconViewDelegate: AnyObject {
    func didTappedDetailFeatureIconView(feature: Feature)
}

final class DetailFeatureIconView: UIView {
    
    weak var delegate: DetailFeatureIconViewDelegate?
    
    private let feature: Feature
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemBlue
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemBlue
        return label
    }()
    
    init(feature: Feature, isPhoneNotExisted: Bool? = nil) {
        self.feature = feature
        super.init(frame: .zero)
        self.titleLabel.text = feature.featureText
        self.imageView.image = feature.featureImage
        if isPhoneNotExisted == true {
            self.imageView.tintColor = .systemGray
            self.titleLabel.textColor = .systemGray
        }
        setupViews()
        setupGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DetailFeatureIconView {
    private func setupGesture() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTappedDetailFeatureIconView))
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func setupViews() {
        [ imageView, titleLabel ].forEach { addSubview($0) }
        imageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview()
            $0.width.height.equalTo(36.0)
        }
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(imageView.snp.bottom).offset(8.0)
            $0.bottom.equalToSuperview()
        }
    }
    
    @objc func didTappedDetailFeatureIconView() {
        delegate?.didTappedDetailFeatureIconView(feature: feature)
    }
}
