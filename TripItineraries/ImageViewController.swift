//
//  ImageViewController.swift
//  TripItineraries
//
//  Created by MJ Orton on 5/9/24.
//

import UIKit

class ImageViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var doneButton: UIButton!
    
    var image: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        imageView?.image = image
        
        if let customColor = UIColor(named: "CustomLabelButtonAndTextColor") {
            doneButton.setTitleColor(customColor, for: .normal)
        }
    }
    
    
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
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
