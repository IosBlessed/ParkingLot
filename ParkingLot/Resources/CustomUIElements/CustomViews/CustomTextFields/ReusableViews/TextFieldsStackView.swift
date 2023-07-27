//
//  TextFieldsView.swift
//  ParkingLot
//
//  Created by Никита Данилович on 14.06.2023.
//

import UIKit
import Combine

class TextFieldsStackView: UIView {
    
    // MARK: - Outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var stackView: UIStackView! {
        didSet {
            stackView.axis = .vertical
            stackView.distribution = .fillEqually
            stackView.alignment = .fill
            stackView.isLayoutMarginsRelativeArrangement = true
            stackView.spacing = CustomTextFieldConstants.spacingBetweenElementsInsideStackView
        }
    }
    // MARK: - Properties
    var viewModel: TextFieldsViewModelProtocol! = TextFieldsViewModel()
    private var textFieldsCount: CGFloat = TextFieldsCount.textFieldsStackView
    var getHeightOfStackView: CGFloat {
        let textFieldViewHeight = CustomTextFieldConstants.heightForCustomTextFieldView
        let spacingBetweenTextFields = CustomTextFieldConstants.spacingBetweenElementsInsideStackView
        return (textFieldsCount * textFieldViewHeight) + (textFieldsCount * spacingBetweenTextFields)
    }
    @Published var textFieldsEmptyStatePublisher: Bool = true
    //MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        awakeFromNib()
        initialSetup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("Coder is unknown")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        Bundle.main.loadNibNamed(String(describing: TextFieldsStackView.self), owner: self)
    }
    
    // MARK: - Behaviour
    private func initialSetup() {
        self.addSubview(contentView)
        contentView.frame = self.bounds
    }
    
    func setupTextFields(with textFieldsDetails: [TextFieldDetails]) {
        textFieldsDetails.forEach { textFieldDetails in
            let textField = CustomTextFieldView(frame: .zero)
            textField.customTextField.addTarget(self, action: #selector(textFieldDidChanged), for: .allEditingEvents)
            textField.fillTextFieldView(with: textFieldDetails)
            self.stackView.addArrangedSubview(textField)
        }
        textFieldsCount = CGFloat(stackView.arrangedSubviews.count)
        viewModel.textFields = stackView.arrangedSubviews as! [CustomTextFieldView]
    }
    
    func makeTextFieldsEmpty() {
        viewModel.clearTextFields()
    }
    
    @objc func textFieldDidChanged() {
       self.textFieldsEmptyStatePublisher = viewModel.textFieldsAreNotEmpty()
    }
  
    func processTextFieldsInputData() {
        viewModel.validateTextFields()
    }
}
