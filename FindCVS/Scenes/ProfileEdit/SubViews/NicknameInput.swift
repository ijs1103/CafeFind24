//
//  NicknameInput.swift
//  FindCVS
//
//  Created by 이주상 on 2023/05/05.
//

import UIKit
import SnapKit

final class NicknameInput: UIView {
    lazy var textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "8자 이내로 설정"
        textField.layer.cornerRadius = 8.0
        textField.layer.borderWidth = 2.0
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 8.0, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        return textField
    }()
    init() {
        super.init(frame: .zero)
        setupViews()
        setupDelegates()
    }
    func updateNickname(_ nickname: String) {
        textField.text = nickname
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
extension NicknameInput {
    private func setupViews() {
        addSubview(textField)
        textField.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.verticalEdges.equalToSuperview()
            $0.height.equalTo(40)
        }
    }
    private func setupDelegates() {
        textField.delegate = self
    }
}

extension NicknameInput: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.layer.borderColor = UIColor.black.cgColor
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.layer.borderColor = UIColor.systemGreen.cgColor
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return false }
        let maxLength = 8
        // 최대 글자수 이상을 입력한 이후에는 중간에 다른 글자를 추가할 수 없음
        if text.count >= maxLength && range.length == 0 && range.location >= maxLength {
            textField.endEditing(true)
            return false
        }
        return true
    }
}
