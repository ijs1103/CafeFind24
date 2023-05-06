//
//  ProfileEditViewModel.swift
//  FindCVS
//
//  Created by 이주상 on 2023/05/05.
//

import Foundation
import Combine

final class ProfileEditViewModel {
    private var subscriptions = Set<AnyCancellable>()
    var fetchedProfile = CurrentValueSubject<ProfileWithImage?, Never>(nil)

}
extension ProfileEditViewModel {
    func fetchProfile() {
        let profile = UserDefaultsManager.getMyProfile()
        fetchedProfile.send(profile)
    }
    func saveProfile(nickname: String, image: UIImage?) {
        let ProfileWithImage: ProfileWithImage
        if let image = image {
            let imageName = "\(image)\(Date())"
            ProfileWithImage = (profile: MyProfile(nickname: nickname, imageName: imageName) , image: image)
        } else {
            ProfileWithImage = (profile: MyProfile(nickname: nickname, imageName: nil) , image: nil)
        }
        UserDefaultsManager.setMyProfile(profileWithImage: ProfileWithImage)
    }
}
