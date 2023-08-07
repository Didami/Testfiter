//
//  Extensions+Constants.swift
//  Testfiter
//
//  Created by Didami on 06/08/23.
//

import UIKit

// MARK: - UIColor
extension UIColor {
    
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
    
    static let background = UIColor(r: 20, g: 20, b: 20)
    static let codGray = UIColor(r: 28, g: 28, b: 28)
    static let luxorGold = UIColor(r: 169, g: 139, b: 51)
    static let shadyLady = UIColor(r: 160, g: 156, b: 159)
    static let borders = UIColor(r: 134, g: 111, b: 44)
    static let coralRed = UIColor(r: 244, g: 54, b: 73)
}

// MARK: - Font
extension UIFont {
    
    func withWeight(_ weight: UIFont.Weight) -> UIFont {
        var attributes = fontDescriptor.fontAttributes
        var traits = (attributes[.traits] as? [UIFontDescriptor.TraitKey: Any]) ?? [:]
        
        traits[.weight] = weight
        attributes[.name] = nil
        attributes[.traits] = traits
        attributes[.family] = familyName
        
        let descriptor = UIFontDescriptor(fontAttributes: attributes)
        
        return UIFont(descriptor: descriptor, size: pointSize)
    }
    
    class func mainFont(ofSize size: CGFloat, weight: UIFont.Weight) -> UIFont {
        
        let systemFont = UIFont.systemFont(ofSize: size, weight: weight)
        
        if let font = UIFont(name: "", size: size)?.withWeight(weight) {
            
            return font
        }
        
        return systemFont
    }
}

// MARK: - UIView
extension UIView {
    
    public func pinToSuperview(with constant: CGFloat = 0) {
        
        if let superview = self.superview {
            self.translatesAutoresizingMaskIntoConstraints = false
            
            self.leftAnchor.constraint(equalTo: superview.leftAnchor, constant: constant).isActive = true
            self.rightAnchor.constraint(equalTo: superview.rightAnchor, constant: -constant).isActive = true
            self.topAnchor.constraint(equalTo: superview.topAnchor, constant: constant).isActive = true
            self.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -constant).isActive = true
        }
    }
    
    public func circleView() {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = self.frame.height / 2
    }
    
    public func addShadow(offset: CGSize, color: UIColor, radius: CGFloat, opacity: Float) {
        layer.masksToBounds = false
        layer.shadowOffset = offset
        layer.shadowColor = color.cgColor
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        
        let backgroundCGColor = backgroundColor?.cgColor
        backgroundColor = nil
        layer.backgroundColor =  backgroundCGColor
    }
    
    public func popIn(duration: CGFloat = 0.1, delay: CGFloat = 0 , impact: Bool = true) {
        if impact { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
        UIView.animate(withDuration: duration) {
            self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        } completion: { _ in
            UIView.animate(withDuration: duration, delay: delay) {
                self.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
        }
    }
}

// MARK: - UIImage
extension UIImage {
    // Size
    public func resizedImage(size sizeImage: CGSize, renderingMode: UIImage.RenderingMode = .alwaysOriginal) -> UIImage? {
        let frame = CGRect(origin: CGPoint.zero, size: CGSize(width: sizeImage.width, height: sizeImage.height))
        UIGraphicsBeginImageContextWithOptions(frame.size, false, 0)
        self.draw(in: frame)
        let resizedImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage?.withRenderingMode(renderingMode)
    }
    
    public func resizedToIcon() -> UIImage? {
        return self.resizedImage(size: CGSize(width: 24, height: 24))?.withRenderingMode(.alwaysTemplate)
    }
    
    public func resizedToLargeIcon() -> UIImage? {
        return self.resizedImage(size: CGSize(width: 360, height: 360))?.withRenderingMode(.alwaysTemplate)
    }
    
    public func resizedToSmallIcon() -> UIImage? {
        return self.resizedImage(size: CGSize(width: 6, height: 6))?.withRenderingMode(.alwaysTemplate)
    }
}

// MARK: - Constants
public enum Constants {
    
    static let superViewSpacing: CGFloat = 12
    
    static let standardSpacing: CGFloat = 24
    static let safeSpacing: CGFloat = 12
    
    static let doubleSpacing: CGFloat = 48
    
    static let stackStandardSpacing: CGFloat = 27
    static let stackSafeSpacing: CGFloat = 12
    
    static let cellSpacing: CGFloat = 42
    static let sectionSpacing: CGFloat = 51
    
    static let cornerRadius: CGFloat = 24
    
    static let iconSize: CGFloat = 48
    
    static let mainAnimationDuration: CGFloat = 0.6
}
