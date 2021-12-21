//
//  CircleProgressView.swift
//  ComponentKit
//
//  Created by William Lee on 10/02/2018.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit

public class CircleProgressView: UIView {
  
    /// 进度
  public var progress: CGFloat = 0 { didSet { setNeedsDisplay() } }
  /// 进度条颜色
  public var progressColor: UIColor = .blue
  /// 进度条背景色
  public var progressBackgroundColor: UIColor = .lightGray
  /// 进度条宽度
  public var progressWidth: CGFloat = 1
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setupUI()
  }
  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // Only override draw() if you perform custom drawing.
  // An empty implementation adversely affects performance during animation.
  override public func draw(_ rect: CGRect) {
    // Drawing code
    
    drawProgressBackground(in: rect)
    drawProgress(in: rect)
  }
  
}

// MARK: - Public
public extension CircleProgressView {
  
}

// MARK: - Setup
private extension CircleProgressView {
  
  func setupUI() {
    
    backgroundColor = .clear
  }
  
}

// MARK: - Utiltiy
private extension CircleProgressView {
  
  func drawProgressBackground(in rect: CGRect) {
    
    let rect = rect.insetBy(dx: self.progressWidth, dy: self.progressWidth)
    let center: CGPoint = CGPoint(x: rect.midX, y: rect.midY)
    let radius: CGFloat = rect.width / 2
    
    let backgroundPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: CGFloat.pi, clockwise: true)
    backgroundPath.move(to: CGPoint(x: center.x + radius, y: center.y))
    backgroundPath.addArc(withCenter: center, radius: radius, startAngle: 0, endAngle: CGFloat.pi, clockwise: false)
    backgroundPath.lineWidth = 3
    backgroundPath.lineCapStyle = .square
    progressBackgroundColor.setStroke()
    backgroundPath.stroke()
  }
  
  func drawProgress(in rect: CGRect) {
    
    let rect = rect.insetBy(dx: self.progressWidth, dy: self.progressWidth)
    let center: CGPoint = CGPoint(x: rect.midX, y: rect.midY)
    let radius: CGFloat = rect.width / 2
    let startAnagel: CGFloat = .pi * 1.5
    let endAngel: CGFloat = startAnagel - .pi * 2 * self.progress
    // 对于progress为1的情况下，不会绘制成一个圈
    let progressPath = UIBezierPath()

    if self.progress > 0 {
      
      progressPath.addArc(withCenter: center, radius: radius, startAngle: startAnagel, endAngle: endAngel, clockwise: true)
      
    } else {
      
      progressPath.addArc(withCenter: center, radius: radius, startAngle: 0, endAngle: CGFloat.pi, clockwise: true)
      progressPath.move(to: CGPoint(x: center.x + radius, y: center.y))
      progressPath.addArc(withCenter: center, radius: radius, startAngle: 0, endAngle: CGFloat.pi, clockwise: false)
    }
    progressPath.lineWidth = 3
    progressPath.lineCapStyle = .square
    progressColor.setStroke()
    progressPath.stroke()
  }
  
}
