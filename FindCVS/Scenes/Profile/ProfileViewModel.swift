//
//  ProfileViewModel.swift
//  FindCVS
//
//  Created by 이주상 on 2023/05/05.
//

import Foundation
import Combine

final class ProfileViewModel {
    private var subscriptions = Set<AnyCancellable>()
    var fetchedProfile = CurrentValueSubject<ProfileWithImage?, Never>(nil)

}
extension ProfileViewModel {
    func fetchProfile() {
        let profile = UserDefaultsManager.getMyProfile()
        fetchedProfile.send(profile)
    }
}
