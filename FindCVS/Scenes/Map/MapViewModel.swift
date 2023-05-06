//
//  MapViewModel.swift
//  FindCVS
//
//  Created by 이주상 on 2023/04/25.
//

import Foundation
import Combine

final class MapViewModel {
    private let network = NetworkService(configuration: .default)
    let fetchedCafes = CurrentValueSubject<[Cafe]?, Never>(nil)
    let currentPoint = CurrentValueSubject<MTMapPoint?, Never>(nil)
    let didTappedCurrentLocationButton = PassthroughSubject<Void, Never>()
    var subscriptions = Set<AnyCancellable>()

    func fetchCafes(mapPoint: MTMapPoint) {
        let params = [
            "category_group_code": "CE7",
            "x": "\(mapPoint.mapPointGeo().longitude)",
            "y": "\(mapPoint.mapPointGeo().latitude)",
            "radius": "500"
        ]
        let headers = ["Authorization": Env.kakaoApiKey]
        let resource = NetworkResource<CategoryMapData>(baseUrl: Constants.categorySearchUrl, params: params, headers: headers)
        network.load(resource)
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    self.fetchedCafes.send(nil)
                    debugPrint("fetch error: \(error)")
                case .finished: break
                }
            } receiveValue: { result in
                self.fetchedCafes.send(result.documents)
            }
            .store(in: &subscriptions)
    }
}
