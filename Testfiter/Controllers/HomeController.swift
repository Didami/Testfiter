//
//  HomeController.swift
//  Testfiter
//
//  Created by Didami on 06/08/23.
//

import UIKit

class HomeController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews() {
        view.backgroundColor = .background
        navigationController?.navigationBar.isHidden = true
    }
}
