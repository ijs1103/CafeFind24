//
//  LikeViewController.swift
//  FindCVS
//
//  Created by 이주상 on 2023/05/01.
//

import UIKit
import SnapKit
import Combine

final class LikeViewController: UIViewController {
    
    private let viewModel = LikeViewModel()
    private var subscriptions = Set<AnyCancellable>()
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .white
        table.dataSource = self
        table.delegate = self
        table.register(LikeTableViewCell.self, forCellReuseIdentifier: LikeTableViewCell.identifier)
        let backgroundView = LikedCafeBackgroundView()
        table.backgroundView = backgroundView
        backgroundView.delegate = self
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationTitle(title: "즐겨찾기")
        setupViews()
        bind()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        viewModel.updateLikedCafeList()
    }
}
extension LikeViewController {
    private func bind() {
        viewModel.likedCafeList
            .receive(on: RunLoop.main)
            .sink {[unowned self] cafeList in
                guard let cafeList = cafeList else { return }
                if cafeList.count > 0 {
                    self.tableView.backgroundView?.isHidden = true
                } else {
                    self.tableView.backgroundView?.isHidden = false
                }
                self.tableView.reloadData()
            }.store(in: &subscriptions)
    }
    private func setupViews() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.bottom.equalTo(view.safeAreaLayoutGuide).offset(8.0)
            $0.leading.trailing.equalToSuperview()
        }
    }
}
extension LikeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 96.0
    }
}
extension LikeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.likedCafeList.value?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LikeTableViewCell.identifier, for: indexPath) as? LikeTableViewCell
        cell?.delegate = self
        if let cafe = viewModel.likedCafeList.value?[indexPath.item] {
            cell?.update(cafe: cafe)
            cell?.selectionStyle = .none
        }
        return cell ?? UITableViewCell()
    }
}
extension LikeViewController: LikeTableViewCellDelegate {
    func didTapOptionButton(id: String, kakaoUrl: String) {
        actionSheetAlert { [unowned self] action in
            switch action {
            case .goToWeb:
                let webViewController = WebViewController(urlString: kakaoUrl)
                self.navigationController?.pushViewController(webViewController, animated: true)
            case .deleteLike:
                RealmManager.shared.deleteLikeCafe(id: id)
                self.viewModel.updateLikedCafeList()
            }
        }
    }
}
extension LikeViewController: LikedCafeBackgroundViewDelegate {
    func didTappedLikedCafeBackgroundView() {
        tabBarController?.selectedIndex = 0
    }
}

