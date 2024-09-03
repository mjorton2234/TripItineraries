//
//  ContactViewController.swift
//  TripItineraries
//
//  Created by MJ Orton on 4/23/24.
//

import UIKit
import MessageUI
import CoreLocation

class ContactViewController: UIViewController, UIEditMenuInteractionDelegate, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var tripItinerariesAddressButton: UIButton!
    @IBOutlet weak var tripItinerariesPhoneNumberButton: UIButton!
    @IBOutlet weak var tripItinerariesEmailAddress: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup buttons with long press and edit menu interactions
        setUpLongpressAndEditMenu(for: tripItinerariesAddressButton)
        setUpLongpressAndEditMenu(for: tripItinerariesPhoneNumberButton)
        setUpLongpressAndEditMenu(for: tripItinerariesEmailAddress)
    }

    private func setUpLongpressAndEditMenu(for button: UIButton) {
        // Add long press gesture recognizer
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(buttonLongPressed(_:)))
        button.addGestureRecognizer(longPressGesture)
//        print("Long press gesture added to \(button)")

        // Add edit menu interaction
        let editMenuInteraction = UIEditMenuInteraction(delegate: self)
        button.addInteraction(editMenuInteraction)
//        print("Edit Menu interaction added to \(button)")
    }

    @objc func buttonLongPressed(_ gestureRecognizer: UILongPressGestureRecognizer) {
        // Check the state of the gesture recognizer
        guard gestureRecognizer.state == .began else { return }
        guard let button = gestureRecognizer.view as? UIButton else {
//            print("Gesture recognizer view is not a UIButton")
            return
        }
        
//        print("Button long pressed: \(button)")

        // Manually present the edit menu interaction
        if let interaction = button.interactions.first(where: { $0 is UIEditMenuInteraction }) as? UIEditMenuInteraction {
            interaction.presentEditMenu(with: UIEditMenuConfiguration(identifier: nil, sourcePoint: gestureRecognizer.location(in: button)))
//            print("Presenting Edit Menu for \(button)")
        } else {
//            print("No Edit Menu interaction found for \(button)")
        }
    }

    // MARK: - UIEditMenuInteractionDelegate Methods

    func editMenuInteraction(_ interaction: UIEditMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIEditMenuConfiguration {
//        print("editMenuInteraction: configurationForMenuAtLocation")
        return UIEditMenuConfiguration(identifier: nil, sourcePoint: location)
    }

    func editMenuInteraction(_ interaction: UIEditMenuInteraction, menuFor configuration: UIEditMenuConfiguration, suggestedActions: [UIMenuElement]) -> UIMenu? {
//        print("editMenuInteraction: menuFor configuration \(configuration) with suggestedActions \(suggestedActions)")
        guard let button = interaction.view as? UIButton else {
//            print("interaction.view is not a UIButton")
            return nil
        }

        let copyAction = UIAction(title: "Copy", image: nil) { _ in
            if let text = button.titleLabel?.text, !text.isEmpty {
                UIPasteboard.general.string = text
//                print("Copy action triggered for text: \(text)")
            } else {
//                print("Copy action could not find text or text is empty")
            }
        }
        let menu = UIMenu(title: "", children: [copyAction])
//        print("Returning menu: \(menu)")
        return menu
    }

    // MARK: - Button Actions

    @IBAction func logOutButtonTapped(_ sender: Any) {
        showLogOutAlert(message: "Are you sure you want to log out?")
    }

    @IBAction func tripItinerariesAddressButtonTapped(_ sender: Any) {
        openAddressOptions()
    }

    @IBAction func tripItinerariesPhoneNumberButtonTapped(_ sender: Any) {
        let phoneNumber = "8016716466" // Ensure the number is correctly formatted for the tel:// scheme
        
        // Directly initiate the phone call
        if let phoneURL = URL(string: "tel://\(phoneNumber)"), UIApplication.shared.canOpenURL(phoneURL) {
            UIApplication.shared.open(phoneURL, options: [:], completionHandler: nil)
        } else {
            showAlert(title: "Cannot Make Phone Call", message: "Your device cannot phone calls.")
        }
    }

    @IBAction func tripItinerariesEmailAddressButtonTapped(_ sender: Any) {
        sendEmail()
    }

    // MARK: - Email Methods

    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            mailComposer.setToRecipients(["info@educationsystems.com"])
            mailComposer.setSubject("")
            mailComposer.setMessageBody("", isHTML: false)
            present(mailComposer, animated: true, completion: nil)
        } else {
            showAlert(title: "Cannot Send Email", message: "Your device cannot send emails")
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }

    // MARK: - Alert Methods

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }

    func showLogOutAlert(message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let logOutAlert = UIAlertAction(title: "Log Out", style: .destructive) { _ in
            self.logOut()
        }
        let dismissAlert = UIAlertAction(title: "No", style: .default, handler: nil)

        alertController.addAction(dismissAlert)
        alertController.addAction(logOutAlert)

        present(alertController, animated: true, completion: nil)
    }

    // MARK: - Navigation Methods

    func logOut() {
        if let viewControllers = navigationController?.viewControllers {
            for viewController in viewControllers {
                if let logInViewController = viewController as? LogInViewController {
                    navigationController?.popToViewController(logInViewController, animated: true)
                    return
                }
            }
        }
    }

    // MARK: - Map Handling Methods

    func openInAppleMaps() {
        let address = "5642 W. Sunkist Dr. Kearns, UT 84118"
        if let url = URL(string: "http://maps.apple.com/?address=\(address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func openInGoogleMaps() {
        let googleMapsURL = "https://maps.app.goo.gl/ZHXGJBuhWxjEFQbm7"
        if let url = URL(string: googleMapsURL) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            print("Invalid URL address")
        }
    }
    
    @objc func openAddressOptions() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Open in Apple Maps", style: .default) { _ in
            self.openInAppleMaps()
        })
        
        actionSheet.addAction(UIAlertAction(title: "Open in Google Maps", style: .default) { _ in
            self.openInGoogleMaps()
        })
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        DispatchQueue.main.async {
            self.present(actionSheet, animated: true, completion: nil)
        }
    }
}
