//
//  DetailViewModel.swift
//  FindCVS
//
//  Created by 이주상 on 2023/04/28.
//

import Foundation
import Combine
import CoreLocation

final class DetailViewModel {
    let cafe: Cafe
    
    var title: String {
        return cafe.title
    }
    var phone: String {
        return cafe.phone != "" ? cafe.phone : "전화번호 미등록" 
    }
    var isPhoneNotExisted: Bool {
        return cafe.phone == ""
    }
    var kakaoUrl: String {
        return cafe.kakaoUrl
    }
    var findPathUrl: String {
        return "https://map.kakao.com/link/to/\(cafe.id)"
    }
    var id: String {
        return cafe.id
    }
    var addressName: String {
        return cafe.addressName
    }
    var category: String {
        return cafe.category
    }
    var currentCoordi: CLLocationCoordinate2D {
        let latLong = UserDefaultsManager.getCurrentLatLong()
        let latitude = latLong.lat
        let longitude = latLong.long
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    var destinationCoordi: CLLocationCoordinate2D {
        guard let latitude = Double(cafe.y), let longitude = Double(cafe.x) else {
            return CLLocationCoordinate2D(latitude: 37.5069760639586, longitude: 126.958134851629)
        }
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    let buttonTapped = PassthroughSubject<MTMapPoint?, Never>()
    let didTappedLike = PassthroughSubject<String, Never>()
    var isLikedCafe: CurrentValueSubject<Bool, Never> = CurrentValueSubject(false)
    var subscriptions = Set<AnyCancellable>()
    
    init(cafe: Cafe) {
        self.cafe = cafe
    }
    
    func updateisLikedCafe() {
        isLikedCafe.send(RealmManager.shared.isLikedCafe(cafe.id))
    }
}
