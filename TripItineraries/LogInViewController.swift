//
//  LogInViewController.swift
//  TripItineraries
//
//  Created by MJ Orton on 4/23/24.
//


import UIKit

class LogInViewController: UIViewController, UITextFieldDelegate {

    var isPasswordVisible = false
    let customTextFieldColor = UIColor(red: 15/255, green: 55/255, blue: 84/255, alpha: 1)

    override func viewDidLoad() {
        super.viewDidLoad()


        userNameTextField.delegate = self
        passwordTextField.delegate = self
        
        userNameTextField.textColor = customTextFieldColor
        passwordTextField.textColor = customTextFieldColor
        
        userNameTextField.attributedPlaceholder = NSAttributedString(
            string: userNameTextField.placeholder ?? "Username",
            attributes: [NSAttributedString.Key.foregroundColor: customTextFieldColor]
        )
        passwordTextField.attributedPlaceholder = NSAttributedString(
            string: passwordTextField.placeholder ?? "Password",
            attributes: [NSAttributedString.Key.foregroundColor: customTextFieldColor]
        )

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)

        setupTogglePasswordButton()
//        setDynamicColors() // Call to set colors
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var togglePasswordButton: UIButton!

    @IBAction func logInButtonTapped(_ sender: UIButton) {

        if userNameTextField.text == "ADD USERNAME HERE" && passwordTextField.text == "ADD PASSWORD HERE" {
            userNameTextField.text = ""
            passwordTextField.text = ""

            performSegue(withIdentifier: "LogIn", sender: self)
        } else {
            showAlert(message: "Invalid Username or Password")
        }
//        print("Log In Successful")
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == userNameTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            textField.resignFirstResponder()
        }
        return true
    }

    func showAlert(message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let dismissAlert = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(dismissAlert)
        present(alertController, animated: true, completion: nil)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    func setupTogglePasswordButton() {
        togglePasswordButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
    }

    @objc func togglePasswordVisibility() {
        isPasswordVisible.toggle()
        passwordTextField.isSecureTextEntry = !isPasswordVisible

        let buttonImageName = isPasswordVisible ? "eye.slash" : "eye"
        togglePasswordButton.setImage(UIImage(systemName: buttonImageName), for: .normal)
    }

//    func setDynamicColors() {
//        let customColor = UIColor.customTextFieldColor
//
//        // Set text color
//        userNameTextField.textColor = customColor
//        passwordTextField.textColor = customColor
//
//        // Set placeholder color dynamically
//        let placeholderAttributes: [NSAttributedString.Key: Any] = [
//            .foregroundColor: customColor.withAlphaComponent(0.7)
//        ]
//
//        userNameTextField.attributedPlaceholder = NSAttributedString(
//            string: userNameTextField.placeholder ?? "Username",
//            attributes: placeholderAttributes
//        )
//
//        passwordTextField.attributedPlaceholder = NSAttributedString(
//            string: passwordTextField.placeholder ?? "Password",
//            attributes: placeholderAttributes
//        )
//    }
}

//extension UIColor {
//    static let customTextFieldColor = UIColor(red: 15/255, green: 55/255, blue: 84/255, alpha: 1)
//}
