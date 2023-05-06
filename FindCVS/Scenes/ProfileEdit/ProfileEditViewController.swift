//
//  ProfileEditViewController.swift
//  FindCVS
//
//  Created by 이주상 on 2023/05/05.
//

import UIKit
import SnapKit
import Combine

final class ProfileEditViewController: UIViewController {
    private let viewModel = ProfileEditViewModel()
    private var subscriptions = Set<AnyCancellable>()
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.tintColor = .gray
        imageView.layer.borderColor = UIColor.brown.cgColor
        imageView.layer.borderWidth = 2.0
        imageView.layer.cornerRadius = 50
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapImageView))
        imageView.addGestureRecognizer(tapGestureRecognizer)
        return imageView
    }()
    private lazy var imagePickerController: UIImagePickerController = {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        return imagePickerController
    }()
    private lazy var nicknameLabel: UILabel = {
        let label = UILabel()
        label.text = "닉네임"
        label.font = .systemFont(ofSize: 14.0, weight: .bold)
        return label
    }()
    private lazy var nicknameInput = NicknameInput()
    // 유저가 앨범에서 이미지를 select하였거나 프로필 이미지를 이미 가지고 있으면 true, 기본 프로필 이미지이면 false인 변수
    private var isImagePicked = false
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupViews()
        bind()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchProfile()
    }
}
extension ProfileEditViewController {
    private func setupNavigation() {
        navigationItem.title = "프로필 수정"
        navigationItem.backButtonTitle = nil
        let rightBarButtonItem = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(didTapDoneButton))
        rightBarButtonItem.tintColor = .brown
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    private func setupViews() {
        view.backgroundColor = .secondarySystemBackground
        [imageView, nicknameLabel, nicknameInput].forEach {
            view.addSubview($0)
        }
        imageView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(32.0)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(100)
        }
        nicknameLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(32.0)
            $0.leading.equalToSuperview().inset(16.0)
        }
        nicknameInput.snp.makeConstraints {
            $0.top.equalTo(nicknameLabel.snp.bottom).offset(16.0)
            $0.leading.trailing.equalToSuperview().inset(16.0)
        }
    }
    private func bind() {
        viewModel.fetchedProfile
            .receive(on: RunLoop.main)
            .sink { [unowned self] result in
                if result?.image != nil {
                    self.isImagePicked = true
                }
                self.imageView.image = result?.image ?? UIImage(systemName: "person.fill")!
                self.nicknameInput.updateNickname(result?.profile.nickname ?? "Anonymous")
                
            }.store(in: &subscriptions)
    }
    @objc private func didTapImageView() {
        present(imagePickerController, animated: true)
    }
    @objc private func didTapDoneButton() {
        guard let nickname = nicknameInput.textField.text else { return }
        viewModel.saveProfile(nickname: nickname, image: isImagePicked ? imageView.image : nil)
        navigationController?.popViewController(animated: true)
    }
}

extension ProfileEditViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        var resizedImage: UIImage?
            
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            resizedImage = editedImage.resize(image: editedImage, newWidth: 100)
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            resizedImage = originalImage.resize(image: originalImage, newWidth: 100)
        }
        
        picker.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.imageView.image = resizedImage
            self.isImagePicked = true
        }
    }
}
