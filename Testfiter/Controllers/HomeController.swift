//
//  HomeController.swift
//  Testfiter
//
//  Created by Didami on 06/08/23.
//

import UIKit

struct Functionality {
    var name: String
    var controller: UIViewController
}

class HomeController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    let functionalities: [Functionality] = [
        .init(name: "Garment Viewer", controller: GarmentsController()),
        .init(name: "Profile", controller: ProfileController())
    ]
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = Constants.standardSpacing
        layout.minimumInteritemSpacing = Constants.standardSpacing
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .clear
        
        cv.delegate = self
        cv.dataSource = self
        cv.register(HomeCell.self, forCellWithReuseIdentifier: HomeCell.identifier)
        
        return cv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews() {
        view.backgroundColor = .background
        navigationController?.navigationBar.isHidden = true
        
        // add subviews
        view.addSubview(collectionView)
        
        // x, y, w, h
        collectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        collectionView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    // MARK: - Delegate methods
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return functionalities.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width - Constants.standardSpacing, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeCell.identifier, for: indexPath) as? HomeCell else { return UICollectionViewCell() }
        cell.label.text = functionalities[indexPath.item].name
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = functionalities[indexPath.item].controller
        navigationController?.pushViewController(vc, animated: true)
    }
}
