//
//  ButtomActionButton.swift
//  FCMB-Mobile
//
//  Created by Kembene Nkem-Etoh on 2/20/18.
//  Copyright © 2018 FCMB. All rights reserved.
//

import UIKit

protocol ButtomButtonClickDelegate{
    func onButtonClicked(button: UIButton)
}

//@IBDesignable
class ButtomActionButton: BaseXNib {
    var delegate: ButtomButtonClickDelegate?
    @IBOutlet weak var button: UIButton?
    @IBOutlet weak var contentView: UIView?
    @IBOutlet weak var activity: UIActivityIndicatorView?
    var lastTitleColor: UIColor?
    @IBInspectable var buttonText: String? = "" {
        didSet {
            button?.setTitle(buttonText, for: .normal)
        }
    }
    
    @IBInspectable var isEnabled: Bool = true {
        didSet {
            self.button?.isEnabled = self.isEnabled
        }
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
//    deinit {
//        self.button?.removeTarget(self, action: #selector(ButtomActionButton.pressed(_:)), for: UIControlEvents.touchUpInside)
//    }
  
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupXnib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupXnib()
    }

    override func setupXnib() {
        super.setupXnib()
        self.button?.customizeToTheme()
        self.activity?.customizeToTheme()
        self.activity?.stopAnimating()
        contentView?.backgroundColor = ThemeManager.currentTheme().backgroundColor
        self.button?.addTarget(self, action: #selector(ButtomActionButton.pressed(_:)), for: UIControl.Event.touchUpInside)
    }
    
    override func getNibName()-> String? {
        return "ButtomActionButton"
    }
    
    override func getContentView()-> UIView? {
        return contentView
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupXnib()
    }
    
    @objc func pressed(_ sender: UIButton) {
        self.delegate?.onButtonClicked(button: sender)
    }
    
    
    func switchToLoadingState(performSwtich: Bool) {
        if performSwtich {
            self.activity?.color = button?.titleColor(for: .normal)
            self.activity?.startAnimating()
            self.button?.isEnabled = false
        }
        else {            
            self.activity?.stopAnimating()
            self.button?.isEnabled = true
        }
    }
    
}
