//
//  ProfileViewController.swift
//  FindCVS
//
//  Created by 이주상 on 2023/05/05.
//
import SnapKit
import UIKit
import Combine

enum ProfileSection: CaseIterable {
    case setting, etc
    var title: String {
        switch self {
        case .setting:
            return "설정"
        case .etc:
            return "기타"
        }
    }
}
final class ProfileViewController: UIViewController {
    private let viewModel = ProfileViewModel()
    private var subscriptions = Set<AnyCancellable>()
    private lazy var profileView = ProfileView()
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.isScrollEnabled = false
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupViews()
        setupDelegates()
        bind()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchProfile()
    }
}
extension ProfileViewController {
    private func setupNavigation() {
        let backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        navigationItem.backBarButtonItem = backBarButtonItem
    }
    private func setupViews() {
        view.backgroundColor = .secondarySystemBackground
        [profileView, tableView].forEach {
            view.addSubview($0)
        }
        profileView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(16.0)
            $0.centerX.equalToSuperview()
        }
        tableView.snp.makeConstraints {
            $0.top.equalTo(profileView.snp.bottom).offset(16.0)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    private func setupDelegates() {
        profileView.delegate = self
    }
    private func bind() {
        viewModel.fetchedProfile
            .receive(on: RunLoop.main)
            .sink { [unowned self] result in
                self.profileView.updateImage(result?.image ?? UIImage(systemName: "person.fill")!)
                self.profileView.updateNickname(result?.profile.nickname ?? "Anonymous")
            }.store(in: &subscriptions)
    }
    private func pushToProfileEditViewController() {
        let profileEditViewController = ProfileEditViewController()
        navigationController?.pushViewController(profileEditViewController, animated: true)
    }
}
extension ProfileViewController: ProfileViewDelegate {
    func didTapProfileView() {
        pushToProfileEditViewController()
    }
}

extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            switch indexPath.item {
            case 0:
                pushToProfileEditViewController()
            case 1:
                guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                UIApplication.shared.open(url)
            default:
                return
            }
        }
        if indexPath.section == 1 {
            switch indexPath.item {
            case 0:
                let webViewController = WebViewController(urlString: Constants.policyUrl)
                navigationController?.pushViewController(webViewController, animated: true)
            case 1:
                let licenseViewController = LicenseViewController()
                navigationController?.pushViewController(licenseViewController, animated: true)
            default:
                return
            }
        }
    }
}

extension ProfileViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return ProfileSection.allCases.count
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ProfileSection.allCases[section].title
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        case 1:
            return 2
        default:
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        if indexPath.section == 0 {
            switch indexPath.item {
            case 0:
                cell.textLabel?.text = "프로필 수정"
            case 1:
                cell.textLabel?.text = "권한 설정"
            default:
                cell.textLabel?.text = ""
            }
        }
        if indexPath.section == 1 {
            switch indexPath.item {
            case 0:
                cell.textLabel?.text = "개인정보 처리방침"
            case 1:
                cell.textLabel?.text = "라이센스"
            default:
                cell.textLabel?.text = ""
            }
        }
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        return cell
    }
}
