//
//  UserDefaultsManager.swift
//  FindCVS
//
//  Created by 이주상 on 2023/05/04.
//
import Foundation

struct UserDefaultsManager {
    static func getCurrentLatLong() -> LatLong {
        if let result = UserDefaults.standard.object(forKey: "LatLong") as? Data,
           let decoded = try? JSONDecoder().decode(LatLong.self, from: result) {
            return decoded
        } else {
            print("UserDefaults - 디코딩 실패")
            return LatLong(lat: 37.5031934221037, long: 126.948458342683) // 스타벅스 상도역
        }
    }
    static func setCurrentLatLong(latLong: LatLong) {
        if let encoded = try? JSONEncoder().encode(latLong) {
            UserDefaults.standard.set(encoded, forKey: "LatLong")
        } else {
            print("UserDefaults - 인코딩 실패")
        }
    }
    static func getMyProfile() -> ProfileWithImage {
        if let result = UserDefaults.standard.object(forKey: "MyProfile") as? Data,
           let myProfile = try? JSONDecoder().decode(MyProfile.self, from: result) {
            // 프로필 이미지가 존재할때
            if let imageName = myProfile.imageName {
                let image = loadImageFromDocumentDirectory(imageName: imageName)
                return (profile: myProfile, image: image)
            }
            // 프로필 이미지가 없을때
            return (profile: myProfile, image: nil)
        } else {
            // 프로필 초기 세팅
            return (profile: MyProfile(nickname: "Anonymous", imageName: nil), image: nil)
        }
    }
    static func setMyProfile(profileWithImage: ProfileWithImage) {
        // 프로필 이미지가 변경될때
        if let imageName = profileWithImage.profile.imageName, let image = profileWithImage.image {
            saveImageToDocumentDirectory(imageName: imageName, image: image)
        }
        if let encoded = try? JSONEncoder().encode(profileWithImage.profile) {
            UserDefaults.standard.set(encoded, forKey: "MyProfile")
        } else {
            print("UserDefaults - 인코딩 실패")
        }
    }
    static private func saveImageToDocumentDirectory(imageName: String, image: UIImage) {
        // 1. 이미지를 저장할 경로를 설정해줘야함 - 도큐먼트 폴더,File 관련된건 Filemanager가 관리함(싱글톤 패턴)
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        // 2. 이미지 파일 이름 & 최종 경로 설정
        let imageURL = documentDirectory.appendingPathComponent(imageName)
        // 3. 이미지 압축(image.pngData())
        // 압축할거면 jpegData로~(0~1 사이 값)
        guard let data = image.pngData() else {
            print("압축을 실패했습니다.")
            return
        }
        // 4. 이미지 저장: 동일한 경로에 이미지를 저장하게 될 경우, 덮어쓰기하는 경우
        // 4-1. 이미지 경로 여부 확인
        if FileManager.default.fileExists(atPath: imageURL.path) {
            // 4-2. 이미지가 존재한다면 기존 경로에 있는 이미지 삭제
            do {
                try FileManager.default.removeItem(at: imageURL)
                print("이미지 삭제 완료")
            } catch {
                print("이미지를 삭제하지 못했습니다.")
            }
        }
        // 5. 이미지를 도큐먼트에 저장
        do {
            try data.write(to: imageURL)
            print("이미지 저장완료")
        } catch {
            print("이미지를 저장하지 못했습니다.")
        }
    }
    static private func loadImageFromDocumentDirectory(imageName: String) -> UIImage? {
        // 1. 도큐먼트 폴더 경로가져오기
        let documentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let path = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomainMask, true)
        
        if let directoryPath = path.first {
            // 2. 이미지 URL 찾기
            let imageURL = URL(fileURLWithPath: directoryPath).appendingPathComponent(imageName)
            // 3. UIImage로 불러오기
            return UIImage(contentsOfFile: imageURL.path)
        }
        return nil
    }
}
