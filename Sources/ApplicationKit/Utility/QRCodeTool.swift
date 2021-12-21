//
//  QRCodeTool.swift
//  ComponentKit
//
//  Created by William Lee on 2018/11/13.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit

public struct QRCodeTool {
  
}

public extension QRCodeTool {
 
  static func convert(from text: String) -> UIImage? {
    
    // 1、创建滤镜对象
    guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
    // 恢复滤镜的默认属性
    filter.setDefaults()
    
    let data = text.data(using: .utf8)
    // 设置过滤器的输入值, KVC赋值
    filter.setValue(data, forKey: "inputMessage")
    
    // 3、获得滤镜输出的图像，然后放大获取高清图片
    guard let outputImage = filter.outputImage?.transformed(by: CGAffineTransform(scaleX: 5, y: 5)) else { return nil }
    
    // - - - - - - - - - - - - - - - - 添加中间小图标 - - - - - - - - - - - - - - - -
    // TODO
    
    return UIImage(ciImage: outputImage)
  }
  
  static func convert(from image: UIImage) -> String? {
    
    guard let data = image.pngData() else { return nil }
    guard let ciImage = CIImage(data: data) else { return nil }
    
    let context = CIContext(options: [.useSoftwareRenderer: true])
    let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: context, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
    let result = detector?.features(in: ciImage)
    let feature = result?.first as? CIQRCodeFeature
    return feature?.messageString
  }
}
