//
//  SearchViewController.swift
//  FindCVS
//
//  Created by 이주상 on 2023/05/02.
//

import UIKit
import SnapKit
import Combine

final class SearchViewController: UIViewController {
    enum Section: CaseIterable {
        case popularSearchKeyword, searchResult
        var title: String {
            switch self {
            case .popularSearchKeyword:
                return "인기 검색어"
            case .searchResult:
                return "검색 결과"
            }
        }
    }
    enum SearchContents: Hashable {
        case popularSearchKeyword(String)
        case searchResult(Cafe)
    }
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, SearchContents>
    typealias DataSource = UICollectionViewDiffableDataSource<Section, SearchContents>
    private var dataSource: DataSource?
    private var snapshot = Snapshot()
    private lazy var searchBarTitleView = SearchBarTitleView()
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: SearchViewController.customLayout())
        collectionView.register(
            SearchCollectionViewHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SearchCollectionViewHeader.identifier
        )
        collectionView.register(
            PopularCafeCollectionViewCell.self,
            forCellWithReuseIdentifier: PopularCafeCollectionViewCell.identifier
        )
        collectionView.register(
            SearchResultCollectionViewCell.self,
            forCellWithReuseIdentifier: SearchResultCollectionViewCell.identifier
        )
        return collectionView
    }()
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20.0, weight: .semibold)
        label.textColor = .brown
        label.text = "검색 결과가 없습니다."
        return label
    }()
    private let viewModel = SearchViewModel()
    private var subscriptions = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupViews()
        setupDelegates()
        setupSnapshot()
        setupDataSource()
        setupKeyboard()
        bind()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
}
extension SearchViewController {
    private func setupNavigation() {
        searchBarTitleView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 40)
        navigationItem.titleView = searchBarTitleView
    }
    private func setupViews() {
        view.backgroundColor = .systemBackground
        [ collectionView, textLabel ].forEach {
            view.addSubview($0)
        }
        collectionView.snp.makeConstraints {
            $0.top.bottom.equalTo(view.safeAreaLayoutGuide).offset(16.0)
            $0.leading.trailing.equalToSuperview()
        }
        textLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
    }
    private func setupDelegates() {
        searchBarTitleView.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = dataSource
    }
    private func bind() {
        viewModel.popularKeywordList
            .receive(on: RunLoop.main)
            .sink {[weak self] keywords in
                guard let self = self, let dataSource = self.dataSource else { return }
                var snapshot = dataSource.snapshot(for: Section.popularSearchKeyword)
                let contents = keywords.map { SearchContents.popularSearchKeyword($0) }
                snapshot.append(contents)
                dataSource.apply(snapshot, to: Section.popularSearchKeyword)
            }.store(in: &subscriptions)
        
        viewModel.fetchedCafeList
            .receive(on: RunLoop.main)
            .sink { [weak self] cafeList in
                guard let self = self, let dataSource = self.dataSource else { return }
                // 검색결과 없으면
                self.textLabel.isHidden = !(cafeList.count == 0)
                var snapshot = dataSource.snapshot(for: Section.searchResult)
                let contents = cafeList.map { SearchContents.searchResult($0) }
                snapshot.deleteAll()
                snapshot.append(contents)
                dataSource.apply(snapshot, to: Section.searchResult)
            }.store(in: &subscriptions)
        
        viewModel.didTapCafe
            .receive(on: RunLoop.main)
            .sink { [unowned self] cafe in
                let mapViewController = MapViewController(cafe: cafe)
                navigationController?.pushViewController(mapViewController, animated: true)
            }.store(in: &subscriptions)
    }
    private func setupDataSource() {
        dataSource = DataSource(collectionView: collectionView) { [unowned self] collectionView, indexPath, content in
            switch content {
            case .popularSearchKeyword(let keyword):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PopularCafeCollectionViewCell.identifier, for: indexPath) as? PopularCafeCollectionViewCell
                cell?.updateKeyword(keyword)
                cell?.delegate = self
                return cell ?? UICollectionViewCell()
            case .searchResult(let cafe):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchResultCollectionViewCell.identifier, for: indexPath) as? SearchResultCollectionViewCell
                cell?.update(title: cafe.title, address: cafe.addressName)
                return cell ?? UICollectionViewCell()
            }
        }
        setupHeader(dataSource: dataSource)
    }
    private func setupSnapshot() {
        snapshot.appendSections(Section.allCases)
    }
    private func setupHeader(dataSource: DataSource?) {
        guard let dataSource = dataSource else { return }
        
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionHeader else { return nil }
            let view = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: SearchCollectionViewHeader.identifier,
                for: indexPath
            ) as? SearchCollectionViewHeader
            let section = dataSource.snapshot().sectionIdentifiers[indexPath.section]
            view?.updateTitle(section.title)
            return view
        }
    }
    private func setupKeyboard() {
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                action: #selector(didTapCollectionView))
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        singleTapGestureRecognizer.isEnabled = true
        singleTapGestureRecognizer.cancelsTouchesInView = false
        collectionView.addGestureRecognizer(singleTapGestureRecognizer)
    }
    @objc private func didTapCollectionView() {
        searchBarTitleView.hideKeyboard()
    }
    static func customLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { sectionNumber, _ -> NSCollectionLayoutSection? in
            return SearchCollectionViewLayouts().section(at: sectionNumber)
        }
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.didChangeSearchText(searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBarTitleView.hideKeyboard()
    }
}


extension SearchViewController: PopularCafeCollectionViewCellDelegate {
    func didTapKeywordButton(keyword: String?) {
        guard let keyword = keyword else { return }
        searchBarTitleView.updateSearchBar(keyword: keyword)
        viewModel.didChangeSearchText(keyword)
    }
}

extension SearchViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 1, viewModel.fetchedCafeList.value.count > 0 {
            let cafe = viewModel.fetchedCafeList.value[indexPath.item]
            viewModel.didTapCafe.send(cafe)
        }
    }
}
