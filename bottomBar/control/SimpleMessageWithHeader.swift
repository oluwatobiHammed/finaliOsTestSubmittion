//
//  SimpleMessageWithHeader.swift
//  CustomLoginDemo
//
//  Created by Oladipupo Oluwatobi Hammed on 19/05/2020.
//  Copyright © 2020 Christopher Ching. All rights reserved.
//

import UIKit

class SimpleMessageWithHeader: BaseXNib {

    @IBOutlet weak var contentView: UIView?
    @IBOutlet weak var headerLabel: UILabel?
    @IBOutlet weak var textLabel: UILabel?
    @IBOutlet weak var subTextLabel: UILabel?
    @IBOutlet weak var textLabelBottomAnchor: NSLayoutConstraint?
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

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
        headerLabel?.useCaptionFont(by: 3)
        textLabel?.useDefaultFont(by: 1)
        subTextLabel?.text = nil
    }
    
    override func getContentView() -> UIView? {
        return contentView
    }
    override func getNibName() -> String? {
        return "SimpleMessageWithHeader"
    }
    
    class func createWith(message: StringResource, header: StringResource?, estimatedHeight: CGFloat = 150)->SimpleMessageWithHeader {
        let widget = SimpleMessageWithHeader(frame: CGRect(x: 0, y: 0, width: 0, height: estimatedHeight))
        widget.textLabel?.stringResource = message
        if let resource = header {
            widget.headerLabel?.stringResource = resource
        }
        return widget
    }
    class func createWith(message: String, header: String?, estimatedHeight: CGFloat = 150)->SimpleMessageWithHeader {
        let widget = SimpleMessageWithHeader(frame: CGRect(x: 0, y: 0, width: 0, height: estimatedHeight))
        widget.headerLabel?.text = header
        widget.textLabel?.text = message
        return widget
    }
    
    class func createWith(message: NSAttributedString, header: String?, estimatedHeight: CGFloat = 150)->SimpleMessageWithHeader {
        let widget = SimpleMessageWithHeader(frame: CGRect(x: 0, y: 0, width: 0, height: estimatedHeight))
        widget.headerLabel?.text = header
        widget.textLabel?.attributedText = message
        return widget
    }
}

