//
//  ActivityIndicatorViewController.swift
//  ParkingLot
//
//  Created by Никита Данилович on 10.07.2023.
//

import UIKit

class ActivityIndicatorViewController: UIViewController {
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(frame: self.view.bounds)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = true
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .large
        activityIndicator.color = CustomSystemColors.primary
        return activityIndicator
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black.withAlphaComponent(Transparency.semi)
        view.addSubview(activityIndicator)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.activityIndicator.startAnimating()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.activityIndicator.stopAnimating()
    }
}
