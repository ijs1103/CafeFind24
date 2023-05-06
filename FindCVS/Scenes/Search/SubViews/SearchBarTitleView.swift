//
//  SearchBarTitleView.swift
//  FindCVS
//
//  Created by 이주상 on 2023/05/02.
//

import UIKit

final class SearchBarTitleView: UIView {
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.backgroundColor = .secondarySystemBackground
        searchBar.layer.cornerRadius = 8.0
        searchBar.layer.masksToBounds = true
        return searchBar
    }()
    
    weak var delegate: UISearchBarDelegate? {
        didSet {
            searchBar.delegate = delegate
        }
    }
    
    init() {
        super.init(frame: CGRect.zero)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        searchBar.frame = bounds
    }
    
    func hideKeyboard() {
        searchBar.endEditing(true)
    }

    func updateSearchBar(keyword: String) {
        searchBar.text = keyword
    }
}

extension SearchBarTitleView {
    private func setupView() {
        addSubview(searchBar)
    }
}
