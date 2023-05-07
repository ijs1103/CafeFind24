//
//  DetailViewController.swift
//  FindCVS
//
//  Created by 이주상 on 2023/04/26.
//

import UIKit
import SnapKit
import Toast
import Combine
import CoreLocation

protocol DetailViewControllerDelegate: AnyObject {
    func pushToWebView(urlString: String)
    func pushToFindPathView(currentCoordi: CLLocationCoordinate2D, destinationCoordi: CLLocationCoordinate2D, cafeTitle: String)
}

final class DetailViewController: UIViewController {
    
    weak var delegate: DetailViewControllerDelegate?
    private var viewModel: DetailViewModel
    private var subscriptions = Set<AnyCancellable>()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .brown
        label.font = UIFont.boldSystemFont(ofSize: 26)
        label.text = viewModel.title
        return label
    }()
    
    private lazy var likeButton: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .red
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTappedLike))
        imageView.addGestureRecognizer(gestureRecognizer)
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private lazy var spacingView1 = SpacingView()
    private lazy var spacingView2 = SpacingView()
    private lazy var callButton = DetailFeatureIconView(feature: .call, isPhoneNotExisted: viewModel.isPhoneNotExisted)
    private lazy var webPageButton = DetailFeatureIconView(feature: .webPage)
    private lazy var findPathButton = DetailFeatureIconView(feature: .findPath)
    private lazy var shareButton = DetailFeatureIconView(feature: .share)

    private lazy var buttonStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [ callButton, webPageButton, findPathButton, shareButton ])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .center
        return stack
    }()

    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .white
        table.dataSource = self
        table.delegate = self
        table.register(DetailTableViewCell.self, forCellReuseIdentifier: DetailTableViewCell.identifier)
        return table
    }()
    
    init(cafe: Cafe) {
        self.viewModel = DetailViewModel(cafe: cafe)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupDelegates()
        bind()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        viewModel.updateisLikedCafe()
    }
}

extension DetailViewController {
    private func bind() {
        viewModel.isLikedCafe.receive(on: RunLoop.main)
            .sink { [unowned self] isLikedCafe in
                self.likeButton.image = isLikedCafe ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
            }.store(in: &subscriptions)
        
        viewModel.didTappedLike.receive(on: RunLoop.main)
            .sink { [unowned self] id in
                if !viewModel.isLikedCafe.value {
                    let likedCafe = likedCafe(id: viewModel.id, title: viewModel.title, addressName: viewModel.addressName, kakaoUrl: viewModel.kakaoUrl, findPathUrl: viewModel.findPathUrl)
                    RealmManager.shared.addLikedCafe(likedCafe)
                    viewModel.isLikedCafe.send(true)
                    self.view.makeToast("즐겨찾기 되었습니다", duration: 1.0, position: .bottom)
                } else {
                    RealmManager.shared.deleteLikeCafe(id: id)
                    viewModel.isLikedCafe.send(false)
                    self.view.makeToast("즐겨찾기 해제하였습니다", duration: 1.0, position: .bottom)
                }
            }.store(in: &subscriptions)
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        [ likeButton, titleLabel, buttonStackView, spacingView1, spacingView2, tableView ].forEach {
            view.addSubview($0)
        }
        let spacing: CGFloat = 16.0
        likeButton.snp.makeConstraints {
            $0.top.equalToSuperview().inset(24.0)
            $0.trailing.equalToSuperview().inset(spacing)
            $0.width.height.equalTo(36.0)
        }
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(likeButton.snp.top)
            $0.leading.equalToSuperview().inset(spacing)
            $0.trailing.equalTo(likeButton.snp.leading).offset(spacing)
        }
        spacingView1.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(30.0)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1.0)
        }
        buttonStackView.snp.makeConstraints {
            $0.top.equalTo(spacingView1.snp.bottom).offset(spacing)
            $0.leading.trailing.equalToSuperview()
        }
        spacingView2.snp.makeConstraints {
            $0.top.equalTo(buttonStackView.snp.bottom).offset(spacing)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(8.0)
        }
        tableView.snp.makeConstraints {
            $0.top.equalTo(spacingView2.snp.bottom).offset(spacing)
            $0.leading.trailing.equalToSuperview().inset(spacing)
            $0.height.equalTo(200.0)
        }
    }
    
    private func setupDelegates() {
        callButton.delegate = self
        webPageButton.delegate = self
        findPathButton.delegate = self
        shareButton.delegate = self
    }
    
    @objc private func didTappedLike() {
        viewModel.didTappedLike.send(viewModel.id)
    }
    
    private func makePhoneCall() {
        if viewModel.isPhoneNotExisted { return }
        if let url = URL(string: "tel://\(viewModel.phone)"), UIApplication.shared .canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    private func goToWebPage() {
        let urlString = viewModel.kakaoUrl
        delegate?.pushToWebView(urlString: urlString)
    }
    
    private func findPath() {
        delegate?.pushToFindPathView(currentCoordi: viewModel.currentCoordi, destinationCoordi: viewModel.destinationCoordi, cafeTitle: viewModel.title)
    }
    
    private func shareCafe() {
        var activityItems: [String] = []
        let shareText = "카페명: \(viewModel.title) \n\n \(viewModel.kakaoUrl)"
        activityItems.append(shareText)
        let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        self.present(activityVC, animated: true, completion: nil)
    }
}

extension DetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64.0
    }
}
extension DetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DetailTableViewCell.identifier, for: indexPath) as? DetailTableViewCell
        let text = [viewModel.addressName, viewModel.phone, viewModel.category][indexPath.item]
        let kind = (DetailTableViewCellKind.init(rawValue: indexPath.item) ?? .address) as DetailTableViewCellKind
        cell?.update(text: text, kind: kind)
        cell?.selectionStyle = .none
        
        return cell ?? UITableViewCell()
    }
}

extension DetailViewController: DetailFeatureIconViewDelegate {
    func didTappedDetailFeatureIconView(feature: Feature) {
        switch feature {
        case .call:
            makePhoneCall()
        case .webPage:
            goToWebPage()
        case .findPath:
            findPath()
        case .share:
            shareCafe()
        }
    }
}
