//
//  UIImage + Extensions.swift
//  RemitExchange
//
//  Created by Elma YEH 葉品妤 on 2025/8/25.
//

import UIKit

extension UIImage {
    static func applyGaussianBlur(to image: UIImage, radius: CGFloat) -> UIImage? {
        guard let ciImage = CIImage(image: image) else { return nil }
        
        // 建立模糊濾鏡
        let filter = CIFilter(name: "CIGaussianBlur")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        filter?.setValue(radius, forKey: kCIInputRadiusKey) // 模糊半徑，越大越模糊，建議不超過30
        
        guard let outputCIImage = filter?.outputImage else { return nil }
        
        // 修正邊界模糊（crop 回原圖尺寸）
        let context = CIContext()
        let rect = ciImage.extent.insetBy(dx: 0, dy: -12)
        guard let cgImage = context.createCGImage(outputCIImage, from: rect) else { return nil }
        
        return UIImage(cgImage: cgImage)
    }
}
