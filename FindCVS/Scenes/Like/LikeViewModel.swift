//
//  LikeViewModel.swift
//  FindCVS
//
//  Created by 이주상 on 2023/05/01.
//

import Foundation
import Combine

final class LikeViewModel {
    
    let likedCafeList: CurrentValueSubject<[likedCafe]?, Never> = CurrentValueSubject(nil)
    
    func updateLikedCafeList() {
        likedCafeList.send(RealmManager.shared.getLikedCafeList())
    }
}
