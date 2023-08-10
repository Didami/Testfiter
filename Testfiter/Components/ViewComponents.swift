//
//  ViewComponents.swift
//  Testfiter
//
//  Created by Didami on 07/08/23.
//

import UIKit

// MARK: - PATENTED
// MARK: - Template View
class TemplateView: UIView {
    
    let icon: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "plus.bold")?.resizedToIcon())
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .luxorGold
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    private func setupViews() {
        // add subviews
        addSubview(icon)
        
        // x, y, w, h
        icon.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        icon.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        icon.widthAnchor.constraint(equalToConstant: 30).isActive = true
        icon.heightAnchor.constraint(equalTo: icon.widthAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Color View
class ColorView: UIView {
    
    var color: UIColor? {
        didSet {
            self.backgroundColor = color
            self.alpha = color == nil ? 0 : 1
        }
    }
    
    var pattern: GarmentPattern? {
        didSet {
            
            if let rawValue = pattern?.rawValue {
                backgroundImage.image = UIImage(named: "ob_\(rawValue.lowercased())")
                backgroundImage.alpha = 1
            } else {
                backgroundImage.image = nil
                backgroundImage.alpha = 0
            }
        }
    }
    
    let backgroundImage: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.alpha = 0
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.borders.cgColor
        
        self.addSubview(backgroundImage)
        self.backgroundImage.pinToSuperview()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.masksToBounds = true
        self.layer.cornerRadius = self.frame.size.height / 2
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - TESTING
class PlainSegmentedControl: UISegmentedControl {
    
    override init(items: [Any]?) {
        super.init(items: items)
        self.selectedSegmentTintColor = .clear
        self.setBackgroundImage(UIImage(), for: .normal, barMetrics: .default)
        self.setDividerImage(UIImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        self.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.shadyLady.withAlphaComponent(0.4), NSAttributedString.Key.font: UIFont.mainFont(ofSize: 18, weight: .light)], for: .normal)
        self.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.luxorGold, NSAttributedString.Key.font: UIFont.mainFont(ofSize: 18, weight: .regular)], for: .selected)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
