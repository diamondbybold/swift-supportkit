import UIKit

extension UIImage {
    public static func fromColor(_ color: UIColor) -> UIImage? {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        let size = CGSize(width: 1.0, height: 1.0)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    public static func fromBase64String(_ string: String) -> UIImage? {
        guard let imageData = Data(base64Encoded: string) else { return nil }
        return UIImage(data: imageData)
    }
    
    public func base64String(compressionQuality: CGFloat = 0.9) -> String {
        return jpegData(compressionQuality: compressionQuality)?.base64EncodedString() ?? ""
    }
    
    public func resized(targetSize: CGSize) -> UIImage {
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        
        let scaleFactor = min(widthRatio, heightRatio)
        let scaledImageSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)
        
        let renderer = UIGraphicsImageRenderer(size: scaledImageSize)
        
        let scaledImage = renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: scaledImageSize))
        }
        
        return scaledImage
    }
    
    public func resizedIfNeeded(maxSize: CGFloat) -> UIImage {
        guard size.width > maxSize || size.height > maxSize else { return self }
        return resized(targetSize: CGSize(width: maxSize, height: maxSize))
    }
}
