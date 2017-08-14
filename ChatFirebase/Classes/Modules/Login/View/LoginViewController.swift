//
//  LoginViewController.swift
//  ChatFirebase
//
//  Created by Dmitriy on 13.08.17.
//  Copyright © 2017 GrowApp Solutions. All rights reserved.
//

import UIKit
import PKHUD

class LoginViewController: UIViewController {

    var presenter: LoginPresenter!
    
    @IBOutlet weak var txfNickname: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension LoginViewController {
    @IBAction func buttonLoginTouched(_ button: UIButton) {
        if let nickname = txfNickname.text {
            presenter.startChat(with: nickname)
            
            //  TODO: Save user display name
            UserDefaults.standard.set(nickname, forKey: "username")
            UserDefaults.standard.synchronize()
        }
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension LoginViewController: LoginViewProtocol {
    func startLoading() {
        HUD.show(.progress)
    }
    
    func finishLoading() {
        HUD.hide()
    }
    
    func showError(_ error: Error) {
        print("error: \(error.localizedDescription)")
    }
    
    func loggedInSuccessfully() {
        HUD.flash(.success, delay: 0.5)
    }
}

extension LoginViewController: ViewControllerProtocol {
    static func storyBoardName() -> String {
        return "Login"
    }
}
