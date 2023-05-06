//
//  SearchViewModel.swift
//  FindCVS
//
//  Created by 이주상 on 2023/05/03.
//

import Foundation
import Combine

final class SearchViewModel {
    private let network = NetworkService(configuration: .default)
    private let keywordList = [ "이디야", "컴포즈", "할리스", "폴바셋", "빽다방", "커피빈" ]
    var fetchedCafeList = CurrentValueSubject<[Cafe], Never>([])
    var popularKeywordList = CurrentValueSubject<[String], Never>([])
    private var searchKeyword = PassthroughSubject<String, Never>()
    var didTapCafe = PassthroughSubject<Cafe, Never>()
    private var subscriptions = Set<AnyCancellable>()
    init() {
        self.fetchKeywords()
        self.bindSearchKeyword()
    }
}
extension SearchViewModel {
    private func bindSearchKeyword() {
        searchKeyword.debounce(for: 0.17, scheduler: RunLoop.main)
            .compactMap { $0 }
            .sink { [unowned self] keyword in
                self.fetchCafeList(keyword: keyword)
            }.store(in: &subscriptions)
    }
    private func fetchCafeList(keyword: String) {
        let currentLatLong = UserDefaultsManager.getCurrentLatLong()
        let params = [
            "query": keyword,
            "category_group_code": "CE7",
            "x": "\(currentLatLong.long)",
            "y": "\(currentLatLong.lat)",
            "radius": "2000"
        ]
        let headers = ["Authorization": Env.kakaoApiKey]
        let resource = NetworkResource<KeywordMapData>(baseUrl: Constants.keywordSearchUrl, params: params, headers: headers)
        network.load(resource)
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    debugPrint("fetch error: \(error)")
                case .finished: break
                }
            } receiveValue: { result in
                self.fetchedCafeList.send(result.documents)
            }
            .store(in: &subscriptions)
    }
    private func fetchKeywords() {
        popularKeywordList.value = keywordList
    }
    func didChangeSearchText(_ keyword: String) {
        searchKeyword.send(keyword)
    }
}
