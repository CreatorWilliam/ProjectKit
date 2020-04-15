//
//  Transitioning.swift
//  ComponentKit
//
//  Created by William Lee on 2019/8/5.
//  Copyright © 2019 William Lee. All rights reserved.
//

import ApplicationKit
import UIKit

/// 表示UIViewController转场动画
public class Transitioning: NSObject {
  
  /// 蒙版颜色
  public var maskColor: UIColor = UIColor.black.withAlphaComponent(0.4)
  /// 是否开启退出手势
  public var isQuitGestureEnable: Bool = true
  
  /// 内部持有延长其生命期
  private static var shared: Transitioning?
  
  /// 转场动画
  public enum Animation {
    case bottomToTop
    case topToBottom
    case rightToLeft
    case leftToRight
  }
  /// 设置Present转场动画
  public var presentAnimation: Animation = .bottomToTop
  /// 设置Dismiss转场动画
  public var dismissAnimation: Animation = .topToBottom
  
  /// 用于描述转场阶段
  private enum Stage {
    /// 模态动画的present阶段
    case present
    /// 模态动画的dismiss阶段
    case dismis
    /// 导航动画的push阶段
    case push
    /// 导航动画的pop阶段
    case pop
  }
  
  /// 过渡容器视图
  private weak var containerView: UIView?
  /// 转场开始时显示的控制器
  private weak var fromViewController: UIViewController?
  /// 转场结束后显示的控制器
  private weak var toViewController: UIViewController?
  
  /// 保存当前动画所处的阶段
  private var stage: Stage = .present
  /// 滑动退出手势
  private lazy var quitGesture = UISwipeGestureRecognizer(target: self,
                                                          action: #selector(quit(_:)))
  
  public override init() {
    super.init()
    
    Transitioning.shared = self
  }
  
}

// MARK: - Public
extension Transitioning {
  
}

// MARK: - UINavigationControllerDelegate
extension Transitioning: UINavigationControllerDelegate {
  
}

// MARK: - UIViewControllerTransitioningDelegate
extension Transitioning: UIViewControllerTransitioningDelegate {
  
  public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    
    stage = .present
    return self
  }
  
  public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    
    stage = .dismis
    return self
  }
  
  public func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    
    return nil
  }
  
  public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    
    return nil
  }
  
  public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
    
    return nil
  }
  
}

// MARK: - UIViewControllerAnimatedTransitioning
extension Transitioning: UIViewControllerAnimatedTransitioning {
  
  public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    
    return 0.3
  }
  
  public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    
    toViewController = transitionContext.viewController(forKey: .to)
    fromViewController = transitionContext.viewController(forKey: .from)
    containerView = transitionContext.containerView
    
    switch stage {
    case .present: animatePresentTransition(using: transitionContext, animationType: presentAnimation)
    case .dismis: animateDismisTransition(using: transitionContext, animationType: dismissAnimation)
    default: break
    }
  }
  
  public func animationEnded(_ transitionCompleted: Bool) {
    
  }
  
}

// MARK: - Action
private extension Transitioning {
  
  @objc func quit(_ sender: UISwipeGestureRecognizer) {
    
    guard sender.direction == .down else { return }
    
    Presenter.back()
  }
  
}

// MARK: - Utility
private extension Transitioning {
  
  func animatePresentTransition(using transitionContext: UIViewControllerContextTransitioning, animationType: Animation) {
    
    guard let toViewController = toViewController else { return }
    guard let containerView = containerView else { return }
    
    containerView.backgroundColor = maskColor
    
    containerView.addSubview(toViewController.view)
    switch animationType {
    case .bottomToTop: toViewController.view.frame.origin.y = UIScreen.main.bounds.height
    case .topToBottom: toViewController.view.frame.origin.y = -UIScreen.main.bounds.height
    case .rightToLeft: toViewController.view.frame.origin.x = UIScreen.main.bounds.width
    case .leftToRight: toViewController.view.frame.origin.x = -UIScreen.main.bounds.width
    }
    
    if isQuitGestureEnable == true {
      
      quitGesture.direction = .down
      toViewController.view.addGestureRecognizer(quitGesture)
    }
    
    UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
      
      switch animationType {
      case .bottomToTop, .topToBottom:
        toViewController.view.frame.origin.y = 0
      case .rightToLeft, .leftToRight:
        toViewController.view.frame.origin.x = 0
      }
      
    }, completion: { (_) in
      
      transitionContext.completeTransition(true)
    })
  }
  
  func animateDismisTransition(using transitionContext: UIViewControllerContextTransitioning, animationType: Animation) {
    
    guard let fromViewController = fromViewController else { return }
    guard let toViewController = toViewController else { return }
    guard let containerView = containerView else { return }
    
    toViewController.view.removeGestureRecognizer(quitGesture)
    
    containerView.addSubview(fromViewController.view)
    
    UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
      
      switch animationType {
      case .bottomToTop: fromViewController.view.frame.origin.y = -UIScreen.main.bounds.height
      case .topToBottom: fromViewController.view.frame.origin.y = UIScreen.main.bounds.height
      case .rightToLeft: fromViewController.view.frame.origin.x = -UIScreen.main.bounds.width
      case .leftToRight: fromViewController.view.frame.origin.x = UIScreen.main.bounds.width
      }
      
    }, completion: { (_) in
      
      transitionContext.completeTransition(true)
      Transitioning.shared = nil
    })
  }
  
}
