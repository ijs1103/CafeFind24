//
//  WebViewController.swift
//  FindCVS
//
//  Created by 이주상 on 2023/04/28.
//

import WebKit
import UIKit
import SnapKit

final class WebViewController: UIViewController {
    
    private var urlString: String? = nil
    
    private lazy var spinner: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicator.color = .brown
        activityIndicator.style = .large
        return activityIndicator
    }()
    
    private let webView = WKWebView()
    
    init(urlString: String) {
        super.init(nibName: nil, bundle: nil)
        self.urlString = urlString
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        setupViews()
        setupDelegates()
    }
}

extension WebViewController {
    private func setupWebView() {
        guard let urlString = urlString, let url = URL(string: urlString) else {
            self.navigationController?.popViewController(animated: true)
            return
        }
        view = webView
        let request = URLRequest(url: url)
        webView.load(request)
    }
    private func setupViews() {
        webView.addSubview(spinner)
        spinner.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    private func setupDelegates() {
        webView.navigationDelegate = self
    }
}
extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        spinner.startAnimating()
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        spinner.stopAnimating()
    }
}

