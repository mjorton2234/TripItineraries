//
//  AboutUsViewController.swift
//  TripItineraries
//
//  Created by MJ Orton on 5/1/24.
//

import UIKit

class AboutUsViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var deonnaImage: UIImageView!
    @IBOutlet weak var clarissaImage: UIImageView!
    @IBOutlet weak var rebeccaImage: UIImageView!
    @IBOutlet weak var mjImage: UIImageView!
    
    @IBOutlet weak var aboutUsLabel: UILabel!
    @IBOutlet weak var tripItinerariesLabel: UILabel!
    @IBOutlet weak var deonnaLabel: UILabel!
    @IBOutlet weak var clarissaLabel: UILabel!
    @IBOutlet weak var rebeccaLabel: UILabel!
    @IBOutlet weak var mjLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        let tapGestureForDeonnaImage = UITapGestureRecognizer(target: self, action: #selector(deonnaImageTapped))
        deonnaImage.addGestureRecognizer(tapGestureForDeonnaImage)
        deonnaImage.isUserInteractionEnabled = true
        
        let tapGestureForClarissaImage = UITapGestureRecognizer(target: self, action: #selector(clarissaImageTapped))
        clarissaImage.addGestureRecognizer(tapGestureForClarissaImage)
        clarissaImage.isUserInteractionEnabled = true
        
        let tapGestureForRebeccaImage = UITapGestureRecognizer(target: self, action: #selector(rebeccaImageTapped))
        rebeccaImage.addGestureRecognizer(tapGestureForRebeccaImage)
        rebeccaImage.isUserInteractionEnabled = true
        
        let tapGestureForMjImage = UITapGestureRecognizer(target: self, action: #selector(mjImageTapped))
        mjImage.addGestureRecognizer(tapGestureForMjImage)
        mjImage.isUserInteractionEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        adjustScrollViewContentHeight()
    }
    
    @objc func deonnaImageTapped() {
        presentImageModally(image: deonnaImage.image)
    }
    
    @objc func clarissaImageTapped() {
        presentImageModally(image: clarissaImage.image)
    }
    
    @objc func rebeccaImageTapped() {
        presentImageModally(image: rebeccaImage.image)
    }
    
    @objc func mjImageTapped() {
        presentImageModally(image: mjImage.image)
    }
    
    func presentImageModally(image: UIImage?) {
        if let imageViewController = storyboard?.instantiateViewController(withIdentifier: "ShowImages") as? ImageViewController {
            imageViewController.image = image
            imageViewController.modalPresentationStyle = .custom
            imageViewController.transitioningDelegate = self
            present(imageViewController, animated: true, completion: nil)
        }
    }
    
    func adjustScrollViewContentHeight() {
        var adjustment: CGFloat = 0
        
        // Get the screen height
        let screenHeight = UIScreen.main.bounds.height
        
        // Check for Plus/Max models by matching a range of screen heights
        if screenHeight >= 2778 && screenHeight <= 2796 {
            adjustment = -100 // Reduce height by 100 points for Plus/Max models
        }
        
        // Apply the adjustment
        scrollView.contentSize.height += adjustment
    }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        
//        // Calculate maxY positions of relevant views
//        let deonnaMaxY = deonnaLabel.frame.maxY
//        let tripItinerariesMinY = tripItinerariesLabel.frame.minY
//        
//        // Calculate content height including necessary padding
//        let contentHeight = max(tripItinerariesMinY + 20, scrollView.bounds.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom)
//        
//        // Set scrollView's content size based on calculated content height
//        scrollView.contentSize = CGSize(width: scrollView.bounds.width, height: contentHeight)
//        
//        // Ensure scrollView's contentInset accounts for safe area
//        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: view.safeAreaInsets.bottom, right: 0)
//    }

    // Uncomment this section if needed
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension AboutUsViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return DismissableFullScreenPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
