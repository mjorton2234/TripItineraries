//
//  PDFViewController.swift
//  TripItineraries
//
//  Created by MJ Orton on 5/18/24.
//


import UIKit
import PDFKit

class PDFViewController: UIViewController {

    var pdfView: PDFView!
    var pdfURL: URL?
    var username: String = "mjorton22"
    var password: String = "mo3om21"
    var scrollView: UIScrollView?
    var isNavigationBarVisible = true
    var defaultScaleFactor: CGFloat = 1.0
    private var pinchGestureScale: CGFloat = 1.0

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpPDFView()
        addTapGestureRecognizer()
        addPinchGestureRecognizer()

        if let url = pdfURL {
            fetchPDF(url: url) { [weak self] document in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    if let document = document {
                        if document.isLocked {
                            let unlockSucceeded = document.unlock(withPassword: self.password)
                            if !unlockSucceeded {
//                                print("Failed to unlock PDF with provided password")
                            }
                        }
                        self.pdfView.document = document
//                        self.pdfView.scaleFactor = 1.0
                        self.defaultScaleFactor = self.pdfView.scaleFactor
//                        print("Adjusted default scale factor set to: \(self.defaultScaleFactor)")
                    } else {
//                        print("Failed to load PDF")
                    }
                }
            }
        } else {
//            print("Invalid PDF URL")
        }

        // Set up Done button in default navigation bar
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "TrebuchetMS-Bold", size: 17)!,
            .foregroundColor: UIColor(red: 4/255, green: 55/255, blue: 84/255, alpha: 1)
        ]
        doneButton.setTitleTextAttributes(attributes, for: .normal)
        self.navigationItem.leftBarButtonItem = doneButton

        // Customize navigation bar appearance
        configureNavigationBarAppearance()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        configureNavigationBarAppearance()
    }

    func configureNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 232/255, alpha: 1)
        appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(red: 4/255, green: 55/255, blue: 84/255, alpha: 1)]
        appearance.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(red: 4/255, green: 55/255, blue: 84/255, alpha: 1)]

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance

        navigationController?.navigationBar.tintColor = UIColor(red: 4/255, green: 55/255, blue: 84/255, alpha: 1)
    }

    func setUpPDFView() {
        pdfView = PDFView(frame: self.view.bounds)
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.usePageViewController(true, withViewOptions: nil)
        self.view.addSubview(pdfView)

        pdfView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pdfView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            pdfView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            pdfView.topAnchor.constraint(equalTo: self.view.topAnchor),
            pdfView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }

    @objc func doneButtonTapped() {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }

    func addTapGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        pdfView.addGestureRecognizer(tapGestureRecognizer)
    }

    @objc func handleTap() {
        isNavigationBarVisible.toggle()
        self.navigationController?.setNavigationBarHidden(!isNavigationBarVisible, animated: true)
    }

    func addPinchGestureRecognizer() {
//        print("addPinchGestureRecognizer() called")
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        pdfView.addGestureRecognizer(pinchGestureRecognizer)
    }
    
    @objc func handlePinch(_ gestureRecognizer: UIPinchGestureRecognizer) {
//        print("Pinch gesture state: \(gestureRecognizer.state.rawValue)")
        guard let pdfView = self.pdfView else {
//            print("PDFView is nil")
            return
        }
        
        switch gestureRecognizer.state {
        case .began:
//            print("Pinch gesture began")
            pinchGestureScale = pdfView.scaleFactor
        case .changed:
//            print("Pinch gesture changed")
            let newScale = pinchGestureScale * gestureRecognizer.scale
            pdfView.scaleFactor = newScale
        case .ended:
//            print("Pinch gesture ended")
            if pdfView.scaleFactor < self.defaultScaleFactor {
                animateScaleToDefault()
            }
        default:
            break
        }
        gestureRecognizer.scale = 1.0
    }
    
    func animateScaleToDefault() {
        guard let pdfView = self.pdfView else { return }
        
        UIView.animate(withDuration: 0.3) {
//            print("Animating scale to default")
            pdfView.scaleFactor = self.defaultScaleFactor
//            print("Current scale factor after animation: \(pdfView.scaleFactor)")
        }
    }

    func fetchPDF(url: URL, completion: @escaping (PDFDocument?) -> Void) {
        var request = URLRequest(url: url)
        let loginString = "\(username):\(password)"
        guard let loginData = loginString.data(using: .utf8) else {
            completion(nil)
            return
        }
        let base64LoginString = loginData.base64EncodedString()
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching PDF: \(error.localizedDescription)")
                completion(nil)
                return
            }
            guard let data = data else {
//                print("No data returned from PDF fetch")
                completion(nil)
                return
            }
            let document = PDFDocument(data: data)
            if document == nil {
//                print("Failed to create PDFDocument from data")
            }
            completion(document)
        }
        task.resume()
    }
}
