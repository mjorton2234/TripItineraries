//
//  HomeViewController.swift
//  TripItineraries
//
//  Created by MJ Orton on 4/23/24.
//

import UIKit

class HomeViewController: UIViewController {
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBarAppearance()

        // Do any additional setup after loading the view.
        
        let tapGestureForPurposeImage = UITapGestureRecognizer(target: self, action: #selector(purposeImageTapped))
        purposeImage.addGestureRecognizer(tapGestureForPurposeImage)
        purposeImage.isUserInteractionEnabled = true
        
        let tapGestureForItinerariesImage = UITapGestureRecognizer(target: self, action: #selector(itinerariesImageTapped))
        itinerariesImage.addGestureRecognizer(tapGestureForItinerariesImage)
        itinerariesImage.isUserInteractionEnabled = true
    }
    
    @IBOutlet weak var purposeImage: UIImageView!
    @IBOutlet weak var itinerariesImage: UIImageView!
    
    func setupTabBarAppearance() {
        if let tabBar = tabBarController?.tabBar {
            tabBar.backgroundImage = UIImage()
            tabBar.shadowImage = UIImage()
            tabBar.isTranslucent = true
            tabBar.backgroundColor = .clear
        }
    }
    
    @objc func purposeImageTapped() {
        presentImageModaly(image: purposeImage.image)
    }
    
    @objc func itinerariesImageTapped() {
        presentImageModaly(image: itinerariesImage.image)
    }
    
    
    func presentImageModaly(image: UIImage?) {
        if let imageViewController = storyboard?.instantiateViewController(withIdentifier: "ShowImages") as? ImageViewController {
            imageViewController.image = image
            imageViewController.modalPresentationStyle = .custom
            imageViewController.transitioningDelegate = self
            present(imageViewController, animated: true, completion: nil)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension HomeViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return DismissableFullScreenPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
