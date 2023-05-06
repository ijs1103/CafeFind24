//
//  RealmManager.swift
//  FindCVS
//
//  Created by 이주상 on 2023/04/28.
//

import Foundation
import RealmSwift

struct RealmManager {
    static let shared = RealmManager()
    let realm = try! Realm()
    private init() {}
    func isLikedCafe(_ cafeId: String) -> Bool {
        let isLiked = realm.objects(likedCafe.self).where {
            $0.id == cafeId
        }
        return isLiked.count > 0
    }
    func addLikedCafe(_ cafe: likedCafe) {
        try! realm.write {
            realm.add(cafe)
        }
    }
    func getLikedCafeList() -> [likedCafe] {
        let likedCafeList = realm.objects(likedCafe.self).sorted(byKeyPath: "title")
        return Array(likedCafeList)
    }
    func deleteLikeCafe(id: String) {
        let toDelete = realm.objects(likedCafe.self).where {
            $0.id == id
        }
        try! realm.write {
            realm.delete(toDelete)
        }
    }
}
class likedCafe: Object {
    @Persisted var id = ""
    @Persisted var title = ""
    @Persisted var addressName = ""
    @Persisted var kakaoUrl = ""
    @Persisted var findPathUrl = ""
    
    convenience init(id: String, title: String, addressName: String, kakaoUrl: String, findPathUrl: String) {
        self.init()
        self.id = id
        self.title = title
        self.addressName = addressName
        self.kakaoUrl = kakaoUrl
        self.findPathUrl = findPathUrl
    }
}

