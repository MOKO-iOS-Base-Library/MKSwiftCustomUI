//
//  File.swift
//  MKBaseSwiftModule
//
//  Created by aa on 2025/5/30.
//

import UIKit

import MKBaseSwiftModule

// Bundle 扩展
extension Bundle {
    public static var myModule: Bundle {
        return ResourceHelper.bundle
    }
}

public class ResourceHelper {
    public static var bundle: Bundle {
        #if SWIFT_PACKAGE
        return Bundle.module
        #else
        // 对于非 SPM 环境（如主工程或其他 SPM）
        return Bundle(for: ResourceHelper.self)
        #endif
    }
}

public func moduleIcon(name: String, in bundle: Bundle? = nil) -> UIImage? {
    let targetBundle = bundle ?? ResourceHelper.bundle
    return UIImage(named: name, in: targetBundle, compatibleWith: nil)
}

public extension UIImage {
    // MARK: - Image Processing
    
    /// Returns a stretchable image
    static func resizableImage(named name: String) -> UIImage? {
        guard let normal = UIImage(named: name) else { return nil }
        let w = normal.size.width * 0.5
        let h = normal.size.height * 0.5
        return normal.resizableImage(withCapInsets: UIEdgeInsets(top: h, left: w, bottom: h, right: w))
    }
    
    /// Takes a screenshot of a view
    @MainActor static func screenshot(from view: UIView, rect: CGRect) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        context.translateBy(x: -rect.origin.x, y: -rect.origin.y)
        view.layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    /// Creates a thumbnail while maintaining aspect ratio
    static func thumbnailWithoutScale(image: UIImage, size: CGSize) -> UIImage? {
        let oldSize = image.size
        var rect = CGRect.zero
        
        if size.width/size.height > oldSize.width/oldSize.height {
            rect.size.width = size.height * oldSize.width / oldSize.height
            rect.size.height = size.height
            rect.origin.x = (size.width - rect.size.width) / 2
            rect.origin.y = 0
        } else {
            rect.size.width = size.width
            rect.size.height = size.width * oldSize.height / oldSize.width
            rect.origin.x = 0
            rect.origin.y = (size.height - rect.size.height) / 2
        }
        
        UIGraphicsBeginImageContext(size)
        UIColor.clear.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    /// Compresses image to target width while maintaining aspect ratio
    static func compressImage(_ sourceImage: UIImage, toTargetWidth targetWidth: CGFloat) -> UIImage? {
        let imageSize = sourceImage.size
        let width = imageSize.width
        let height = imageSize.height
        let targetHeight = (targetWidth / width) * height
        return thumbnailWithoutScale(image: sourceImage, size: CGSize(width: targetWidth, height: targetHeight))
    }
    
    // MARK: - Image Compression
    
    /// Creates a thumbnail with max dimension of 800px
    static func thumbnail(image: UIImage) -> UIImage? {
        let margin: CGFloat = 800
        var width: CGFloat = 0
        var height: CGFloat = 0
        
        if image.size.width >= image.size.height {
            let proportion = image.size.height / image.size.width
            width = margin
            height = width * proportion
        } else {
            let proportion = image.size.width / image.size.height
            height = margin
            width = height * proportion
        }
        
        return thumbnailWithoutScale(image: image, size: CGSize(width: width, height: height))
    }
    
    /// Returns a cropped image
    func cropped(to bounds: CGRect) -> UIImage? {
        guard let cgImage = self.cgImage?.cropping(to: bounds) else { return nil }
        return UIImage(cgImage: cgImage)
    }
    
    /// Returns a resized image with specified quality
    func resized(to newSize: CGSize, interpolationQuality quality: CGInterpolationQuality) -> UIImage? {
        let transform = transformForOrientation(newSize)
        return resized(to: newSize, transform: transform, drawTransposed: true, interpolationQuality: quality)
    }
    
    /// Resizes image according to content mode
    func resized(withContentMode contentMode: UIView.ContentMode, bounds: CGSize, interpolationQuality quality: CGInterpolationQuality) -> UIImage? {
        let horizontalRatio = bounds.width / size.width
        let verticalRatio = bounds.height / size.height
        let ratio: CGFloat
        
        switch contentMode {
        case .scaleAspectFill:
            ratio = max(horizontalRatio, verticalRatio)
        case .scaleAspectFit:
            ratio = min(horizontalRatio, verticalRatio)
        default:
            fatalError("Unsupported content mode: \(contentMode)")
        }
        
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        return resized(to: newSize, interpolationQuality: quality)
    }
    
    // MARK: - Private Methods
    
    private func resized(to newSize: CGSize, transform: CGAffineTransform, drawTransposed: Bool, interpolationQuality quality: CGInterpolationQuality) -> UIImage? {
        let newRect = CGRect(origin: .zero, size: newSize).integral
        let transposedRect = CGRect(origin: .zero, size: CGSize(width: newRect.size.height, height: newRect.size.width))
        guard let cgImage = self.cgImage else { return nil }
        
        guard let colorSpace = cgImage.colorSpace,
              let context = CGContext(
                data: nil,
                width: Int(newRect.width),
                height: Int(newRect.height),
                bitsPerComponent: cgImage.bitsPerComponent,
                bytesPerRow: 0,
                space: colorSpace,
                bitmapInfo: cgImage.bitmapInfo.rawValue & ~CGBitmapInfo.alphaInfoMask.rawValue | CGImageAlphaInfo.noneSkipLast.rawValue
              ) else {
            return nil
        }
        
        context.concatenate(transform)
        context.interpolationQuality = quality
        context.draw(cgImage, in: drawTransposed ? transposedRect : newRect)
        
        guard let newImageRef = context.makeImage() else { return nil }
        return UIImage(cgImage: newImageRef)
    }
    
    private func transformForOrientation(_ newSize: CGSize) -> CGAffineTransform {
        var transform = CGAffineTransform.identity
        
        switch imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: newSize.width, y: newSize.height)
            transform = transform.rotated(by: .pi)
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: newSize.width, y: 0)
            transform = transform.rotated(by: .pi / 2)
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: newSize.height)
            transform = transform.rotated(by: -.pi / 2)
        default:
            break
        }
        
        switch imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: newSize.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: newSize.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        default:
            break
        }
        
        return transform
    }
    
    // MARK: - Launch Image
    
    /// Returns the launch image
    @MainActor static var launchImage: UIImage? {
        let viewSize = UIScreen.main.bounds.size
        let viewOrientation = "Portrait" // Use "Landscape" for landscape
        var imageName = ""
        
        if let imagesDict = Bundle.main.infoDictionary?["UILaunchImages"] as? [[String: Any]] {
            for dict in imagesDict {
                if let imageSizeString = dict["UILaunchImageSize"] as? String,
                   let orientation = dict["UILaunchImageOrientation"] as? String,
                   let name = dict["UILaunchImageName"] as? String {
                    
                    let imageSize = NSCoder.cgSize(for: imageSizeString)
                    if imageSize == viewSize && viewOrientation == orientation {
                        imageName = name
                        break
                    }
                }
            }
        }
        
        return UIImage(named: imageName)
    }
}


