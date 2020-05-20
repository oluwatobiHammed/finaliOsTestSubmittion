//
//  IconButton.swift
//  FCMB-Mobile
//
//  Created by Kembene Nkem-Etoh on 2/28/18.
//  Copyright © 2018 FCMB. All rights reserved.
//

import Foundation
import UIKit

//@IBDesignable
class IconButton: UIButton {
    fileprivate var circleLayer = CAShapeLayer()
    
    @IBInspectable var drawOval: Bool = true {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable var iconSize: CGFloat = FontStyle.Icon.size - 3 {
        didSet {
            buildIcon()
        }
    }
    
    @IBInspectable var icon: String? {
        didSet {
            buildIcon()
        }
    }
    
    @IBInspectable var colorIcon: UIColor? = UIColor.white {
        didSet {
            buildIcon()
        }
    }
    
    @IBInspectable var colorThemeIcon: String? = nil {
        didSet {
            if let color = colorThemeIcon {
                if let uiColor = ThemeManager.currentTheme().color(from: color) {
                    self.colorIcon = uiColor
                }
            }
        }
    }
    
    @IBInspectable var colorBackground: UIColor? = nil {
        didSet {
            if let color = colorBackground{
                self.layer.backgroundColor = color.cgColor
            }
        }
    }
    
    @IBInspectable var circleRadius: CGFloat = 40.0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable var colorCircle: UIColor = UIColor.gray {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable var addShadow: Bool = false {
        didSet {
            if addShadow {
                self.dropShadow()
            }
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            if cornerRadius > 0.0 {
                self.layer.cornerRadius = cornerRadius
                self.layer.borderWidth = 1
                self.layer.borderColor = UIColor.clear.cgColor
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    func initialize() {
        //        self.titleEdgeInsets = UIEdgeInsetsMake(2, 2, 2, 2)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if drawOval {
            let path = circlePath()
            guard let ctx = UIGraphicsGetCurrentContext() else { return }
            ctx.setFillColor(colorCircle.cgColor)
            ctx.addPath(path.cgPath)
            ctx.closePath()
            ctx.fillPath()
        }
    }
    
    fileprivate func circleFrame(offset:CGFloat = 0) -> CGRect {
        var circleFrame = CGRect(x: offset, y: offset, width: bounds.width - offset, height: bounds.height - offset)
        circleFrame.origin.x = offset/2
        circleFrame.origin.y = offset/2
        return circleFrame
    }
    
    fileprivate func circlePath() -> UIBezierPath {
        return UIBezierPath(ovalIn: circleFrame())
    }
    
    func buildIcon() {
        if let theIcon = icon {
            let icon = FontIcon.fromString(iconName: theIcon)!
            if let color = colorIcon {
                let attributedText = icon.string(size: iconSize, color: color)
                self.setAttributedTitle(attributedText, for: .normal)
            }
        }
    }
}
