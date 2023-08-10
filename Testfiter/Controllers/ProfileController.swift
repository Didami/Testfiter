//
//  ProfileController.swift
//  Testfiter
//
//  Created by Didami on 07/08/23.
//

import UIKit

public enum ProfileSection: String, CaseIterable {
    case OOTD
    case Outfits
    case Garments
    
    var index: Int {
        return self == .Outfits ? 1 : self == .Garments ? 2 : 0
    }
}

func profileSectionForIndex(_ index: Int) -> ProfileSection {
    return index == 1 ? .Outfits : index == 2 ? .Garments : .OOTD
}

class ProfileController: UIViewController, UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.backgroundColor = .luxorGold
        return iv
    }()
    
    lazy var segmentedControl: PlainSegmentedControl = {
        let sc = PlainSegmentedControl(items: ProfileSection.allCases.map({ $0.rawValue.localized() }))
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.selectedSegmentIndex = 0
        sc.addTarget(self, action: #selector(handleSegmentedControl(_:)), for: .valueChanged)
        return sc
    }()
    
    lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: profileCollectionViewLayout())
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .clear
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.isPagingEnabled = true
        
        cv.delegate = self
        cv.dataSource = self
        cv.register(ProfileCell.self, forCellWithReuseIdentifier: ProfileCell.identifier)
        cv.register(GarmentCell.self, forCellWithReuseIdentifier: GarmentCell.identifier)
        
        return cv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchGarments()
        setupViews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        profileImageView.circleView()
    }
    
    private func setupViews() {
        view.backgroundColor = .codGray
        
        let shadowContainer = UIView()
        shadowContainer.translatesAutoresizingMaskIntoConstraints = false
        shadowContainer.backgroundColor = .background
        shadowContainer.addTopShadow(shadowColor: .black, shadowOpacity: 0.7, shadowRadius: 10, offset: CGSize(width: 0, height: -5))
        
        // add subview
        view.addSubview(shadowContainer)
        view.addSubview(profileImageView)
        
        shadowContainer.addSubview(segmentedControl)
        shadowContainer.addSubview(collectionView)
        
        // x, y, w, h
        shadowContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        shadowContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        shadowContainer.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        shadowContainer.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 3/4).isActive = true
        
        segmentedControl.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: -Constants.safeSpacing).isActive = true
        segmentedControl.rightAnchor.constraint(equalTo: shadowContainer.rightAnchor).isActive = true
        segmentedControl.topAnchor.constraint(equalTo: shadowContainer.topAnchor, constant: Constants.standardSpacing).isActive = true
        segmentedControl.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        collectionView.centerXAnchor.constraint(equalTo: shadowContainer.centerXAnchor).isActive = true
        collectionView.widthAnchor.constraint(equalTo: shadowContainer.widthAnchor, constant: -Constants.standardSpacing).isActive = true
        collectionView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: Constants.safeSpacing).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: shadowContainer.bottomAnchor).isActive = true
        
        profileImageView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: Constants.standardSpacing).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: shadowContainer.topAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.25).isActive = true
        profileImageView.heightAnchor.constraint(equalTo: profileImageView.widthAnchor).isActive = true
    }
    
    var garments = [Garment]()
    var profile: Profile?
    
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
                profile = Profile(name: "TEST", garments: garments, outfits: [], uid: "test")
                collectionView.reloadData()
                
            case .failure(let err):
                print(err)
            }
        }
    }
    
    // MARK: - @objc selectors
    @objc private func handleSegmentedControl(_ sender: UISegmentedControl) {
        collectionView.scrollToItem(at: IndexPath(item: 0, section: sender.selectedSegmentIndex), at: .centeredHorizontally, animated: true)
    }
    
    // MARK: - Delegate methods
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == collectionView {
            segmentedControl.selectedSegmentIndex = Int(scrollView.contentOffset.x / scrollView.frame.width)
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return ProfileSection.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch profileSectionForIndex(section) {
        case .OOTD:
            return 1
        case .Outfits:
            return 1
        case .Garments:
            return garments.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch profileSectionForIndex(indexPath.section) {
        case .OOTD:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfileCell.identifier, for: indexPath) as? ProfileCell else { return UICollectionViewCell() }
            return cell
        case .Outfits:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfileCell.identifier, for: indexPath) as? ProfileCell else { return UICollectionViewCell() }
            return cell
        case .Garments:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GarmentCell.identifier, for: indexPath) as? GarmentCell else { return UICollectionViewCell() }
            cell.indexPath = indexPath
            cell.hasRenderedImage = false
            cell.garment = garments[indexPath.item]
            cell.cellState = .Standard
            return cell
        }
    }
}

public func profileCollectionViewLayout() -> UICollectionViewCompositionalLayout {
    
    let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
        
        let sectionType = profileSectionForIndex(sectionIndex)
        
        // Items
        let item: NSCollectionLayoutItem!
        
        if sectionType == .Garments {
            let width = (layoutEnvironment.container.contentSize.width - (Constants.standardSpacing * 2)) / 2
            item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .absolute(width),
                    heightDimension: .absolute(width * 1.5)
                )
            )
        } else {
            item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalHeight(1)
                )
            )
        }
        
        // Groups
        let group: NSCollectionLayoutGroup!
        
        if sectionType == .Garments {
            let height = (layoutEnvironment.container.contentSize.height - (Constants.standardSpacing * 2)) / 2
            group = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(height)),
                subitems: [item]
            )
        } else {
            group = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalHeight(1)),
                subitems: [item]
            )
        }
        
        group.contentInsets = NSDirectionalEdgeInsets(top: Constants.safeSpacing, leading: Constants.safeSpacing, bottom: Constants.safeSpacing, trailing: Constants.safeSpacing)
        group.interItemSpacing = .fixed(Constants.standardSpacing)
        
        // Sections
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = Constants.standardSpacing
        section.contentInsets = .zero
        
        return section
    }
    
    let config = UICollectionViewCompositionalLayoutConfiguration()
    config.scrollDirection = .horizontal
    
    layout.configuration = config
    
    return layout
}
