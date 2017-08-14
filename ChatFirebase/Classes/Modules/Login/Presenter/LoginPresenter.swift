//
//  LoginPresenter.swift
//  ChatFirebase
//
//  Created by Dmitriy on 13.08.17.
//  Copyright © 2017 GrowApp Solutions. All rights reserved.
//

import Foundation

protocol LoginViewProtocol {
    func startLoading()
    func finishLoading()
    
    func loggedInSuccessfully()
    func showError(_ error: Error)
}

class LoginPresenter {
    var view: LoginViewProtocol!
    
    func startChat(with nickname: String) {
        auth(nickname) { (token, error) in
            if error == nil {
                Router.shared.openChannels()
            }
            else {
                self.view.showError(error!)
            }
        }
    }
}

private extension LoginPresenter {
    func auth(_ nickname: String, completion: @escaping (String?, Error?) -> ()) {
        view.startLoading()
        ChatManager.shared.login(nickname) { [weak self] (token, error) in
            self?.view.finishLoading()
            if let error = error {
                self?.view.showError(error)
            }
            else {
                self?.view.loggedInSuccessfully()
            }
            completion(token, error)
        }
    }
}
