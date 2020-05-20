//
//  InputFieldGroup.swift
//  CustomLoginDemo
//
//  Created by Oladipupo Oluwatobi Hammed on 19/05/2020.
//  Copyright © 2020 Christopher Ching. All rights reserved.
//


import UIKit
import RxSwift
import ObjectMapper

enum InputFieldType: String {
    case defaultType = "defaultType"
    case decimal = "decimal"
    case email = "email"
    case number = "number"
    case phone = "phone"
    case url = "url"
    case password = "password"
    case username = "username"
    case accountNumber = "accountNumber"
    case pin = "pin"
    case otp = "otp"
    case bvn = "bvn"
}

protocol InputFieldValueProvider {
    func getValue()-> Any?
}

struct StringInputFieldValueProvider: InputFieldValueProvider {
    var value: String
    
    func getValue() -> Any? {
        return value
    }
}

enum RecurringFieldType: String, RadioListDataItem {
    case instant = "Instant"
    case later = "Later"
    case repeating = "Repeating"
    
    func getItemLabel() -> String {
        return self.rawValue
    }
    
    func getRequestValue()-> String {
        switch self {
        case .instant:
            return "ONE_TIME"
        case .later:
            return "SCHEDULED"
        case .repeating:
            return "SUBSCRIPTION"
        }
    }
    
    func getParameterValue()-> String {
        switch self {
        case .instant:
            return "ONE_TIME"
        case .later:
            return "SCHEDULED"
        case .repeating:
            return "SUBSCRIPTION"
        }
    }
    
    static func fromAPIString(value: String?)-> RecurringFieldType? {
        if value == "ONE_TIME" {
            return .instant
        }
        else if value == "SCHEDULED" {
            return .later
        }
        else if value == "SUBSCRIPTION" {
            return .repeating
        }
        if let val = value {
            return RecurringFieldType(rawValue: val)
        }
        return nil
    }
}

class RecurringTypeTransformer: TransformType {
    typealias Object = RecurringFieldType
    
    typealias JSON = String
    
    open func transformFromJSON(_ value: Any?) -> Object? {
        if let val = value as? String {
            return RecurringFieldType.fromAPIString(value: val)
        }
        return nil
    }
    
    open func transformToJSON(_ value: RecurringFieldType?) -> JSON? {
        if let val = value {
            return val.rawValue
        }
        return nil
    }
    
    static var instance: RecurringTypeTransformer = {
        return RecurringTypeTransformer()
    }()
    
}

enum RecurringFrequencyFieldType: String, RadioListDataItem {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case custom = "Custom"
    
    func getItemLabel() -> String {
        return self.rawValue
    }
    
    func getParameterValue()-> String {
        return self.rawValue.uppercased()
    }
    
    static func fromAPIString(value: String?)-> RecurringFrequencyFieldType? {
        if value == "DAILY" {
            return .daily
        }
        else if value == "WEEKLY" {
            return .weekly
        }
        else if value == "MONTHLY" {
            return .monthly
        }
        else if value == "CUSTOM" {
            return .custom
        }
        if let val = value {
            return RecurringFrequencyFieldType(rawValue: val)
        }
        return nil
    }
}

class RecurringFrequencyFieldTransformer: TransformType {
    typealias Object = RecurringFrequencyFieldType
    
    typealias JSON = String
    
    open func transformFromJSON(_ value: Any?) -> Object? {
        if let val = value as? String {
            return RecurringFrequencyFieldType.fromAPIString(value: val)
        }
        return nil
    }
    
    open func transformToJSON(_ value: Object?) -> JSON? {
        if let val = value {
            return val.rawValue
        }
        return nil
    }
    
    static var instance: RecurringFrequencyFieldTransformer = {
        return RecurringFrequencyFieldTransformer()
    }()
    
}

enum InputFieldGroupState {
    case entryState
    case summaryState
}

//@IBDesignable
class InputFieldGroup: BaseXNib {
    
    @IBOutlet var contentView: UIView?
    @IBOutlet weak var inputField: UITextField?
    @IBOutlet weak var leftAddon: LabelWithKeyboardGesture?
    @IBOutlet weak var rightAddon: UILabel?
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView?
    @IBOutlet weak var errorMessageLabel: UILabel?
    @IBOutlet weak var rightIconTrailingConstraint: NSLayoutConstraint?
    @IBOutlet weak fileprivate var leftIconLeadingConstraint: NSLayoutConstraint?
    @IBOutlet weak var leftIconWidthConstraint: NSLayoutConstraint?
    @IBOutlet weak var summaryView: UIView!
    @IBOutlet weak var summaryTitleLabel: UILabel!
    @IBOutlet weak var summaryValueLabel: UILabel!
    @IBOutlet weak var summaryButton: UIButton!
    
    @IBOutlet weak var inputLeadingToContainer: NSLayoutConstraint!
    @IBOutlet weak var inputTrailingToContainer: NSLayoutConstraint!
    
    @IBOutlet weak var inputLeadingToLeftIcon: NSLayoutConstraint!
    @IBOutlet weak var inputTrailingToRightIcon: NSLayoutConstraint!
    
    @IBOutlet weak var rightLabelWidth: NSLayoutConstraint!
    @IBOutlet weak var rightLabelHeight: NSLayoutConstraint!
    
    @IBOutlet weak var leftImageView: UIImageView!
    
    @IBOutlet weak var numberCounterContainer: UIView?
    @IBOutlet weak var numberCounterUp: UIButton?
    @IBOutlet weak var numberCounterDown: UIButton?
    @IBOutlet weak var rightImageView: UIImageView?
    
    var numberCounterStep: Double = 1.0
    var numberCounterAsInteger = false
    
    var debugPrintValue = true
    var onCharacterLimitReached: ((_ field: InputFieldGroup)->Void)?
    var valueTransformer: ((_ value: Any?, _ field: InputFieldGroup)-> Any?)?
    
    var useThousandSeperator = false {
        didSet {
//            NotificationCenter.default.addObserver(self, selector: #selector(textDidChange(_:)), name:NSNotification.Name.UITextFieldTextDidChange, object: self)
            NotificationCenter.default.addObserver(self, selector: #selector(textDidChange(_:)), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)

        }
    }
    var thousandPreviousValue : String = ""
    
    var rightImage: UIImage? {
        didSet {
            if let image = rightImage{
                self.rightImageView?.image = image
                self.rightImageView?.isHidden = false
            }
            else{
                self.rightImageView?.isHidden = true
            }
        }
    }
    
    var thousandNumberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = ","
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    fileprivate var onBlurPublisher = PublishSubject<Any?>()
    var disposeBab: DisposeBag = DisposeBag()
    var onBlurObservable: Observable<Any?> {
        return onBlurPublisher.asObserver()
    }
    
    var characterLimit: Int?
    
    var inputFieldGroupDelegate: InputFieldGroupDelegate?
    var isTextInput = true
    var canUseFieldTextForValue = true
    var leftIconSet = false
    fileprivate var _fieldValue: Any?
    var fieldValue: Any? {
        set {
            self.isDirty = true
            self._fieldValue = newValue
        }
        get {
            return self._fieldValue
        }
    }
    var isDirty = false
    
    var doneToolbarButton: UIBarButtonItem!
    var cancelToolbarButton: UIBarButtonItem!
    var titleToolbarButton: UIBarButtonItem!
    var toolBar: UIToolbar!
    
    var doneToolbarButtonText: String? = "Done" {
        didSet {
            doneToolbarButton.title = doneToolbarButtonText
        }
    }
    
    var cancelToolbarButtonText: String? = "Cancel" {
        didSet {
            cancelToolbarButton.title = cancelToolbarButtonText
        }
    }
    
    var titleToolbarButtonText: String? = nil{
        didSet {
            titleToolbarButton.title = titleToolbarButtonText
        }
    }
    
    var displayValidationErrorMessage = true
    
    var fieldState: InputFieldGroupState = InputFieldGroupState.entryState
    
    fileprivate var validatorSet: Set<Validator> = []
    
    var minLengthValidator: MinLengthValidator = {
       return MinLengthValidator()
    }()
    var minIntegerValidator: MinIntegerValidator = {
       return MinIntegerValidator()
    }()
    var maxIntegerValidator: MaxIntegerValidator = {
        return MaxIntegerValidator()
    }()
    var maxLengthValidator: MaxLengthValidator = {
        return MaxLengthValidator()
    }()
    var exactlyMinOrMaxValidator: ExactLengthValidator = {
        return ExactLengthValidator()
    }()
    var exactLengthValidator: ExactLengthValidator = {
        return ExactLengthValidator()
    }()
    var confirmValidator: FieldsValueComparisonValidator = {
        return FieldsValueComparisonValidator()
    }()
    var requiredValidator: RequiredValidator = {
        return Validators.required.instance(config: nil) as! RequiredValidator
    }()
    var asyncUsernameValidator: ConfirmUsernameAsyncValidator = {
        return ConfirmUsernameAsyncValidator(inputField: nil)
    }()
    
    
    var passwordIsVisible = false
    var passwordVisibilityAddOnRecognizer: UITapGestureRecognizer?
    
    @IBInspectable var fieldName: String? = nil
    
    @IBInspectable var removeLeftIconSpace: Bool = true{
        didSet {
            if removeLeftIconSpace {
                self.inputLeadingToContainer.isActive = true
                self.inputLeadingToLeftIcon.isActive = false
                self.leftIconWidthConstraint?.constant = 0
//                self.leftIconLeadingConstraint?.constant = 0
            }
            else{
                self.inputLeadingToContainer.isActive = false
                self.inputLeadingToLeftIcon.isActive = true
                self.leftIconWidthConstraint?.constant = 30
//                self.leftIconLeadingConstraint?.constant = 20
            }
        }
    }
    
    @IBInspectable var passwordVisibility: Bool = false {
        didSet {
            if passwordVisibility {
                if !hasSetupPasswordVisibility {
                    hasSetupPasswordVisibility = true
                    self.showRightIcon = true
                    self.rightIcon = "eye"
                    self.rightLabelWidth.constant = 50
                    self.rightLabelHeight.constant = 50
                    self.rightAddon?.isUserInteractionEnabled = true
                    if passwordVisibilityAddOnRecognizer == nil {
                        passwordVisibilityAddOnRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTogglePasswordVisibility))
                            rightAddon?.addGestureRecognizer(passwordVisibilityAddOnRecognizer!)
                    }
                }
                
                
            }
        }
    }
    var hasSetupPasswordVisibility = false
    var useShowHideTextIcon = false {
        didSet {
            if useShowHideTextIcon {
                self.rightLabelWidth.constant = 50
                self.passwordVisibility = true
                self.rightAddon?.usingIcon(icon: FontIcon.show_text, size: 10, color: nil)
            }
        }
    }
    
    @IBInspectable var validRequired: Bool = false{
        didSet {
            if validRequired {
                self.addValidator(validator: self.requiredValidator)
            }
            else {
                self.requiredValidator.enabled = false
            }
        }
    }
    
    
    @IBInspectable var minLength: Int = 0 {
        didSet {
            if minLength > 0 {
                self.minLengthValidator.number = minLength
                self.addValidator(validator: self.minLengthValidator)
            }
        }
    }
    
    @IBInspectable var minLengthMessage: String?  {
        didSet {
            if let minLengthMessage = self.minLengthMessage {
                if minLengthMessage.count > 0 {
                    self.minLengthValidator.message = minLengthMessage
                    self.addValidator(validator: self.minLengthValidator)
                }
            }
        }
    }
    
    @IBInspectable var minInteger: Int = 0 {
        didSet {
            if minInteger > 0 {
                self.minIntegerValidator.number = minInteger
                self.addValidator(validator: self.minIntegerValidator)
            }
        }
    }
    
    @IBInspectable var minIntegerMessage: String?  {
        didSet {
            if let minIntegerMessage = self.minIntegerMessage {
                if minIntegerMessage.count > 0 {
                    self.minIntegerValidator.message = minIntegerMessage
                    self.addValidator(validator: self.minIntegerValidator)
                }
            }
        }
    }
    
    @IBInspectable var maxInteger: Int = 0 {
        didSet {
            if maxInteger > 0 {
                self.maxIntegerValidator.number = maxInteger
                self.addValidator(validator: self.maxIntegerValidator)
            }
        }
    }
    
    @IBInspectable var maxIntegerMessage: String?  {
        didSet {
            if let maxIntegerMessage = self.maxIntegerMessage {
                if maxIntegerMessage.count > 0 {
                    self.maxIntegerValidator.message = maxIntegerMessage
                    self.addValidator(validator: self.maxIntegerValidator)
                }
            }
        }
    }
    
    var exactlyMinOrMax: Bool = false
    
    
    @IBInspectable var maxLength: Int = 0 {
        didSet {
            if maxLength > 0 {
                self.maxLengthValidator.number = maxLength
                self.addValidator(validator: self.maxLengthValidator)
            }
        }
    }
    
    @IBInspectable var maxLengthMessage: String?  {
        didSet {
            if let maxLengthMessage = self.maxLengthMessage {
                if maxLengthMessage.count > 0 {
                    self.maxLengthValidator.message = maxLengthMessage
                    self.addValidator(validator: self.maxLengthValidator)
                }
            }
        }
    }
    
    @IBInspectable var exactLength: Int = 0 {
        didSet {
            if exactLength > 0 {
                self.characterLimit = exactLength
                self.exactLengthValidator.enabled = true
                self.exactLengthValidator.number = exactLength
                self.addValidator(validator: self.exactLengthValidator)
            }
            else {
                self.characterLimit = nil
                self.exactLengthValidator.enabled = false
            }
        }
    }
    
    @IBInspectable var exactLengthMessage: String?  {
        didSet {
            if let exactLengthMessage = self.exactLengthMessage {
                if exactLengthMessage.count > 0 {
                    self.exactLengthValidator.message = exactLengthMessage
                    self.addValidator(validator: self.exactLengthValidator)
                }
            }
        }
    }
    
    
    
    @IBInspectable var confirmValidationMessage: String? {
        didSet {
            if let message = confirmValidationMessage {
                self.confirmValidator.errorMessages.removeAll()
                self.confirmValidator.errorMessages.append(message)
                self.addValidator(validator: self.confirmValidator)
            }
        }
    }
    
    
    @IBInspectable var confirmFieldName: String? {
        didSet {
            if let fieldName = confirmFieldName {
                if !fieldName.isEmpty {
                    self.confirmValidator.enabled = true
                    self.confirmValidator.fieldNames.append(fieldName)
                    self.addValidator(validator: self.confirmValidator)
                }
                else {
                    self.confirmValidator.enabled = false
                }
            }
            else {
                self.confirmValidator.enabled = false
            }
        }
    }
    
    @IBInspectable var validEmail: Bool = false{
        didSet {
            if validEmail {
                self.addValidator(validator: Validators.email.instance(config: nil))
            }
        }
    }
    
    @IBInspectable var leftImage: UIImage? {
        didSet {
            if let image = leftImage {
                leftImageView.image = image
                leftImageView.isHidden = false
                leftAddon?.isHidden = true
                removeLeftIconSpace = false
                self.leftIconWidthConstraint?.constant = 30
            }
            else {
                leftImageView.image = nil
                leftImageView.isHidden = true
                leftAddon?.isHidden = false
                removeLeftIconSpace = true
            }
        }
    }
    
    @IBInspectable var showLeftIcon: Bool = true {
        didSet {
            if (showLeftIcon) {
                self.removeLeftIconSpace = false
                self.checkAndDisplayIcon()
            }
            else {
                self.removeLeftIconSpace = true
            }
        }
    }
    @IBInspectable var showRightIcon: Bool = false {
        didSet {
            if (showRightIcon) {
                self.displayRightIcon()
            }
        }
    }
    @IBInspectable var rightIcon: String?{
        didSet {
            if (rightIcon != nil) {
                self.displayRightIcon()
            }
        }
    }
    @IBInspectable var leftIcon: String?{
        didSet {
            if (leftIcon != nil) {
                self.removeLeftIconSpace = false
                self.leftAddon?.usingIcon(icon: FontIcon.fromString(iconName: leftIcon!)!)
                leftIconSet = true
                
            }
        }
    }
    @IBInspectable var placeholder: String? {
        didSet {
            if let place = placeholder {
                if let resource = StringResource(rawValue: place) {
                    self.placeholderValue = resource
                }
                else {
                    self.inputField?.placeholder = place
                }
            }
            self.didSetPlaceholder()
        }
    }
    @IBInspectable var keyboardType: String? {
        didSet {
            if let keyboard = keyboardType {
                self.keyboardTypeValue = InputFieldType(rawValue: keyboard)!
            }
        }
    }
    
    @IBInspectable var returnKeyType: String? = "default" {
        didSet {
            if let returnType = returnKeyType {
                switch returnType {
                case "continue":
                    self.inputField?.returnKeyType = .continue
                case "default":
                    self.inputField?.returnKeyType = .default
                case "done":
                    self.inputField?.returnKeyType = .done
                case "emergencyCall":
                    self.inputField?.returnKeyType = .emergencyCall
                case "go":
                    self.inputField?.returnKeyType = .go
                case "google":
                    self.inputField?.returnKeyType = .google
                case "join":
                    self.inputField?.returnKeyType = .join
                case "next":
                    self.inputField?.returnKeyType = .next
                case "route":
                    self.inputField?.returnKeyType = .route
                case "search":
                    self.inputField?.returnKeyType = .search
                case "send":
                    self.inputField?.returnKeyType = .send
                case "yahoo":
                    self.inputField?.returnKeyType = .yahoo
                default:
                    self.inputField?.returnKeyType = .default
                }
            }
        }
    }
    
    var placeholderValue: StringResource? {
        didSet {
            self.inputField?.placeholder = placeholderValue?.resourceValue
        }
    }
    
    var     keyboardTypeValue = InputFieldType.defaultType {
        didSet {
            switch keyboardTypeValue {
            case .defaultType:
                inputField?.keyboardType = .default
                inputField?.isSecureTextEntry = false
                self.checkAndDisplayIcon()
            case .decimal:
                inputField?.keyboardType = .decimalPad
                inputField?.isSecureTextEntry = false
                self.checkAndDisplayIcon()
            case .email:
                inputField?.keyboardType = .emailAddress
                inputField?.isSecureTextEntry = false
                self.checkAndDisplayIcon()
            case .number:
                inputField?.keyboardType = .numberPad
                inputField?.isSecureTextEntry = false
                self.checkAndDisplayIcon()
            case .phone:
                inputField?.keyboardType = .numberPad//.phonePad
                inputField?.isSecureTextEntry = false
                self.checkAndDisplayIcon()
            case .url :
                inputField?.keyboardType = .URL
                inputField?.isSecureTextEntry = false
                self.checkAndDisplayIcon()
            case .password:
                inputField?.keyboardType = .default
                inputField?.isSecureTextEntry = true
                self.checkAndDisplayIcon()
            case .username:
                inputField?.keyboardType = .default
                inputField?.isSecureTextEntry = false
                self.checkAndDisplayIcon()
            case .accountNumber:
                inputField?.keyboardType = .numberPad
                self.exactLength = 10
                self.characterLimit = 10
                inputField?.isSecureTextEntry = false
                self.exactLengthMessage = "Please enter a valid NUBAN Number"
                self.checkAndDisplayIcon()
            case .pin:
                inputField?.keyboardType = .numberPad
                inputField?.isSecureTextEntry = true
                self.checkAndDisplayIcon()
            case .otp:
                inputField?.keyboardType = .numberPad
                inputField?.isSecureTextEntry = true
                self.checkAndDisplayIcon()
            case .bvn:
                inputField?.keyboardType = .numberPad
                self.exactLength = 11
                self.exactLengthMessage = "Please enter a valid BVN Number"
                self.characterLimit = 11
                inputField?.isSecureTextEntry = false
                self.checkAndDisplayIcon()
            }
        }
    }
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
        
        self.numberCounterContainer?.isHidden = true
        self.numberCounterContainer?.backgroundColor = UIColor.clear
        self.errorMessageLabel?.textColor = ThemeManager.currentTheme().dangerColor
        self.errorMessageLabel?.useDefaultFont(by: -1)
        
        self.backgroundColor = UIColor.clear
        self.contentView?.backgroundColor = UIColor.clear
        self.contentView?.layer.backgroundColor = UIColor.white.cgColor
        self.contentView?.layer.cornerRadius = 3
        self.contentView?.addDefaultBrandBorder()
        self.rightImageView?.isHidden = true
        
        
        activityIndicator?.customizeToTheme()
        self.removeLeftIconSpace = true
        if shouldReceiveTapGesture() {
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(InputFieldGroup.viewTapped(rec:)))
            self.addGestureRecognizer(tapRecognizer)
        }
        if let textField = inputField {
            if isTextInput {
                self.prepareTextfield(textField: textField)
            }
        }
        
//        let leftAddOnRecognizer = UITapGestureRecognizer(target: self, action: #selector(leftLabelWasTapped(rec:)))
//        leftAddon?.addGestureRecognizer(leftAddOnRecognizer)
        leftAddon?.isUserInteractionEnabled = needsLeftLabelInteraction()
        leftAddon?.becameFirstResponder = {
            self.processLeftViewTapped()
        }
        leftAddon?.resignedFromFirstResponder = {
            self.processLeftViewResigned()
        }
        cancelToolbarButton = UIBarButtonItem.init(title: cancelToolbarButtonText, style: .plain, target: self, action: #selector(toolbarCancelButtonClicked))
        titleToolbarButton = UIBarButtonItem.init(title: titleToolbarButtonText, style: .plain, target: self, action: nil)
        let doneButton = UIButton(type: .custom)
        doneButton.setTitle(doneToolbarButtonText, for: .normal)
        doneButton.addTarget(self, action: #selector(toolbarDoneButtonClicked), for: .touchUpInside)
        doneButton.titleLabel?.usingFont(of: .Bold, sizeBy: 2)
        doneButton.setTitleColor(ThemeManager.currentTheme().mainColor, for: .normal)
//        doneToolbarButton = UIBarButtonItem.init(title: doneToolbarButtonText, style: .plain, target: self, action: #selector(toolbarDoneButtonClicked))
        doneToolbarButton = UIBarButtonItem(customView: doneButton)
        
//        toolBar = UIToolbar.init(frame: CGRect.init(x: 0, y: 0,
//                                                    width: ApplicationUtility.appDelegate.window!.frame.width, height: 44))
        //toolBar.customizeForInputAccessory(doneButton: doneToolbarButton, titleItem: titleToolbarButton, cancelButton: cancelToolbarButton)
        
        numberCounterUp?.addTarget(self, action: #selector(onNumberCounterUpClicked), for: .touchUpInside)
        numberCounterDown?.addTarget(self, action: #selector(onNumberCounterDownClicked), for: .touchUpInside)
        self.inputField?.inputAccessoryView = getFieldInputAccessoryView()
    }
    
    @objc func onNumberCounterUpClicked() {
        if let value = Double(self.inputField?.text ?? "0"){
            let val = Int(exactly: value + self.numberCounterStep)
            self.inputField?.text = "\(val ?? 0)"
            self.toolbarDoneButtonClicked()
        }
    }
    
    @objc func onNumberCounterDownClicked() {
        if let value = Double(self.inputField?.text ?? "0"){
            let val = Int(exactly: value - self.numberCounterStep)
            self.inputField?.text = "\(val ?? 0)"
            self.toolbarDoneButtonClicked()
        }
    }
    
    func valid(forceShowError: Bool = false)-> Bool {
        if exactlyMinOrMax {
            let validator = self.exactlyMinOrMaxValidator
            validator.number = minLength
            validator.otherNumber = maxLength
            self.addValidator(validator: validator)
        }
        if let fieldValue = self.getValue() {
            if let valueString = fieldValue as? String {
                if let error_message = self.validateInput(value: valueString as AnyObject) {
                    if self.displayValidationErrorMessage {
                        self.showErrorMessage(error_message, forceShowError: forceShowError)
                    }
                    return false
                }
            }
            else if let array = fieldValue as? Array<Any> {
                for value in array {
                    if let error_message = self.validateInput(value: value as AnyObject) {
                        if self.displayValidationErrorMessage {
                            self.showErrorMessage(error_message, forceShowError: forceShowError)
                        }
                        return false
                    }
                }
            }
            else {
                if let error_message = self.validateInput(value: fieldValue as AnyObject) {
                    if self.displayValidationErrorMessage {
                        self.showErrorMessage(error_message, forceShowError: forceShowError)
                    }
                    return false
                }
            }
        }
        else {
            if let error_message = self.validateInput(value: nil) {
                if self.displayValidationErrorMessage {
                    self.showErrorMessage(error_message, forceShowError: forceShowError)
                }
                return false
            }
        }
        self.hideErrorMessage()
        return true
    }
    
    func addValidator(validator: Validator) {
        validatorSet.insert(validator)
    }
    
    func didSetPlaceholder() {
        
    }
    
    func shouldReceiveTapGesture()->Bool {
        return true
    }
    
    
    
    @objc func onTogglePasswordVisibility() {
        if passwordIsVisible {
            self.inputField?.isSecureTextEntry = true
            if useShowHideTextIcon {
                self.rightAddon?.usingIcon(icon: .show_text, size: 10, color: nil)
            }
            else{
                self.rightAddon?.usingIcon(icon: .eye, size: 20, color: nil)
            }
        }
        else {
            self.inputField?.isSecureTextEntry = false
            if useShowHideTextIcon {
                self.rightAddon?.usingIcon(icon: .hide_text, size: 10, color: ThemeManager.currentTheme().mainColor)
            }
            else{
                self.rightAddon?.usingIcon(icon: .eye, size: 20, color: ThemeManager.currentTheme().mainColor)
            }
        }
        self.passwordIsVisible = !self.passwordIsVisible
    }
    
    func displaySummaryView(label: String, value: String, showSummaryButton: Bool = true, animate: Bool = true) {
        self.summaryTitleLabel.text = label
        self.summaryValueLabel.text = value
        if animate {
            UIView.animate(withDuration: 0.8) {
                self.summaryView.alpha = 1
                if !showSummaryButton {
                    self.summaryButton.alpha = 0
                } else {
                    self.summaryButton.alpha = 1
                }
            }
        }
        else {
            self.summaryView.alpha = 1
            if !showSummaryButton {
                self.summaryButton.alpha = 0
            } else {
                self.summaryButton.alpha = 1
            }
        }
        
        self.fieldState = .summaryState
    }
    
    func hideSummaryView() {
        self.inputField?.text = self.summaryValueLabel.text
        UIView.animate(withDuration: 0.8) {
            self.summaryView.alpha = 0
        }
        self.fieldState = .entryState
    }
    
    @IBAction func changeSummaryButtonWasClicked() {
        self.hideSummaryView()
    }
    
    func showErrorMessage(_ message: String, forceShowError: Bool = false) {
        if isDirty || forceShowError {
            self.displayErrorMessage(message)
        }
    }
    
    func displayErrorMessage(_ message: String) {
        self.errorMessageLabel?.alpha = 0
        self.errorMessageLabel?.text = message
        UIView.animate(withDuration: 1, animations: {
            self.errorMessageLabel?.alpha = 1
        })
    }
    
    func hideErrorMessage() {
        UIView.animate(withDuration: 1, animations: {
            self.errorMessageLabel?.alpha = 0
            self.errorMessageLabel?.text = nil
        })
    }
    
    override func getNibName()-> String? {
        return "InputFieldGroup"
    }
    
    override func getContentView()-> UIView? {
        return contentView
    }
    
    func validateInput(value: AnyObject?)-> String? {
        for validator in validatorSet {
            if validator.enabled {
                if let error = validator.validateAgainst(value, groupDelegate: inputFieldGroupDelegate) {
                    return error
                }
            }
        }
        return nil
    }
    
    func showProgressIndicator(show: Bool) {
        if (show) {
            activityIndicator?.startAnimating()
        }
        else {
            activityIndicator?.stopAnimating()
        }
    }
    
    func applyConstraint() {
    }
    
    func getValue()-> Any? {
        let value = self.doGetValue()
        if let transformer = self.valueTransformer {
            return transformer(value, self)
        }
        return value
    }
    
    func doGetValue()-> Any? {
        if isTextInput && canUseFieldTextForValue {
            if fieldValue != nil {
                return fieldValue
            }
            else {
                return inputField?.text
            }
        }
        if let valueProvider = fieldValue as? InputFieldValueProvider {
            return valueProvider.getValue()
        }
        if let fieldValues = fieldValue as? Array<Any> {
            var theArrays: [Any] = []
            for val in fieldValues {
                if let valueProvider = val as? InputFieldValueProvider {
                    if let theValue = valueProvider.getValue(){
                        theArrays.append(theValue)
                    }
                }
                else {
                    theArrays.append(val)
                }
            }
            return theArrays
        }
        return fieldValue
    }
    
    @objc func viewTapped(rec: UITapGestureRecognizer) {
        if rec.state == .ended {
            self.onInputFieldWasTapped(tappedView: rec.view)
        }
    }
    
    func needsLeftLabelInteraction()->Bool {
        return false
    }
    
    func onInputFieldWasTapped(tappedView: UIView?) {
        let _ = self.becomeFirstResponder()
    }
    
    func processLeftViewTapped() {
        
    }
    
    func processLeftViewResigned() {
        
    }
    
    func activateField() {
        if isTextInput {
            inputField?.becomeFirstResponder()
        }
        else {
            
        }
    }
    
    func checkAndDisplayIcon() {
        if leftIconSet {
            return
        }
        switch keyboardTypeValue {
        case .email:
            self.leftAddon?.usingIcon(icon: .mail)
        case .password:
            self.leftAddon?.usingIcon(icon: .password)
        case .username:
            self.leftAddon?.usingIcon(icon: .user)
        case .accountNumber:
            self.leftAddon?.usingIcon(icon: .user)
        case .pin:
            self.leftAddon?.usingIcon(icon: .password)
        case .otp:
            self.leftAddon?.usingIcon(icon: .password)
        case .bvn:
            self.leftAddon?.usingIcon(icon: .user)
        default:
            break
        }
        self.removeLeftIconSpace = false
    }
    
    func displayRightIcon() {
        if let icon = rightIcon {
            self.rightAddon?.usingIcon(icon: FontIcon.fromString(iconName: icon)!)
        }
    }
    
    func resetField() {
        self.inputField?.text = nil
        self.fieldValue = nil
    }
    
    fileprivate func prepareTextfield(textField: UITextField) {
        textField.delegate = self
    }
    
    override func becomeFirstResponder() -> Bool {
        if fieldState == .entryState {
            activateField()
            inputFieldGroupDelegate?.isMadeCurrentResponder?(source: self)
            return super.becomeFirstResponder()
        }
        return false
    }
    
    override func resignFirstResponder() -> Bool {
        inputFieldGroupDelegate?.onInputGroupBlur?(source: self)
        onBlurPublisher.onNext(self.getValue())
        self.inputField?.resignFirstResponder()
        return super.resignFirstResponder()
    }
    
    func getFieldInputAccessoryView()-> UIView? {
        return self.toolBar
    }
    
    @objc func toolbarDoneButtonClicked() {
        let _ = self.resignFirstResponder()
    }
    
    @objc func toolbarCancelButtonClicked() {
        let _ = inputField?.resignFirstResponder()
//        let _ = self.resignFirstResponder()
    }
    
    func shouldAllowTextEditing()-> Bool {
        return true
    }
}

extension InputFieldGroup: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.isDirty = true
        if fieldState == .entryState {
            inputFieldGroupDelegate?.isMadeCurrentResponder?(source: self)
            inputFieldGroupDelegate?.textFieldIsEditing?(textField)
            let begin = self.shouldAllowTextEditing()
            if begin {
                self.fieldValue = nil
            }
            return begin
        }
        return false
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        let _ = self.resignFirstResponder()
    }
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        inputFieldGroupDelegate?.navigateToNextField?(source: self)
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        var allow = true
        if let limit = characterLimit {
            let newLength = text.count + string.count - range.length
            allow = newLength <= limit
            if newLength == limit{
                onMoveTextFieldToNextItem()
            }
        }
        return allow
    }
    
    fileprivate func onMoveTextFieldToNextItem(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.onCharacterLimitReached?(self)
        }
    }
}

@objc protocol InputFieldGroupDelegate {
    @objc optional func textFieldIsEditing(_ textField: UITextField)
    @objc optional func navigateToNextField(source: InputFieldGroup)
    @objc optional func isMadeCurrentResponder(source: InputFieldGroup)
    @objc optional func onInputGroupBlur(source: InputFieldGroup)
    @objc optional func getFieldValue(fieldName: String)-> AnyObject?
}
