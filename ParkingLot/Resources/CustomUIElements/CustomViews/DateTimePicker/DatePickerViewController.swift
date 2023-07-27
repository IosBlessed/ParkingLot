//
//  DatePickerViewController.swift
//  ParkingLot
//
//  Created by Никита Данилович on 06.07.2023.
//
import Foundation
import UIKit

enum DatePickerIdentifiers: String {
    case from = "From"
    case to = "To"
}

struct DatePickerConstants {
    
    struct Constraint {
        static let backgroundViewForDatePickerCenterYConstant: CGFloat = -50
        static let stackViewTopConstant: CGFloat = 5
        static let stackViewLeadingTrailingConstants: CGFloat = 5
        static let submitButtonLeadingTrailingConstants: CGFloat = 5
        static let stackViewBottomConstant: CGFloat = -40
        static let submitButtonBottomConstant: CGFloat = -5
        static let submitButtonHeightConstant: CGFloat = 40
    }
    
    struct Time {
        static let stringFrom: String = "10:00"
        static let stringTo: String = "23:00"
        static let minuteInterval: Int = 1
    }
    
    struct Transparency {
        static let opaque: CGFloat = 1.0
        static let semi: CGFloat = 0.5
        static let zero: CGFloat = 0
    }
    
    struct LayerAttributes {
        static let cornerRadius: CGFloat = 10
    }
    
    struct Spacers {
        static let stackViewSpacer: CGFloat = 10
    }
    
    struct Dimensions {
        static let pickerViewBackgroundWidth: CGFloat = UIScreen.main.bounds.width / 1.2
        static let pickerViewBackgroundHeight: CGFloat = UIScreen.main.bounds.height / 2.7
    }
    
    struct Formatter {
        static let hoursMinutes: String = "HH:mm"
        static let hours: String = "HH"
        static let minutes: String = "mm"
    }
}

protocol UIDatePickerDelegate: AnyObject {
    func receiveTime(from: String, to: String)
}

class DatePickerViewController: UIViewController {
    // MARK: - Delegate
    var delegate: UIDatePickerDelegate?
    // MARK: - Properties
    private var backgroundViewForDatePicker: UIView = {
        let backgroundView = UIView(frame: .zero)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.backgroundColor = .white
        backgroundView.layer.masksToBounds = true
        backgroundView.layer.cornerRadius = DatePickerConstants.LayerAttributes.cornerRadius
        return backgroundView
    }()
    private lazy var stackViewForDatePicker: UIStackView = {
        let stackViewForPicker = UIStackView(frame: .zero)
        stackViewForPicker.translatesAutoresizingMaskIntoConstraints = false
        stackViewForPicker.backgroundColor = .clear
        stackViewForPicker.axis = .vertical
        stackViewForPicker.spacing = DatePickerConstants.Spacers.stackViewSpacer
        stackViewForPicker.alignment = .fill
        stackViewForPicker.distribution = .fillEqually
        return stackViewForPicker
    }()
    private var dateFormatter: (String) -> DateFormatter = { pattern in
        let formatter = DateFormatter()
        formatter.dateFormat = pattern
        return formatter
    }
    private lazy var submitButtonForDatePicker: CustomButton = {
        let button = CustomButton(
            isMainActor: true,
            isShadowActive: false,
            selector: #selector(submitButtonFromDatePickerTapped),
            target: self
        )
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Add Interval", for: .normal)
        button.titleLabel?.font = Fonts.buttonText
        return button
    }()
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black.withAlphaComponent(DatePickerConstants.Transparency.zero)
        setupConstraints()
        fillViewForDatePickerWithContent()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.view.backgroundColor = .black.withAlphaComponent(DatePickerConstants.Transparency.semi)
        }
    }
    // MARK: - Behaviour
    private func setupConstraints() {
        view.addSubview(backgroundViewForDatePicker)
        backgroundViewForDatePicker.addSubview(stackViewForDatePicker)
        backgroundViewForDatePicker.addSubview(submitButtonForDatePicker)
        
        backgroundViewForDatePicker.centerXAnchor.constraint(
            equalTo: view.centerXAnchor
        ).isActive = true
        backgroundViewForDatePicker.centerYAnchor.constraint(
            equalTo: view.centerYAnchor,
            constant: DatePickerConstants.Constraint.backgroundViewForDatePickerCenterYConstant
        ).isActive = true
        backgroundViewForDatePicker.heightAnchor.constraint(
            equalToConstant: DatePickerConstants.Dimensions.pickerViewBackgroundHeight
        ).isActive = true
        backgroundViewForDatePicker.widthAnchor.constraint(
            equalToConstant: DatePickerConstants.Dimensions.pickerViewBackgroundWidth
        ).isActive = true
        
        submitButtonForDatePicker.leadingAnchor.constraint(
            equalTo: backgroundViewForDatePicker.leadingAnchor,
            constant: DatePickerConstants.Constraint.submitButtonLeadingTrailingConstants
        ).isActive = true
        submitButtonForDatePicker.trailingAnchor.constraint(
            equalTo: backgroundViewForDatePicker.trailingAnchor,
            constant: -DatePickerConstants.Constraint.submitButtonLeadingTrailingConstants
        ).isActive = true
        submitButtonForDatePicker.bottomAnchor.constraint(
            equalTo: backgroundViewForDatePicker.bottomAnchor,
            constant: DatePickerConstants.Constraint.submitButtonBottomConstant
        ).isActive = true
        submitButtonForDatePicker.heightAnchor.constraint(
            equalToConstant: DatePickerConstants.Constraint.submitButtonHeightConstant
        ).isActive = true
        
        stackViewForDatePicker.topAnchor.constraint(
            equalTo: backgroundViewForDatePicker.topAnchor,
            constant: DatePickerConstants.Constraint.stackViewTopConstant
        ).isActive = true
        stackViewForDatePicker.leadingAnchor.constraint(
            equalTo: backgroundViewForDatePicker.leadingAnchor,
            constant: DatePickerConstants.Constraint.stackViewLeadingTrailingConstants
        ).isActive = true
        stackViewForDatePicker.trailingAnchor.constraint(
            equalTo: backgroundViewForDatePicker.trailingAnchor,
            constant: -DatePickerConstants.Constraint.stackViewLeadingTrailingConstants
        ).isActive = true
        stackViewForDatePicker.bottomAnchor.constraint(
            equalTo: submitButtonForDatePicker.topAnchor,
            constant: DatePickerConstants.Constraint.submitButtonBottomConstant
        ).isActive = true
    }
    
    private func fillViewForDatePickerWithContent() {
        let fromLabel = createDatePickerLabel()
        fromLabel.text = DatePickerIdentifiers.from.rawValue
        let datePickerFrom = createDatePicker(initialDate: DatePickerConstants.Time.stringFrom)
        datePickerFrom.restorationIdentifier = DatePickerIdentifiers.from.rawValue
        let toLabel = createDatePickerLabel()
        toLabel.text = DatePickerIdentifiers.to.rawValue
        let datePickerTo = createDatePicker(initialDate: DatePickerConstants.Time.stringTo)
        datePickerTo.restorationIdentifier = DatePickerIdentifiers.to.rawValue
        stackViewForDatePicker.addArrangedSubview(fromLabel)
        stackViewForDatePicker.addArrangedSubview(datePickerFrom)
        stackViewForDatePicker.addArrangedSubview(toLabel)
        stackViewForDatePicker.addArrangedSubview(datePickerTo)
    }
    
    private func createDatePicker(initialDate: String = "00:00") -> UIDatePicker {
        let datePicker = UIDatePicker(frame: .zero)
        datePicker.datePickerMode = .time
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.minuteInterval = DatePickerConstants.Time.minuteInterval
        datePicker.roundsToMinuteInterval = true
        datePicker.tintColor = .black
        datePicker.accessibilityIgnoresInvertColors = true
        datePicker.setValue(UIColor.black, forKey: "textColor")
        datePicker.setValue(UIColor.clear, forKey: "backgroundColor")
        datePicker.layer.masksToBounds = true
        datePicker.layer.cornerRadius = DatePickerConstants.LayerAttributes.cornerRadius
        let date = dateFormatter(DatePickerConstants.Formatter.hoursMinutes).date(from: initialDate)!
        datePicker.date = date
        return datePicker
    }

    private func createDatePickerLabel() -> UILabel {
        let label = UILabel(frame: .zero)
        label.textAlignment = .center
        label.font = Fonts.screenTitleLabel
        return label
    }
    
    private func processIntervalOfPickedOperatingHours() {
        let datePickers = stackViewForDatePicker.arrangedSubviews
        let pickerDateFrom = datePickers.first(where: { $0.restorationIdentifier == DatePickerIdentifiers.from.rawValue })! as! UIDatePicker
        let pickerDateTo = datePickers.first(where: { $0.restorationIdentifier == DatePickerIdentifiers.to.rawValue })! as! UIDatePicker
        let pickedHoursFrom = Int(dateFormatter(DatePickerConstants.Formatter.hours).string(from: pickerDateFrom.date))!
        let pickedHoursTo = Int(dateFormatter(DatePickerConstants.Formatter.hours).string(from: pickerDateTo.date))!
        let pickedMinutesFrom = Int(dateFormatter(DatePickerConstants.Formatter.minutes).string(from: pickerDateFrom.date))!
        let pickedMinutesTo = Int(dateFormatter(DatePickerConstants.Formatter.minutes).string(from: pickerDateTo.date))!
        if pickedHoursFrom == pickedHoursTo && pickedMinutesFrom >= pickedMinutesTo {
            let alertController = self.showAlertMessage(
                title: "Oops...",
                desriptionMessage: "Minutes FROM should be less than TO",
                actionButtonTitle: "OK",
                destructiveHandler: { _ in },
                handler: { _ in }
            )
            present(alertController, animated: true)
        } else {
            delegate?.receiveTime(
                from: dateFormatter(DatePickerConstants.Formatter.hoursMinutes).string(from: pickerDateFrom.date),
                to: dateFormatter(DatePickerConstants.Formatter.hoursMinutes).string(from: pickerDateTo.date)
            )
            self.dismiss(animated: true)
        }
    }
    // MARK: - Selectors
    @objc private func submitButtonFromDatePickerTapped() {
        submitButtonForDatePicker.animateButtonWhenTapping()
        processIntervalOfPickedOperatingHours()
    }
}
