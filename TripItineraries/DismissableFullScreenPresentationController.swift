//
//  DismissableFullScreenPresentationController.swift
//  TripItineraries
//
//  Created by MJ Orton on 5/18/24.
//

import UIKit

class DismissableFullScreenPresentationController: UIPresentationController {
    
    private var dimmingView: UIView!
    private var panGestureRecognizer: UIPanGestureRecognizer!
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_ :)))
        presentedViewController.view.addGestureRecognizer(panGestureRecognizer)
    }
    
    override var shouldPresentInFullscreen: Bool {
        return true
    }
    
    override var presentationStyle: UIModalPresentationStyle {
        return .fullScreen
    }
    
    override func presentationTransitionWillBegin() {
        guard let containerView = containerView else {return}
        
        dimmingView = UIView(frame: containerView.bounds)
        dimmingView.backgroundColor = UIColor(white: 0.0, alpha: 0.1)
        containerView.addSubview(dimmingView)
        
        dimmingView.alpha = 0.0
        presentingViewController.transitionCoordinator?.animate(alongsideTransition: { _ in self.dimmingView.alpha = 0.2
        })
    }
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: presentedView)
        switch gesture.state {
        case .changed:
            if translation.y > 0 {
                presentedView?.transform = CGAffineTransform(translationX: 0, y: translation.y)
            }
        case .ended:
            let velosity = gesture.velocity(in: presentedView).y
            
            if translation.y > presentedView!.frame.height / 2 || velosity > 1000 {
                presentedViewController.dismiss(animated: true, completion: nil)
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.presentedView?.transform = .identity
                }
            }
        default:
            break
        }
    }
}
