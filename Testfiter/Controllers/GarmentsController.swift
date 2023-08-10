//
//  GarmentsController.swift
//  Testfiter
//
//  Created by Didami on 07/08/23.
//

import UIKit

class GarmentsController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    var garments = [Garment]()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = Constants.standardSpacing
        layout.minimumInteritemSpacing = Constants.standardSpacing
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .clear
        cv.showsVerticalScrollIndicator = false
        
        cv.delegate = self
        cv.dataSource = self
        cv.register(GarmentCell.self, forCellWithReuseIdentifier: GarmentCell.identifier)
        
        return cv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchGarments()
        setupViews()
    }
    
    private func setupViews() {
        view.backgroundColor = .background
        
        // add subviews
        view.addSubview(collectionView)
        
        // x, y, w, h
        collectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        collectionView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -Constants.standardSpacing).isActive = true
        collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    // MARK: - Methods
    private func fetchGarments() {
        
        UserDefaultsManager.shared.fetchGarments { [self] result in
            
            switch result {
            case .success(let fetched):
                
                garments = fetched.sorted(by: { garment1, garment2 in
                    
                    guard let name1 = garment1.name, let name2 = garment2.name, let type1 = garment1.type, let type2 = garment2.type, let dressCode1 = garment1.dressCode?.first, let dressCode2 = garment2.dressCode?.first, let color1 = garment1.mainColor, let color2 = garment2.mainColor, let uid1 = garment1.uid, let uid2 = garment2.uid else {
                        return false
                    }
                    
                    return type1 == type2 ? (dressCode1 == dressCode2 ? (name1 == name2 ? color1 < color2 : name1 < name2) : (dressCode1 == dressCode2) ? uid1 < uid2 : dressCode1 < dressCode2) : type1 < type2
                })
                
                garments.sort(by: { !($0.disabled ?? false) && ($1.disabled ?? false) })
                collectionView.reloadData()
                
            case .failure(let err):
                print(err)
            }
        }
    }
    
    // MARK: - Delegate methods
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return garments.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.size.width - Constants.standardSpacing) / 2
        return CGSize(width: width, height: width * 1.5)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GarmentCell.identifier, for: indexPath) as? GarmentCell else { return UICollectionViewCell() }
        cell.indexPath = indexPath
        cell.hasRenderedImage = false
        cell.garment = garments[indexPath.item]
        cell.cellState = .Standard
        return cell
    }
}
