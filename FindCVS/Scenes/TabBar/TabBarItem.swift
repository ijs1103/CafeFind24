//
//  TabBarItem.swift
//  FindCVS
//
//  Created by 이주상 on 2023/05/01.
//

import UIKit

enum TabBarItem: CaseIterable {
    case map
    case like
    case profile
    
    var title: String {
        switch self {
        case .map:
            return "지도"
        case .like:
            return "즐겨찾기"
        case .profile:
            return "프로필"
        }
    }
    
    var icon: (default: UIImage?, selected: UIImage?) {
        switch self {
        case .map:
            return (UIImage(systemName: "map"), UIImage(systemName: "map.fill"))
        case .like:
            return (UIImage(systemName: "star"), UIImage(systemName: "star.fill"))
        case .profile:
            return (UIImage(systemName: "person"), UIImage(systemName: "person.fill"))
        }
    }

    var viewController: UIViewController {
        switch self {
        case .map:
            return UINavigationController(rootViewController: MapViewController())
        case .like:
            return UINavigationController(rootViewController: LikeViewController())
        case .profile:
            return UINavigationController(rootViewController: ProfileViewController())
        }
    }
}
