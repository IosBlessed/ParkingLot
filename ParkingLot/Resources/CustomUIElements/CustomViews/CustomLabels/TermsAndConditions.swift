//
//  TermsAndConditions.swift
//  ParkingLot
//
//  Created by Никита Данилович on 24.06.2023.
//

import UIKit

class TermsAndConditionsLabel: UILabel {
    // MARK: - Properties
    private var labelText: String = ""
    private var textForLink: String = ""
    private var urlPath: String = ""
    private lazy var linkTapGestureRecognizer: UITapGestureRecognizer = {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(termsAndConditionsDidTapped))
        return tapGesture
    }()
    // MARK: - Lifecycle
    init(labelText: String, textForLink: String, urlPath: String) {
        super.init(frame: .zero)
        self.labelText = labelText
        self.textForLink = textForLink
        self.urlPath = urlPath
        initialSetup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("Unknown coder been sended...")
    }
    // MARK: - Behaviour
    private func initialSetup() {
        let attributedString = NSMutableAttributedString(string: labelText)
        let underlineRange = (labelText as NSString).range(of: textForLink)
        attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: underlineRange)
        self.attributedText = attributedString
        self.numberOfLines = NrOfLines.termsLabel
        self.lineBreakMode = .byWordWrapping
        self.font = Fonts.termsLabel
        self.textAlignment = .center
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(linkTapGestureRecognizer)
    }
    // MARK: - Selectors
    @objc private func termsAndConditionsDidTapped() {
        let rangeOfLinkedText = (self.text! as NSString).range(of: textForLink)
        if linkTapGestureRecognizer.didTapAttributedTextInLabel(
            label: self,
            inRange: rangeOfLinkedText
        ) {
            guard let url = URL(string: urlPath) else { return }
            UIApplication.shared.open(url)
        }
    }
}
