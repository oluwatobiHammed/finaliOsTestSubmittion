//
//  RoundedIconButton.swift
//  CustomLoginDemo
//
//  Created by Oladipupo Oluwatobi Hammed on 19/05/2020.
//  Copyright © 2020 Christopher Ching. All rights reserved.
//

import UIKit

class RoundedIconButton: BaseXNib {

    @IBOutlet weak var textLabel: UILabel?
    @IBOutlet weak var contentView: UIView?
    
    var removeDropShadow = false
    /**
     Color of the radio button circle. Default value is UIColor red.
     */
    @IBInspectable var circleColor: UIColor = ThemeManager.currentTheme().accentColor {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    @IBInspectable var iconText: String? {
        didSet {
            if iconText != nil {
                self.icon = FontIcon.fromString(iconName: iconText!)
            }
        }
    }
    
    var icon: FontIcon? {
        didSet {
            self.changeIcon()
        }
    }
    
    @IBInspectable var iconSize: CGFloat = 30 {
        didSet {
            self.changeIcon()
        }
    }
    
    @IBInspectable var iconColor: UIColor = UIColor.white {
        didSet {
            self.changeIcon()
        }
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        let path = circlePath()
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        ctx.setFillColor(circleColor.cgColor)
        ctx.addPath(path.cgPath)
        ctx.closePath()
        ctx.fillPath()
    }
 
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupXnib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupXnib()
    }
    
    fileprivate func circleFrame() -> CGRect {
        var circleFrame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
        circleFrame.origin.x = 0
        circleFrame.origin.y = 0
        return circleFrame
    }
    
    fileprivate func circlePath() -> UIBezierPath {
        return UIBezierPath(ovalIn: circleFrame())
    }
    
    override func layoutSubviews() {
        if removeDropShadow {
            layer.shadowColor = UIColor.clear.cgColor
            layer.shadowRadius = 0
            layer.shadowOffset = CGSize.zero
            layer.shadowOpacity = 0
        }
        else {
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowRadius = 4
            layer.shadowOffset = CGSize(width: 0, height: 4)
            layer.shadowOpacity = 0.3
        }
    }
    
    func removeShadow() {
        self.removeDropShadow = true
        self.setNeedsLayout()
        self.setNeedsDisplay()
    }
    
    
    override func setupXnib() {
        super.setupXnib()
        self.backgroundColor = UIColor.clear
        self.contentView?.backgroundColor = UIColor.clear
        changeIcon()
        
    }
    override func getContentView() -> UIView? {
        return contentView
    }
    
    override func getNibName() -> String? {
        return "RoundedIconButton"
    }
    
    func changeIcon() {
        if let theIcon = icon{
            self.textLabel?.usingIcon(icon: theIcon, size: iconSize, color: iconColor)
        }
    }
}

