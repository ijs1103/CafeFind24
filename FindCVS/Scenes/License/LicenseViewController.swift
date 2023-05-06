//
//  LicenseViewController.swift
//  FindCVS
//
//  Created by 이주상 on 2023/05/05.
//

import SnapKit
import UIKit

class LicenseViewController: UIViewController {
    
    private lazy var textView: UITextView = {
        let uiTextView = UITextView()
        uiTextView.textColor = .secondaryLabel
        uiTextView.text = Constants.licenseText
        return uiTextView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupNavigation()
    }
}
extension LicenseViewController {
    private func setupViews() {
        view.backgroundColor = .systemBackground
        view.addSubview(textView)
        textView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(16.0)
        }
    }
    private func setupNavigation() {
        navigationItem.title = "라이센스"
        navigationItem.backButtonTitle = nil
    }
}

