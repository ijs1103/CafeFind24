//
//  MyProfile.swift
//  FindCVS
//
//  Created by 이주상 on 2023/05/05.
//

import Foundation

typealias ProfileWithImage = (profile: MyProfile, image: UIImage?)
struct MyProfile: Codable {
    var nickname: String
    var imageName: String?
}
