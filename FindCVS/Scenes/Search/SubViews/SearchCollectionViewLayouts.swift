//
//  SearchCollectionViewLayouts.swift
//  FindCVS
//
//  Created by 이주상 on 2023/05/03.
//

import UIKit

struct SearchCollectionViewLayouts {
    private var pupularSearchKeywordLayout: NSCollectionLayoutSection {
        let smallWidth = UIScreen.main.bounds.width <= 350
        let offset = smallWidth ? 15.0 : 20.0
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.17),
                                               heightDimension: .estimated(40))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                       subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [.init(
            layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(40)),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .topLeading
        )]
        section.orthogonalScrollingBehavior = .groupPaging
        section.contentInsets = .init(top: 5, leading: offset, bottom: 15, trailing: offset)
        section.interGroupSpacing = 20
        return section
    }
    
    private var searchResultLayout: NSCollectionLayoutSection {
        let smallWidth = UIScreen.main.bounds.width <= 350
        let offset = smallWidth ? 15.0 : 20.0
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .estimated(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .estimated(100))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [.init(
            layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(40)),
            elementKind: UICollectionView.elementKindSectionHeader, alignment: .topLeading
        )]
        section.contentInsets = .init(top: 10, leading: offset, bottom: 10, trailing: offset)
        return section
    }
    
    func section(at sectionNumber: Int) -> NSCollectionLayoutSection {
        switch sectionNumber {
        case 0:
            return pupularSearchKeywordLayout
        case 1:
            return searchResultLayout
        default:
            return pupularSearchKeywordLayout
        }
    }
}
