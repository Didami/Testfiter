//
//  Extensions+Constants.swift
//  Testfiter
//
//  Created by Didami on 06/08/23.
//

// MARK: - PATENTED

import UIKit

// MARK: - String
extension String {
    
    public func localized() -> String {
        return NSLocalizedString(self, tableName: "Localizable", bundle: .main, value: self, comment: self)
    }
    
    public func isEmpty() -> Bool {
        
        if self.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return true
        }
        
        return false
    }
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
        
        if let font = UIFont(name: "Dosis", size: size)?.withWeight(weight) {
            
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
    
    public func addTopShadow(shadowColor: UIColor, shadowOpacity: Float, shadowRadius: CGFloat, offset: CGSize){
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.shadowOffset = offset
        self.layer.shadowOpacity = shadowOpacity
        self.layer.shadowRadius = shadowRadius
        self.clipsToBounds = false
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

// MARK: - Color
extension UIColor {
    
    static var background: UIColor {
        return UserDefaultsManager.shared.getBoolean(with: "clear_mode") ? UIColor(r: 215, g: 215, b: 215) : UIColor(r: 20, g: 20, b: 20)
    }
    
    static var codGray: UIColor {
        return UserDefaultsManager.shared.getBoolean(with: "clear_mode") ? UIColor(r: 207, g: 207, b: 207) : UIColor(r: 28, g: 28, b: 28)
    }
    
    static var white: UIColor {
        return UserDefaultsManager.shared.getBoolean(with: "clear_mode") ? .black : UIColor(r: 255, g: 255, b: 255)
    }
    
    static let luxorGold = UIColor(r: 169, g: 139, b: 51)
    static let shadyLady = UIColor(r: 160, g: 156, b: 159)
    static let borders = UIColor(r: 134, g: 111, b: 44)
    static let coralRed = UIColor(r: 244, g: 54, b: 73)
    
    var hsb: (hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat)? {
        var hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0, alpha: CGFloat = 0
        guard getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) else {
            return nil
        }
        return (hue, saturation, brightness, alpha)
    }
    
    var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return (red, green, blue, alpha)
    }
    
    var coreImageColor: CIColor {
        return CIColor(color: self)
    }
    
    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        let coreImageColor = self.coreImageColor
        return (coreImageColor.red, coreImageColor.green, coreImageColor.blue, coreImageColor.alpha)
    }
    
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
    
    convenience init?(hex: String) {
        let r, g, b, a: CGFloat

        if hex.hasPrefix("#") {

            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 8 {
    
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
        
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255
                    
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }
        return nil
    }
    
    public func hexString() -> String {
        let components = self.cgColor.components
        let r: CGFloat = components?[0] ?? 0.0
        let g: CGFloat = components?[1] ?? 0.0
        let b: CGFloat = ((components?.count ?? 0) > 2 ? components?[2] : g) ?? 0.0

        let hexString = String.init(format: "#%02lX%02lX%02lX", lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255)))
            
        return "\(hexString.lowercased())ff"
    }
    
    func color(tolerance: Int = 15) -> Color? {
        precondition(0...15 ~= tolerance)
        guard let hsb = hsb else { return nil }
        
        if hsb.saturation <= CGFloat(tolerance) / 200 { return .neutral }
        if hsb.brightness == 0 { return .neutral }
        
        let hue = Int(hsb.hue * 360), sat = Int(hsb.saturation * 100), bri = Int(hsb.brightness * 100), average = (sat+bri)/2
        switch hue {
        case 0 ... tolerance: return .red
        case 30 - tolerance ... 30 + tolerance: return average < (50 + tolerance) ? (sat <= 50 && bri >= 50 && sat + 25 < bri ? .beige : .brown) : .orange
        case 60 - tolerance ... 60 + tolerance: return sat > 15 && bri < 60 ? .militar : .yellow
        case 90 - tolerance ... 90 + tolerance: return .yellowGreen
        case 120 - tolerance ... 120 + tolerance: return .green
        case 150 - tolerance ... 150 + tolerance: return .greenCyan
        case 180 - tolerance ... 180 + tolerance: return .cyan
        case 210 - tolerance ... 210 + tolerance: return .cyanBlue
        case 240 - tolerance ... 240 + tolerance: return .blue
        case 270 - tolerance ... 270 + tolerance: return .purple
        case 300 - tolerance ... 300 + tolerance: return .magenta
        case 330 - tolerance ... 330 + tolerance: return .magentaRed
        case 360 - tolerance ... 360 : return .red
        default: break
        }
        
        return .neutral
    }
}

func HSVtoRGB(_ h: Float, s: Float, v: Float) -> (r : Float, g : Float, b : Float) {
    var r : Float = 0
    var g : Float = 0
    var b : Float = 0
    let C = s * v
    let HS = h * 6.0
    let X = C * (1.0 - fabsf(fmodf(HS, 2.0) - 1.0))
    if (HS >= 0 && HS < 1) {
        r = C
        g = X
        b = 0
    } else if (HS >= 1 && HS < 2) {
        r = X
        g = C
        b = 0
    } else if (HS >= 2 && HS < 3) {
        r = 0
        g = C
        b = X
    } else if (HS >= 3 && HS < 4) {
        r = 0
        g = X
        b = C
    } else if (HS >= 4 && HS < 5) {
        r = X
        g = 0
        b = C
    } else if (HS >= 5 && HS < 6) {
        r = C
        g = 0
        b = X
    }
    let m = v - C
    r += m
    g += m
    b += m
    return (r, g, b)
}


func RGBtoHSV(_ r: Float, g: Float, b: Float) -> (h: Float, s: Float, v: Float) {
    var h: CGFloat = 0
    var s: CGFloat = 0
    var v: CGFloat = 0
    let col = UIColor(red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: 1.0)
    col.getHue(&h, saturation: &s, brightness: &v, alpha: nil)
    return (Float(h), Float(s), Float(v))
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
    
    public func maskWith(maskImage: UIImage) -> UIImage {
        
        let maskRef = maskImage.cgImage

        let mask = CGImage(
            maskWidth: maskRef!.width,
            height: maskRef!.height,
            bitsPerComponent: maskRef!.bitsPerComponent,
            bitsPerPixel: maskRef!.bitsPerPixel,
            bytesPerRow: maskRef!.bytesPerRow,
            provider: maskRef!.dataProvider!,
            decode: nil,
            shouldInterpolate: false
        )

        let masked = self.cgImage!.masking(mask!)
        let maskedImage = UIImage(cgImage: masked!)

        return maskedImage
    }
}

public enum Height: String {
    case short
    case belowAverage = "below average"
    case average
    case aboveAverage = "above average"
    case tall
    
    var order: Int {
        switch self {
        case .short: return 0
        case .belowAverage: return 1
        case .average: return 2
        case .aboveAverage: return 3
        case .tall: return 4
        }
    }
}

public enum Weight: String {
    case skinny
    case belowAverage = "below average"
    case average
    case aboveAverage = "above average"
    case thick
    
    var order: Int {
        switch self {
        case .skinny: return 0
        case .belowAverage: return 1
        case .average: return 2
        case .aboveAverage: return 3
        case .thick: return 4
        }
    }
}

public enum SkinTone: String {
    case light
    case fair
    case tan
    case swarthy
    case dark
    
    var order: Int {
        switch self {
        case .light: return 0
        case .fair: return 1
        case .tan: return 2
        case .swarthy: return 3
        case .dark: return 4
        }
    }
}

extension Dictionary {
    func compactMapKeys<T>(_ transform: ((Key) throws -> T?)) rethrows -> Dictionary<T, Value> {
        return try self.reduce(into: [T: Value](), { (result, x) in
            if let key = try transform(x.key) {
                result[key] = x.value
            }
        })
    }
}

extension Array where Element: Hashable {
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return filter{ seen.insert($0).inserted }
    }
}

extension Float {
    
    public func toHeight() -> Height {
        switch self {
        case _ where self < 155: return .short
        case 155 ... 165: return .belowAverage
        case 165 ... 175: return .average
        case 175 ... 185: return .aboveAverage
        case _ where self > 185: return .tall
        default: break
        }
        
        return .average
    }
    
    public func toWeight() -> Weight {
        switch self {
        case _ where self < 55: return .skinny
        case 55 ... 65: return .belowAverage
        case 65 ... 75: return .average
        case 75 ... 85: return .aboveAverage
        case _ where self > 85: return .thick
        default: break
        }
        
        return .average
    }
    
    public func toSkinTone() -> SkinTone {
        switch self {
        case 0.0 ... 0.2: return .light
        case 0.2 ... 0.4: return .fair
        case 0.4 ... 0.6: return .tan
        case 0.6 ... 0.8: return .swarthy
        case 0.8 ... 1.0: return .dark
        default: break
        }
        
        return .tan
    }
}

func mostFrequent<T: Hashable>(array: [T]) -> (value: T, count: Int)? {

    let counts = array.reduce(into: [:]) { $0[$1, default: 0] += 1 }

    if let (value, count) = counts.max(by: { $0.1 < $1.1 }) {
        return (value, count)
    }

    // array was empty
    return nil
}

// MARK: - UIApplication
extension UIApplication {
    public static var keyWindow: UIWindow? {
        if #available(iOS 15.0, *) {
            guard let window = UIApplication.shared.connectedScenes.compactMap({ ($0 as? UIWindowScene)?.keyWindow }).first else { return nil }
            return window
        }
        
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return nil }
        return window
    }
}

// MARK: - File Manager
extension FileManager {
    
    public func clearTmpDirectory() {
        do {
            let tmpDirectory = try contentsOfDirectory(atPath: NSTemporaryDirectory())
            try tmpDirectory.forEach { [unowned self] file in
                let path = String.init(format: "%@%@", NSTemporaryDirectory(), file)
                try self.removeItem(atPath: path)
            }
        } catch {
            print(error)
        }
    }
}

extension [Double] {
    public func average() -> Double {
        return Double(self.reduce(0, +))/Double(self.count)
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

// MARK: - Old iOS verions
extension Date {
    
    public static var currentDate: Date {
        if #available(iOS 15.0, *) { return Date.now }
        return Date()
    }
}

/*
   ==.---.
     |^   |  __
      /====\/  \
      |====|\../
      \====/
        \/
*/
