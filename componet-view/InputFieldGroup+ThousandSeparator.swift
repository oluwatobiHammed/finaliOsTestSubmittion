//
//  InputFieldGroup+ThousandSeparator.swift
//  CustomLoginDemo
//
//  Created by Oladipupo Oluwatobi Hammed on 19/05/2020.
//  Copyright © 2020 Christopher Ching. All rights reserved.
//

import Foundation

extension InputFieldGroup {
    @objc func textDidChange(_ notification: Notification){
        self.formatAmountTextOnField()
        
    }
    
    func formatAmountTextOnField() {
        let cleanNumericString : String = getCleanNumberString()
        let textFieldNumber = Double(cleanNumericString)
        
        if let textFieldNumber = textFieldNumber{
            setAmount(textFieldNumber, addDot: cleanNumericString.hasSuffix("."))
        }else{
            self.inputField?.text = cleanNumericString
        }

//                if let newPosition = field.position(from: field.endOfDocument, offset: 0 - offset) {
//                    field.selectedTextRange = field.textRange(from: newPosition, to: newPosition)

    }
    
    //MARK: - Custom text field functions
    
    func setAmount (_ amount : Double, addDot: Bool = false){
        var textFieldStringValue = self.thousandNumberFormatter.string(from: NSNumber(value: amount))
        if addDot {
            textFieldStringValue = "\(textFieldStringValue ?? "")."
        }
        self.inputField?.text = textFieldStringValue
        if let textFieldStringValue = textFieldStringValue{
            thousandPreviousValue = textFieldStringValue
        }
    }
    
    //MARK - helper functions
    
    func getCleanNumberString() -> String {
        var cleanNumericString: String = ""
        let textFieldString = self.inputField?.text
        if let textFieldString = textFieldString{
            cleanNumericString = textFieldString
            
            //Remove periods, commas
            let toArray = cleanNumericString
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .components(separatedBy: ",")//CharacterSet.punctuationCharacters)
            cleanNumericString = toArray.joined(separator: "")
        }
        
        return cleanNumericString
    }
    
    
}

