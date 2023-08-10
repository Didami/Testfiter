//
//  CellComponents.swift
//  Testfiter
//
//  Created by Didami on 07/08/23.
//

import UIKit

// MARK: Home Cell
class HomeCell: UICollectionViewCell {
    
    static let identifier = "HomeCellId"
    
    let label: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textColor = .white
        lbl.font = .mainFont(ofSize: 24, weight: .regular)
        lbl.textAlignment = .left
        lbl.adjustsFontSizeToFitWidth = true
        return lbl
    }()
    
    let separator: UIView = {
        let sep = UIView()
        sep.translatesAutoresizingMaskIntoConstraints = false
        sep.backgroundColor = .luxorGold
        sep.layer.masksToBounds = true
        sep.layer.cornerRadius = 2
        return sep
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    private func setupViews() {
        backgroundColor = .codGray
        layer.masksToBounds = true
        layer.cornerRadius = Constants.cornerRadius
        
        // add subviews
        self.addSubview(label)
        self.addSubview(separator)
        
        // x, y, w, h
        separator.leftAnchor.constraint(equalTo: self.leftAnchor, constant: Constants.standardSpacing).isActive = true
        separator.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -Constants.standardSpacing).isActive = true
        separator.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -Constants.standardSpacing).isActive = true
        separator.heightAnchor.constraint(equalToConstant: 4).isActive = true
        
        label.leftAnchor.constraint(equalTo: separator.leftAnchor).isActive = true
        label.rightAnchor.constraint(equalTo: separator.rightAnchor).isActive = true
        label.topAnchor.constraint(equalTo: self.topAnchor, constant: Constants.standardSpacing).isActive = true
        label.bottomAnchor.constraint(equalTo: separator.topAnchor, constant: -Constants.safeSpacing).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - PATENTED
enum CellState: String {
    case Template
    case Standard
    case Empty
    case Recommended
    case Locked
    case Selected
}

var texturedIcons: [String: [String: UIImage]] = [:]

// MARK: Garment Cell
class GarmentCell: UICollectionViewCell {
    
    static let identifier = "garmentCellId"
    
    var indexPath = IndexPath()
    
    var hasRenderedImage = false
    
    var garment: Garment? {
        didSet {
            setupCell(with: garment)
        }
    }
    
    var cellState: CellState = .Standard {
        didSet {
            setCellState(cellState)
        }
    }
    
    // Top container
    let colorView1 = ColorView()
    let colorView2 = ColorView()
    let colorView3 = ColorView()
    
    lazy var colorsStack: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        sv.distribution = .fillEqually
        sv.spacing = 4
        sv.backgroundColor = .clear
        
        sv.addArrangedSubview(colorView1)
        sv.addArrangedSubview(colorView2)
        sv.addArrangedSubview(colorView3)
        
        return sv
    }()
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.backgroundColor = .clear
        iv.contentMode = .scaleAspectFit
        iv.image = nil
        return iv
    }()
    
    lazy var topContainer: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .clear
        
        container.addSubview(colorsStack)
        container.addSubview(imageView)
        
        colorsStack.leftAnchor.constraint(equalTo: container.leftAnchor, constant: Constants.standardSpacing).isActive = true
        colorsStack.topAnchor.constraint(equalTo: container.topAnchor, constant: Constants.standardSpacing).isActive = true
        colorsStack.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 1/7).isActive = true
        colorsStack.heightAnchor.constraint(equalTo: colorsStack.widthAnchor, multiplier: 3/1, constant: 8).isActive = true
        
        imageView.leftAnchor.constraint(equalTo: colorsStack.rightAnchor, constant: Constants.safeSpacing).isActive = true
        imageView.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -Constants.safeSpacing).isActive = true
        imageView.topAnchor.constraint(equalTo: colorsStack.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -Constants.safeSpacing).isActive = true
        
        return container
    }()
    
    // Bottom container
    let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textColor = .white
        lbl.textAlignment = .right
        lbl.font = .mainFont(ofSize: 21, weight: .light)
        lbl.adjustsFontSizeToFitWidth = true
        lbl.numberOfLines = 0
        return lbl
    }()
    
    let separator: UIView = {
        let cv = UIView()
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .luxorGold
        cv.layer.masksToBounds = true
        cv.layer.cornerRadius = 1.5
        return cv
    }()
    
    lazy var bottomContainer: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .clear
        
        container.addSubview(separator)
        container.addSubview(titleLabel)
        
        separator.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -Constants.standardSpacing).isActive = true
        separator.topAnchor.constraint(equalTo: container.topAnchor, constant: Constants.standardSpacing).isActive = true
        separator.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 1/2).isActive = true
        separator.heightAnchor.constraint(equalToConstant: 2).isActive = true
        
        titleLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
        titleLabel.widthAnchor.constraint(equalTo: container.widthAnchor, constant: -Constants.doubleSpacing).isActive = true
        titleLabel.topAnchor.constraint(equalTo: separator.bottomAnchor, constant: Constants.safeSpacing).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -Constants.standardSpacing).isActive = true
        
        return container
    }()
    
    lazy var disabledView: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .codGray.withAlphaComponent(0.5)
        
        let icon = UIImageView(image: UIImage(named: "raindrops.bold")?.resizedToLargeIcon())
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.contentMode = .scaleAspectFit
        icon.tintColor = .white
        
        container.addSubview(icon)
        
        icon.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
        icon.centerYAnchor.constraint(equalTo: container.centerYAnchor).isActive = true
        icon.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 1/3).isActive = true
        icon.heightAnchor.constraint(equalTo: icon.widthAnchor).isActive = true
        
        return container
    }()
    
    let templateView = TemplateView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        layer.masksToBounds = true
        layer.cornerRadius = Constants.cornerRadius
        
        contentView.backgroundColor = .codGray
        
        disabledView.alpha = 0
        templateView.alpha = 0
        
        // add subviews
        contentView.addSubview(topContainer)
        contentView.addSubview(bottomContainer)
        
        addSubview(disabledView)
        addSubview(templateView)
        
        // x, y, w, h
        topContainer.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        topContainer.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        topContainer.widthAnchor.constraint(equalTo: contentView.widthAnchor).isActive = true
        topContainer.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 9/16).isActive = true
        
        bottomContainer.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        bottomContainer.widthAnchor.constraint(equalTo: contentView.widthAnchor).isActive = true
        bottomContainer.topAnchor.constraint(equalTo: topContainer.bottomAnchor).isActive = true
        bottomContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        
        disabledView.pinToSuperview()
        templateView.pinToSuperview()
    }
    
    private func setCellState(_ state: CellState) {
        
        contentView.alpha = (state == .Standard || state == .Selected) ? 1 : 0
        templateView.alpha = state == .Template ? 1 : 0
        
        if state == .Empty { disabledView.alpha = 0 }
        
        self.backgroundColor = state == .Empty ? .shadyLady.withAlphaComponent(0.1) : .clear
        
        self.layer.borderWidth = (state == .Template || state == .Selected) ? 1 : 0
        self.layer.borderColor = (state == .Template || state == .Selected) ? UIColor.luxorGold.cgColor : nil
    }
    
    private func setupCell(with garment: Garment?) {
        
        if garment == nil { disabledView.alpha = 0 }
        
        if let name = garment?.name, let type = garment?.type, let colors = garment?.hexColors(), let firstColor = colors.first, let mainColor = UIColor(hex: firstColor), let uid = garment?.uid {
            
            if let disabled = garment?.disabled {
                if disabled {
                    disabledView.alpha = 1
                }
            } else {
                disabledView.alpha = 0
            }
            
            titleLabel.text = name
            
            colorView1.color = mainColor
            colorView2.color = UIColor(hex: colors.count > 1 ? colors[1] : "")
            colorView3.color = UIColor(hex: colors.count > 2 ? colors[2] : "")
            
            // Image
            if !hasRenderedImage {
                // Auto mode image
                if let image = LocalImageManager.shared.getSavedImage(uid: uid) {
                    imageView.image = image
                    hasRenderedImage = true
                    return
                }
                
                // Render icon
                var image = UIImage(named: "\(type.rawValue.lowercased())")
                
                guard let pattern = self.garment?.pattern else { return }
                
                if let dict = texturedIcons[type.rawValue], let texturedIcon = dict[pattern.rawValue] {
                    // Textured icon had already been generated.
                    image = texturedIcon
                } else {
                    // Textured icon will be generated.
                    if let maskImage = UIImage(named: "ob_\(pattern.rawValue.lowercased())") {
                        
                        guard let texturedIcon = image?.maskWith(maskImage: maskImage) else { return }
                        
                        if pattern != .Solid {
                            // Add new textured icon to dictionary
                            texturedIcons[type.rawValue] = [pattern.rawValue: texturedIcon]
                            image = texturedIcon
                        }
                    }
                }
                
                imageView.image = image
                hasRenderedImage = true
            }
        }
    }
}

// MARK: - Testing
class ProfileCell: UICollectionViewCell {
    
    static let identifier = "ProfileCellId"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    private func setupViews() {
        self.backgroundColor = .luxorGold
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
