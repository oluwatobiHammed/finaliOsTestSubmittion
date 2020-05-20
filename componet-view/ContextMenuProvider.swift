//
//  ContextMenuProvider.swift
//  CustomLoginDemo
//
//  Created by Oladipupo Oluwatobi Hammed on 19/05/2020.
//  Copyright © 2020 Christopher Ching. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

struct ContextMenuRequest {
    var items: [String]
    var anchorView: UIView
    fileprivate let menuItemSelectedSubject = PublishSubject<Any?>()
    
    var menuItemSelected: Observable<Any?> {
        return menuItemSelectedSubject.asObservable()
    }
    
    func sendSelectedValue(value: Any?) {
        menuItemSelectedSubject.onNext(value)
    }
    
    func complete() {
        menuItemSelectedSubject.onCompleted()
    }
}

class ContextMenuProvider {
    static let shared = ContextMenuProvider()
    fileprivate let showDropDownSubject = PublishSubject<ContextMenuRequest>()
    
    var onShowContextMenuRequested: Observable<ContextMenuRequest> {
        return showDropDownSubject.asObservable()
    }
    
    fileprivate init() {
        
    }
    
    func showDropdown(dropdownItems: [String], anchorView: UIView)-> ContextMenuRequest {
        let request = ContextMenuRequest(items: dropdownItems, anchorView: anchorView)
        showDropDownSubject.onNext(request)
        return request
    }
}

