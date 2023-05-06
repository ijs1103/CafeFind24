//
//  UIViewController+.swift
//  FindCVS
//
//  Created by 이주상 on 2023/04/26.
//

import UIKit

extension UIViewController {
    func errMessageAlert(message: String) {
        let alert = UIAlertController(title: "에러", message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "확인", style: .default)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    func setNavigationTitle(title: String) {
        let label = UILabel()
        label.textColor = .brown
        label.font = UIFont.systemFont(ofSize: 32.0, weight: .bold)
        label.text = title
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: label)
    }
    func actionSheetAlert(completion: @escaping (ActionSheet) -> Void) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let goToWeb = UIAlertAction(title: "사이트 가기", style: .default) { _ in
            completion(.goToWeb)
        }
        let deleteLike = UIAlertAction(title: "즐겨찾기 해제", style: .destructive) { _ in
            completion(.deleteLike)
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        [ goToWeb, deleteLike, cancel ].forEach {
            alert.addAction($0)
        }
        present(alert, animated: true)
    }
}
enum ActionSheet {
    case goToWeb, deleteLike
}
