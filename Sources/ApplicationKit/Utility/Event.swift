//
//  Event.swift
//  Watermark
//
//  Created by Mac mini on 2021/10/19.
//

import Foundation

  /// 观察者模式，不使用系统NotificationCenter主要原因：
  /// 1、强引用问题
  /// 2、使用不是那么的方便
  ///  将数值定义为一个事件，可以很方便的进行命名，标准的发布订阅模式，同一实例可以成为发布者也可以同时成为订阅者
  /// 使用举例：ViewController强持有Event，其他子视图，弱持有Event即可，子视图自己向Event中添加事件回调
  ///  ViewController {
  ///   let subview = CustomizedView()
  ///   let event = Event<Bool>()
  ///
  ///   subview.event = event
  ///  }
  ///  CustomizedView {
  ///    weak var event: Event<Bool>? {
  ///       didSet {
  ///         event?.add(self, event:  { [weak self ] value in
  ///           // do something
  ///         })
  ///       }
  ///     }
  ///  }
  /// 添加的事件触发后的操作闭包，注意使用weak、unowned，避免循环引用
@available(iOS, deprecated: 13.0, message: "Use Combine Framework")
public class Event<Value> {
  
    /// 保存订阅者和与其对应的事件变化时的操作
  private var handles: [WeakWrapper: (Value) -> Void] = [:]
  
  public init() { }
  
    /// 添加观察者
    /// - Parameters:
    ///   - observer: 观察本事件的观察者
    ///   - updateHandle: 本事件发生值更新的时候，会执行，如果为nil，则会移除观察者。
    ///   UpdateHandler闭包若对self进行了引用，建议使用unowned修饰，这样无需频繁的解包，也不会发生循环引用，
    ///   内部会确保闭包的正确调用，不会在观察者生命周期外执行
  public func add(observer: AnyObject, event updateHandler: ((Value) -> Void)? = nil) {
    
    handles[WeakWrapper(observer)] = updateHandler
  }
  
    /// 移除所有观察者及相关事件
  public func removeAll() {
    
    handles.removeAll()
  }
  
    /// 通知观察者，事件有更新
    /// - Parameters:
    ///   - value: 更新的值
    ///   - publisher: 发布者，慎用nil，主要用于过滤掉发布者也是订阅者的情况，避免触发多次更新操作甚至循环更新
  public func post(event value: Value, publisher: AnyObject?) {
    
    handles.forEach { observer, handler in
      
        // 移除无效的观察者
      if observer.source == nil {
        
        handles[observer] = nil
        return
      }
      
      if observer.source === publisher { return }
      
      handler(value)
    }
  }
  
}

/// 弱引用包装，用于对观察者的弱引用，避免影响观察者的生命周期
private struct WeakWrapper: Hashable {
  
  static func == (lhs: WeakWrapper, rhs: WeakWrapper) -> Bool {
    
    lhs.hashValue == rhs.hashValue
  }
  
  func hash(into hasher: inout Hasher) {
    
    guard let observer = source as? AnyHashable else { return }
    hasher.combine(observer)
  }
 
  weak var source: AnyObject?
  
  init(_ observer: AnyObject) { self.source = observer }
  
}
