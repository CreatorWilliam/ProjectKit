//
//  AssetPicker.swift
//  ComponentKit
//
//  Created by William Lee on 23/12/17.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit
import Photos
import ApplicationKit
import MobileCoreServices

public class AssetPicker: NSObject {
  
  private static let shared = AssetPicker()
  
  private var isOrigin: Bool = false
  private var completeHandle: CompleteHandle?
  
  public override init() {
    super.init()
  }
  
}

// MARK: - Public
public extension AssetPicker {
  
  enum Source {
  case camera
  case photoLibrary
  }
  
  typealias CompleteHandle = ([PHAsset], [UIImage]) -> Void
  
  class func video(source: Source,
                   isOrigin: Bool = true,
                   limited count: Int = 1,
                   completion handle: @escaping CompleteHandle) {
    
    switch source {
    case .camera:
      
      guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return }
      
      shared.completeHandle = handle
      shared.isOrigin = isOrigin
      
      let imagePicker = UIImagePickerController()
      imagePicker.modalPresentationStyle = .fullScreen
      imagePicker.delegate = shared
      imagePicker.sourceType = .camera
      imagePicker.mediaTypes = [kUTTypeVideo as String]
      Presenter.present(imagePicker)
      
    case .photoLibrary:
      
      AssetAlbumViewController.select(limit: count, content: .video, completion: handle)
    }
    
  }
  
  class func image(source: Source,
                   isOrigin: Bool = true,
                   limited count: Int = 1,
                   completion handle: @escaping CompleteHandle) {
    
    switch source {
    case .camera:
      
      guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return }
      
      shared.completeHandle = handle
      shared.isOrigin = isOrigin
      
      let imagePicker = UIImagePickerController()
      imagePicker.modalPresentationStyle = .fullScreen
      imagePicker.delegate = shared
      imagePicker.sourceType = .camera
      imagePicker.mediaTypes = [kUTTypeImage as String]
      Presenter.present(imagePicker)
      
    case .photoLibrary:
      
      AssetAlbumViewController.select(limit: count, content: .image, completion: handle)
    }
    
  }
  
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension AssetPicker: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  public func imagePickerController(_ picker: UIImagePickerController,
                                    didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    
    var assets: [PHAsset] = []
    var images: [UIImage] = []
    
    defer {
      
      picker.dismiss(animated: true, completion: {
        
        self.completeHandle?(assets, images)
        self.completeHandle = nil
      })
    }
    
    if #available(iOS 11.0, *),
        let phAsset = info[.phAsset] as? PHAsset {
      
      assets.append(phAsset)
    }
    
    if picker.mediaTypes.contains(kUTTypeVideo as String) {
      
      // Nothing
    }
    
    if picker.mediaTypes.contains(kUTTypeImage as String),
       let originImage = info[.originalImage] as? UIImage {
      
      if isOrigin == true { images.append(originImage) }
      else if let image = draw(originImage) { images.append(image) }
      else { }
    }
    
  }
  
  public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    
    defer { picker.dismiss(animated: true) }
    
    // 因为是全局的，用完一次就可以清除回调
    completeHandle = nil
  }
  
}

// MARK: - Private
private extension AssetPicker {
  
  func draw(_ image: UIImage) -> UIImage? {
    
    var drawedSize = UIScreen.main.bounds.size
    let imageSize = image.size
    
    let scale: CGFloat = drawedSize.width / imageSize.width
      
    drawedSize = CGSize(width: Int(imageSize.width * scale),
                        height: Int(imageSize.height * scale))
    
    let tailoredRect = CGRect(origin: .zero,
                              size: drawedSize)
    
    UIGraphicsBeginImageContextWithOptions(drawedSize, true, 0)
    image.draw(in: tailoredRect)
    let tailoredImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return tailoredImage
  }
  
}
