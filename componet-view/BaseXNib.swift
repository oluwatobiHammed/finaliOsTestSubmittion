//
//  BaseXNib.swift
//  CustomLoginDemo
//
//  Created by Oladipupo Oluwatobi Hammed on 19/05/2020.
//  Copyright © 2020 Christopher Ching. All rights reserved.
//

import UIKit

class BaseXNib: UIView {

    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
//    override func draw(_ rect: CGRect) {
//
//        // Drawing code
//    }
    

    func setupXnib() {
        if let nibName = getNibName() {
            Bundle.main.loadNibNamed(nibName, owner: self, options: nil)
            guard let content = getContentView() else { return }
            content.frame = self.bounds
            content.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            self.addSubview(content)
        }
    }
    
    func getNibName()-> String? {
        return nil
    }
    
    func getContentView()-> UIView? {
        return nil
    }
    
    deinit {
        print("Destroying \(self)")
    }
}

