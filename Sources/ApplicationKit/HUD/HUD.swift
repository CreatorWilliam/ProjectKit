  //
  //  HUD.swift
  //  ComponentKit
  //
  //  Created by William Lee on 17/03/2018.
  //  Copyright © 2018 William Lee. All rights reserved.
  //

import UIKit

  // MARK: - HUD UIViewController Extension
public extension UIViewController {
  
  private struct HUDExtensionKey {
    
    static var hud: Void?
  }
  
    /// LoadingView
  var hud: HUD {
    
    if let temp = objc_getAssociatedObject(self, &HUDExtensionKey.hud) as? HUD { return temp }
    let temp = HUD(self)
    objc_setAssociatedObject(self, &HUDExtensionKey.hud, temp, .OBJC_ASSOCIATION_RETAIN)
    
    return temp
  }
  
}

public class HUD {
  
    /// 消息视图
  private lazy var messageView = MessageView()
    /// 加载视图
  private lazy var loadingView = LoadingView()
    ///
  private lazy var activityView = ActivityIndicatorView(frame: .zero)
  private weak var controller: UIViewController?
  
  fileprivate init(_ controller: UIViewController) {
    
    self.controller = controller
  }
  
}

  // MARK: - MessageView
public extension HUD {
  
    /// 设置加载视图外观
    ///
    /// - Parameters:
    ///   - foreground: 前景色
    ///   - background: 背景色
  class func messageAppearance(foreground: UIColor = UIColor.white, background: UIColor = UIColor.black.withAlphaComponent(0.6)) {
    
    MessageView.default(foreground: foreground, background: background)
  }
  
    /// 显示消息视图
    ///
    /// - Parameters:
    ///   - title: 消息标题
    ///   - message: 消息内容
    ///   - duration: 持续时间
    ///   - completion: 消息视图隐藏后执行
  func showMessage(title: String? = nil, message: String?, duration: TimeInterval = 1, completion: (() -> Void)? = nil ) {
    
    
    messageView.frame = controller?.view.bounds ?? .zero
    messageView.layoutIfNeeded()
    controller?.view.addSubview(messageView)
    messageView.setup(title: title, message: message)
    
    controller?.view.bringSubviewToFront(messageView)
    messageView.show()
    DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
      
      self.controller?.view.sendSubviewToBack(self.messageView)
      self.messageView.hide()
      completion?()
    }
    
  }
  
}

  // MARK: - LoadingView
public extension HUD {
  
    /// 设置加载视图外观
    ///
    /// - Parameters:
    ///   - foreground: 前景色
    ///   - background: 背景色
  class func loadingAppearance(foreground: UIColor = UIColor.white, background: UIColor = UIColor.black.withAlphaComponent(0.6)) {
    
    LoadingView.default(foreground: foreground, background: background)
  }
  
    /// 显示加载视图
    ///
    /// - Parameter handle: 加载视图显示后执行
  func showLoading(_ handle: (() -> Void)? = nil) {
    
    if loadingView.superview == nil {
      
      controller?.view.addSubview(loadingView)
      loadingView.layout.add { (make) in
        make.top(44).equal(controller?.view).safeTop()
        make.bottom().equal(controller?.view).safeBottom()
        make.leading().trailing().equal(controller?.view)
      }
    }
    
    loadingView.isHidden = false
    controller?.view.bringSubviewToFront(loadingView)
    loadingView.start()
    handle?()
  }
  
    /// 隐藏加载视图
    ///
    /// - Parameter handle: 加载视图隐藏后执行
  func hideLoading(_ handle: (() -> Void)? = nil) {
    
    loadingView.isHidden = true
    controller?.view.sendSubviewToBack(loadingView)
    loadingView.stop()
    handle?()
    
  }
  
}


  // MARK: - ActivityIndicatorView
public extension HUD {
  
  func showActivity(_ handle: (() -> Void)? = nil) {
    
    if activityView.superview == nil {
      
      guard let controller = controller else { return }
      activityView.layerTintColors = [UIColor(0x23F6EB), UIColor.black, UIColor(0xFF2E56)]
      activityView = ActivityIndicatorView.show(in: controller.view)
    }
    activityView.startAnimation()
    controller?.view.bringSubviewToFront(activityView)
    handle?()
  }
  
  func hideActivity(_ handle: (() -> Void)? = nil) {
    
    activityView.hide(0.0, compelete: {
      
      handle?()
    })
  }
  
}
