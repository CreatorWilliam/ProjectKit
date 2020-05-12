//
//  Updator.swift
//  
//
//  Created by William Lee on 2020/5/12.
//

import Foundation

public class Updator: NSObject {
  
  private var shouldUpdate: Bool = false
  
  deinit {
    
    NotificationCenter.default.removeObserver(self)
  }
  
}

public extension Updator {
  
  
  /// 监听更新通知
  /// - Parameter name: 更新通知的名称
  func listenUpdate(notification name: Notification.Name) {
    
    NotificationCenter.default.addObserver(self, selector: #selector(recieve(_:)), name: name, object: nil)
  }
  
  /// 手动设置需要更新
  func setNeedUpdate() {
    
    shouldUpdate = true
  }
  
  /// 执行更新
  func update(handle: () -> Void) {
    
    guard shouldUpdate == true else { return }
    shouldUpdate = false
    handle()
  }
  
}

// MARK: - Notification
private extension Updator {
  
  @objc func recieve(_ notification: Notification) {
    
    setNeedUpdate()
  }
  
}
