//
//  AssetPickerPreviewView.swift
//  ComponentKit
//
//  Created by William Lee on 2018/5/12.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit

class AssetPickerPreviewView: UIView {
  
  private let scrollView = UIScrollView()
  private let imageView = UIImageView()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setupUI()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    
    scrollView.bounces = false
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    
    scrollView.bounces = true
  }
  
}

// MARK: - Public
extension AssetPickerPreviewView {
  
  func update(with image: UIImage?) {
    
    imageView.image = image
    resetSize()
  }
  
}

// MARK: - UIScrollViewDelegate
extension AssetPickerPreviewView: UIScrollViewDelegate {
  
  //缩放视图
  func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    return imageView
  }
  
  //缩放响应，设置imageView的中心位置
  func scrollViewDidZoom(_ scrollView: UIScrollView) {
    
    updateOrigin()
  }
  
}

// MARK: - Setup
private extension AssetPickerPreviewView {
  
  func setupUI() {
    
    backgroundColor = UIColor.black
    
    let singleTap = UITapGestureRecognizer(target:self, action:#selector(tapSingle(_:)))
    singleTap.numberOfTapsRequired = 1
    singleTap.numberOfTouchesRequired = 1
    scrollView.addGestureRecognizer(singleTap)
    
    scrollView.delegate = self
    scrollView.maximumZoomScale = 2
    scrollView.minimumZoomScale = 1
    scrollView.backgroundColor = backgroundColor
    scrollView.showsVerticalScrollIndicator = false
    scrollView.showsHorizontalScrollIndicator = false
    addSubview(scrollView)
    scrollView.layout.add { (make) in
      make.top().bottom().leading().trailing().equal(self)
    }
    
    imageView.backgroundColor = backgroundColor
    imageView.contentMode = .scaleAspectFit
    scrollView.addSubview(imageView)
  }
  
}

// MARK: - Action
private extension AssetPickerPreviewView {
  
  @objc func tapSingle(_ sender: UITapGestureRecognizer) {
    
    UIView.animate(withDuration: 0.5, animations: {
      
      self.alpha = 0
      
    }, completion: { (_) in
      
      self.update(with: nil)
    })
  }
  
}

// MARK: - Utility
private extension AssetPickerPreviewView {
  
  func resetSize() {
    
    scrollView.zoomScale = 1.0
    let imageSize: CGSize = imageView.image?.size ?? CGSize(width: 16, height: 9)
    let scale = imageSize.height / imageSize.width
    imageView.frame.size.width = scrollView.bounds.width
    imageView.frame.size.height = imageView.bounds.size.width * scale
    scrollView.contentSize = imageView.bounds.size
    
    updateOrigin()
  }
  
  func updateOrigin() {
    
    if imageView.frame.size.width < scrollView.bounds.width {
      
      imageView.frame.origin.x = scrollView.bounds.width / 2.0 - imageView.frame.width / 2.0
      
    } else {
      
      imageView.frame.origin.x = 0
    }
    
    if imageView.frame.size.height < scrollView.bounds.height {
      
      imageView.frame.origin.y = scrollView.bounds.height / 2.0 - imageView.frame.height / 2.0
      
    } else {
      
      imageView.frame.origin.y = 0
    }
  }
  
}
