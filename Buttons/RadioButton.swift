//
//  RadioButton.swift
//  FCMB-Mobile
//
//  Created by Kembene Nkem-Etoh on 2/19/18.
//  Copyright © 2018 FCMB. All rights reserved.
//

import Foundation
import UIKit
import RxSwift


enum RadioButtonSelectionType {
    case selected
    case deselected
}

protocol RadioButtonItem {
    func getRadioButtonItemLabel()-> String
}

struct YesNoSingleRadioButtonItem: RadioButtonItem {
    var label: String
    func getRadioButtonItemLabel()-> String {
        return label
    }
}

enum YesNoSingleItem {
    case yes
    case no
}

class RadioButton: UIButton {
    fileprivate var circleLayer = CAShapeLayer()
    fileprivate var fillCircleLayer = CAShapeLayer()
    fileprivate let checkmarkLayer = CAShapeLayer()
    
    fileprivate var radioButtonSelectPublisher = PublishSubject<(RadioButton, RadioButtonSelectionType)>()
    
    var buttonSelect: Observable<(RadioButton, RadioButtonSelectionType)> {
        return radioButtonSelectPublisher.asObservable()
    }
    
    var radioItemData: RadioButtonItem?
    
    override var isSelected: Bool {
        didSet {
            toggleButon()
        }
    }
    
    /**
     Color of the radio button circle. Default value is UIColor red.
     */
    @IBInspectable var circleColor: UIColor = UIColor.gray {
        didSet {
            circleLayer.strokeColor = strokeColor.cgColor
            self.toggleButon()
        }
    }
    
    @IBInspectable var lineWidth: CGFloat = 1.0 {
        didSet {
            circleLayer.lineWidth = lineWidth
            self.toggleButon()
        }
    }
    
    @IBInspectable var useAccentTextColor: Bool = false {
        didSet {
            if useAccentTextColor {
                textColor = ThemeManager.currentTheme().accentColor
            }
        }
    }
    
    @IBInspectable var useMainTextColor: Bool = false {
        didSet {
            if useMainTextColor {
                textColor = ThemeManager.currentTheme().mainColor
            }
        }
    }
    
    @IBInspectable var textColor: UIColor = UIColor.black {
        didSet {
            self.setTitleColor(textColor, for: .selected)
            self.setTitleColor(textColor, for: .normal)
            self.toggleButon()
        }
    }
    
    @IBInspectable var checkMarkColor: UIColor = UIColor.white {
        didSet {
            self.toggleButon()
        }
    }
    
    @IBInspectable var selectedColor: UIColor = ThemeManager.currentTheme().accentColor {
        didSet {
            self.toggleButon()
        }
    }
    
    @IBInspectable var increaseFontBy: CGFloat = 0 {
        didSet {
            //self.titleLabel?.font = ThemeManager.defaultFont(sizeBy: increaseFontBy)
            self.updateButtonSize()
        }
    }
    
    /**
     Color of the radio button stroke circle. Default value is UIColor red.
     */
    @IBInspectable var strokeColor: UIColor = ThemeManager.currentTheme().borderColor {
        didSet {
            circleLayer.strokeColor = strokeColor.cgColor
            self.toggleButon()
        }
    }
    
    /**
     Radius of RadioButton circle.
     */
    @IBInspectable var circleRadius: CGFloat = 30.0
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    var thirdPartyLabel: BrandLabel = {
        let label = BrandLabel(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
        label.numberOfLines = 0
        return label
    }()
    
    var useThirdPartyLabel: Bool = false {
        didSet {
            if useThirdPartyLabel {
                let label = self.thirdPartyLabel
                label.translatesAutoresizingMaskIntoConstraints = false
                self.addSubview(label)
                label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 50).isActive = true
                label.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).isActive = true
                self.trailingAnchor.constraint(equalTo: label.trailingAnchor, constant: 10).isActive = true
            }
        }
    }
    
    fileprivate func circleFrame() -> CGRect {
        var circleFrame = CGRect(x: 0, y: 0, width: (circleRadius - circleLayer.lineWidth), height: (circleRadius - circleLayer.lineWidth))
        circleFrame.origin.x = 0 + circleLayer.lineWidth
        circleFrame.origin.y = bounds.height/2 - circleFrame.height/2
        return circleFrame
    }
    
    fileprivate func drawCheckmark()->CGPath {
        
        let bezierPath = UIBezierPath()
        
        let width = circleRadius - (lineWidth * 2)
        let height = circleRadius - (lineWidth * 2)
        
        let quaterX =  (width * 0.25)
        let quaterY =  (height * 0.25)
        
        bezierPath.move(to: CGPoint(x: quaterX, y: height - (quaterY * 2)))
        bezierPath.addLine(to: CGPoint(x: quaterX * 2 , y: quaterY * 3  ))
        bezierPath.move(to: CGPoint(x: quaterX * 2 , y: quaterY * 3  ))
        bezierPath.addLine(to: CGPoint(x: (quaterX * 3) + (quaterX / 2) , y: height - (quaterY * 3)  ))
        
        return bezierPath.cgPath
    }
    
    deinit {
        self.removeTarget(self, action: #selector(RadioButton.pressed(_:)), for: UIControl.Event.touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    init() {
        super.init(frame: CGRect.zero)
        initialize()
    }
    
    fileprivate func initialize() {
        self.contentHorizontalAlignment = .left
        //self.titleLabel?.font = ThemeManager.defaultFont(sizeBy: increaseFontBy)
        self.tintColor = UIColor.clear
        self.setTitleColor(textColor, for: .selected)
        self.setTitleColor(textColor, for: .normal)
        self.addTarget(self, action: #selector(RadioButton.pressed(_:)), for: UIControl.Event.touchUpInside)
        self.backgroundColor = UIColor.clear
        circleLayer.frame = bounds
        circleLayer.lineWidth = self.lineWidth
        circleLayer.fillColor = UIColor.white.cgColor
        circleLayer.strokeColor = strokeColor.cgColor
        layer.addSublayer(circleLayer)
        fillCircleLayer.frame = bounds
        fillCircleLayer.lineWidth = self.lineWidth
        fillCircleLayer.fillColor = UIColor.clear.cgColor
        fillCircleLayer.strokeColor = UIColor.clear.cgColor
        layer.addSublayer(fillCircleLayer)
        checkmarkLayer.frame = bounds
        checkmarkLayer.path = drawCheckmark()
        checkmarkLayer.strokeColor = UIColor.clear.cgColor;
        checkmarkLayer.lineWidth = self.lineWidth
        layer.addSublayer(checkmarkLayer)
        self.titleEdgeInsets = UIEdgeInsets.init(top: 0, left: ((circleRadius + 4*circleLayer.lineWidth) + 5), bottom: 0, right: 0)
        self.toggleButon()
        
    }
    
    override func setTitle(_ title: String?, for state: UIControl.State) {
        if self.useThirdPartyLabel {
            self.thirdPartyLabel.text = title
            super.setTitle(String(repeating: " ", count: (title ?? "").count), for: state)
            self.titleLabel?.textColor = UIColor.clear
        }
        else {
            super.setTitle(title, for: state)
        }
        self.updateButtonSize()
    }
    
    fileprivate func updateButtonSize() {
        if let originalString = self.currentTitle {
//            let myString: NSString = originalString as NSString
//            let size: CGSize = myString.size(withAttributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14.0)])
            if let labelFont = self.titleLabel?.font {
                let width = originalString.width(withConstrainedHeight: 30, font: labelFont) + self.titleEdgeInsets.left + 15
                self.frame = CGRect(x: 0, y: 0, width: width, height: 30)
                self.bounds = CGRect(x: 0, y: 0, width: width, height: 30)
            }
        }
    }
    
    fileprivate func circlePath() -> UIBezierPath {
        return UIBezierPath(ovalIn: circleFrame())
    }
    
    fileprivate func fillCirclePath() -> UIBezierPath {
        //circleFrame().insetBy(dx: 2, dy: 2)
        return UIBezierPath(ovalIn: circleFrame())
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        circleLayer.frame = bounds
        circleLayer.path = circlePath().cgPath
        fillCircleLayer.frame = bounds
        fillCircleLayer.path = fillCirclePath().cgPath
    
        self.titleEdgeInsets = UIEdgeInsets.init(top: 0, left: ((circleRadius + 4*circleLayer.lineWidth) + 5), bottom: 0, right: 0)
    }
    
    /**
     Toggles selected state of the button.
     */
    func toggleButon() {
        if self.isSelected {
            fillCircleLayer.fillColor = selectedColor.cgColor
            circleLayer.strokeColor = UIColor.clear.cgColor
            checkmarkLayer.strokeColor = checkMarkColor.cgColor
            radioButtonSelectPublisher.onNext((self, .selected))
        } else {
            fillCircleLayer.fillColor = UIColor.clear.cgColor
            circleLayer.strokeColor = strokeColor.cgColor
            checkmarkLayer.strokeColor = UIColor.clear.cgColor
            radioButtonSelectPublisher.onNext((self, .deselected))
        }
    }
    
    override func prepareForInterfaceBuilder() {
        initialize()
    }
    
    @objc func pressed(_ sender: UIButton) {
        self.isSelected = !self.isSelected
    }
    
}
