//
//  RadioButtonGroup.swift
//  FCMB-Mobile
//
//  Created by Kembene Nkem-Etoh on 2/19/18.
//  Copyright © 2018 FCMB. All rights reserved.
//

import Foundation
import UIKit
import RxSwift



class RadioButtonGroup {
    
    fileprivate var radioButtonSelectPublisher = PublishSubject<(RadioButton, RadioButtonSelectionType)>()
    
    var disposeBag = DisposeBag()
    var disposables: [Disposable] = []
    
    var buttonSelect: Observable<(RadioButton, RadioButtonSelectionType)> {
        return radioButtonSelectPublisher.asObservable()
    }
    
    
    fileprivate var buttonsArray = [RadioButton]()
    var currentSelected: RadioButton?
    var allowMultiple = false
    
    var getButtons: [RadioButton] {
        return buttonsArray
    }
    
    func addButton(_ aButton: RadioButton) {
        buttonsArray.append(aButton)
        let disposeable = aButton.buttonSelect.subscribe(onNext: { (value) in
            let button = value.0
            let type = value.1
            switch type {
            case .deselected:
                self.currentSelected = nil
            case .selected:
                self.currentSelected?.isSelected = false
                self.currentSelected = button
            }
            self.radioButtonSelectPublisher.onNext(value)
        }, onError: { (error) in
            
        }, onCompleted: {
            
        }) {
            
        }
        disposables.append(disposeable)
        disposeable.disposed(by: disposeBag)
    }
    
    func setButtonsArray(_ aButtonsArray: [RadioButton]) {
        disposables.forEach { (disposable) in
            disposable.dispose()
        }
        disposables = []
        buttonsArray = []
        aButtonsArray.forEach { (button) in
            self.addButton(button)
        }
    }
    
    func selectButtonAtIndex(index: Int) {
        if index < buttonsArray.count {
            let button = buttonsArray[index]
            button.isSelected = true
        }
    }
}

//extension RadioButtonGroup: RadioButtonSelectDelegate {
//    func didSelectButton(selectedButton: RadioButton) {
//        buttonSelectDelegate?.didSelectButton?(selectedButton: selectedButton)
//        if !allowMultiple {
//            if currentSelected != nil {
//                currentSelected!.isSelected = false
//                self.currentSelected = selectedButton
//            }
//        }
//        self.currentSelected = selectedButton
//    }
//
//    func didDeSelectButton(deSelectedButton: RadioButton) {
//        buttonSelectDelegate?.didDeSelectButton?(deSelectedButton: deSelectedButton)
//        if !allowMultiple {
//            self.currentSelected = nil
//        }
//    }
//
//
//}

