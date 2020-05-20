//
//  InputFieldGroupFormController.swift
//  CustomLoginDemo
//
//  Created by Oladipupo Oluwatobi Hammed on 19/05/2020.
//  Copyright © 2020 Christopher Ching. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

@objc protocol InputFieldFormControllerProtocol {
    @objc optional func onFormValid(valid: Bool)
    @objc optional func onKeyboardDone()
}

class InputFieldGroupFormController {
    var view: UIView?
    var inputFields = [InputFieldGroup]()
    var fieldValues: [String: Any] = [:]
    var lastTextInputGroup: InputFieldGroup?
    var currentInputGroup: InputFieldGroup?
    private var boundButton: UIButton?
    var delegate: InputFieldFormControllerProtocol?
    var enableValidation = false
    var validateOnBlur = false
    fileprivate var formIsValidSubscription = BehaviorSubject<Bool>(value: true)
    var formIsValidObservable: Observable<Bool> {
        return formIsValidSubscription.asObservable()
    }
    var formIsValid: Bool {
        do {
            return try formIsValidSubscription.value()
        } catch {
            return false
        }
    }
    init(parentView: UIView?) {
        if let view = parentView {
            loadInputGroups(view: view)
        }
    }

    func bind(to: UIButton?, validateOnBlur: Bool = true) {
        if boundButton != nil {
            self.validateOnBlur = false
            self.enableValidation = false
            boundButton!.isEnabled = true
        }
        to?.isEnabled = false
        self.boundButton = to
        if boundButton != nil {
            self.validateOnBlur = validateOnBlur
            self.enableValidation = true
        }
        self.checkFieldsValidity(field: nil, forceShowError: false)
        
    }
    
    func bind(bottomAction: ButtomActionButton?, validateOnBlur: Bool = true) {
        if bottomAction != nil {
            bind(to: bottomAction!.button, validateOnBlur: validateOnBlur)
        }
        else {
            bind(to: nil)
        }
    }
    
    func loadInputGroups(view: UIView) {
        removeAllFieldGroups()
        self.view = view
        preloadInputGroups(view: view)
        if let inputGroup = lastTextInputGroup {
            if let inputField = inputGroup.inputField{
                if inputField.returnKeyType == .next {
                    inputField.returnKeyType = .done
                }
            }
        }
    }
    
    func addInputGroupsFromView(view: UIView) {
        self.preloadInputGroups(view: view)
    }
    
    fileprivate func preloadInputGroups(view: UIView) {
        for v in view.subviews {
            if let inputGroup = v as? InputFieldGroup {
                addInputFieldGroup(fieldGroup: inputGroup)
                if inputGroup.isTextInput {
                    if let inputField = inputGroup.inputField{
                        if inputField.returnKeyType == .default {
                            inputField.returnKeyType = .next
                        }
                    }
                    lastTextInputGroup = inputGroup
                }
                self.collectValueFor(field: inputGroup)
            }
            else if v.subviews.count > 0 { // recursive
                preloadInputGroups(view: v)
            }
        }
    }
    
    func resetFields() {
        self.fieldValues = [:]
        for field in inputFields {
            field.resetField()
        }
    }

    
    func addInputFieldGroup(fieldGroup: InputFieldGroup) {
        let index = inputFields.count
        fieldGroup.tag = index
        inputFields.append(fieldGroup)
        fieldGroup.inputFieldGroupDelegate = self
    }
    
    func removeFieldGroup(inputField: InputFieldGroup) {
        if let index = inputFields.index(of: inputField) {
            let field = inputFields[index]
            field.inputFieldGroupDelegate = nil
            inputFields.remove(at: index)
            let fieldName = getNameForField(field: inputField)
            fieldValues[fieldName] = nil
        }
    }
    
    func removeAllFieldGroups() {
        for group in inputFields {
            group.inputFieldGroupDelegate = nil
        }
        inputFields = []
        fieldValues = [:]
    }
    
    
    func collectFieldValueAfterDone()-> Bool {
        if let view = self.view{
            view.endEditing(true)
        }
        else{
            let oldValidateOnBlur = validateOnBlur
            validateOnBlur = false
            for input in inputFields {
                let _ = input.resignFirstResponder()
            }
            validateOnBlur = oldValidateOnBlur
        }
        self.delegate?.onKeyboardDone?()
        let valid = self.checkFieldsValidity()
        self.delegate?.onFormValid?(valid: valid)
        return valid
    }
    
    func checkFieldsValidity(field: InputFieldGroup? = nil, forceShowError: Bool = true)-> Bool {
        var valid = true
        if enableValidation {
            
            for input in inputFields {
                if let testField = field {
                    if testField != input {
                        input.displayValidationErrorMessage = false
                    }
                }
                if !input.valid(forceShowError: forceShowError){
                    valid = false
                }
                input.displayValidationErrorMessage = true
            }
            if let button = boundButton {
                if valid {
                    button.isEnabled = true
                }
                else {
                    button.isEnabled = false
                }
            }
        }
        self.formIsValidSubscription.onNext(valid)
        return valid
    }
    
//    func positionKeyboard(_ textView: UITextField?) {
////        var keyboardToolbar: UIView = self.keyboardToolbar
//        if addedKeyboardToSuperView {
//            keyboardToolbar.removeFromSuperview()
//            addedKeyboardToSuperView = false
//        }
//        if let _ = textView?.inputAccessoryView {
//            // if there is aready an accessory view, then lets not use our. It's the responsibility of the view to respond to the accessory view
////            keyboardToolbar = accessoryView
//            return
//        }
//
//        if let text = textView {
//            text.inputAccessoryView = keyboardToolbar
//        }
//        else{
//            addedKeyboardToSuperView = true
//            view.addSubview(keyboardToolbar)
//            keyboardToolbar.translatesAutoresizingMaskIntoConstraints = false
//            keyboardToolbar.heightAnchor.constraint(equalToConstant: keyboardToolbar.frame.height).isActive = true
//            NSLayoutConstraint(item: keyboardToolbar, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
//            NSLayoutConstraint(item: keyboardToolbar, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
//            NSLayoutConstraint(item: view, attribute: .bottomMargin, relatedBy: .equal, toItem: keyboardToolbar, attribute: .bottom, multiplier: 1.0, constant: 20.0).isActive = true
//        }
//    }
    
    func getValues()-> [String: Any] {
        return fieldValues
    }
    
    func fetchFieldValues()-> [String: Any] {
        var values: [String: Any] = [:]
        for item in inputFields {
            let info = getValuePairForField(field: item)
            values[info.0] = info.1
        }
        self.fieldValues = values
        return values
    }
    
    func getValuePairForField(field: InputFieldGroup)-> (String, Any?) {
        let fieldName = self.getNameForField(field: field)
        return (fieldName, field.getValue())
    }
    
    func getNameForField(field: InputFieldGroup)-> String {
        var fieldName = field.fieldName
        if fieldName == nil {
            fieldName = String(field.tag)
        }
        return fieldName!
    }
    
    func collectValueFor(field: InputFieldGroup){
        let info = getValuePairForField(field: field)
        fieldValues[info.0] = info.1
    }
    
    func collectFieldValues() {
        self.inputFields.forEach { (field) in
            self.collectValueFor(field: field)
        }
    }
    
    func fetchValueForField(field: InputFieldGroup) -> Any? {
        var fieldName = field.fieldName
        if fieldName == nil {
            fieldName = String(field.tag)
        }
        return self.fetchValueForField(withName: fieldName!)
    }
    
    func fetchValueForField(withName: String) -> Any? {
        return fieldValues[withName]
    }
}


extension InputFieldGroupFormController: InputFieldGroupDelegate {
    func textFieldIsEditing(_ textField: UITextField) {
//        positionKeyboard(textField)
    }
    
    func navigateToNextField(source: InputFieldGroup) {
        
    }
    
    func isMadeCurrentResponder(source: InputFieldGroup) {
        currentInputGroup = source
    }
    
    func onInputGroupBlur(source: InputFieldGroup) {
        self.collectValueFor(field: source)
        
        if validateOnBlur {
            let _ = self.checkFieldsValidity(field: source)
        }
        var values = getValues()
        let remove = inputFields.filter { (group) -> Bool in
            return group.debugPrintValue == false
        }
        remove.forEach { (group) in
            let name = self.getNameForField(field: group)
            values[name] = "Masked"
        }
        print(values)
    }
    
    func getFieldValue(fieldName: String)-> AnyObject? {
        return self.fetchValueForField(withName: fieldName) as AnyObject
    }
}

