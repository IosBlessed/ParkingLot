//
//  CreateParkingLotViewController.swift
//  ParkingLot
//
//  Created by Никита Данилович on 29.06.2023.
//

import UIKit
import Combine

class CreateParkingLotViewController: UIViewController, CreateParkingLotViewControllerProtocol, UIDatePickerDelegate, UITextFieldDelegate, CustomTextFieldProtocol {

    var parkingLot: ParkingLot?
    
    var coordinator: ParkingLotCoordinatorProtocol!
    var viewModel: CreateNewParkingLotViewModelProtocol!
    
    private var cancellableStates = [AnyCancellable]()
    
    private let activityIndicatorViewController = ActivityIndicatorViewController()
    private var datePickerViewController:DatePickerViewController = DatePickerViewController()
    private var parkingLotOptionsStackView = UIStackView()
    private let parkingLotOperatesOptionStackView = CheckBoxCustomStackView()
    private let temporaryClosedOptionStackView = CheckBoxCustomStackView()
    private let weekDaysStackView = UIStackView()
    private let separetorLineView = UIView()
    private var parkingLevelsStackView = UIStackView()
    private var currentLevelIndexName = CreateParkingLotScreen.currentLevelIndexName
    private let addLevelButton = UIButton()
    private var scrollViewHeight = CreateParkingLotScreen.scrollViewHeight
    private var nrOfLevels: Int = CreateParkingLotScreen.startingNrOfLevels {
        didSet {
            if nrOfLevels >= CreateParkingLotScreen.maximNrOfLevels {
                addLevelButton.isEnabled = false
                addLevelButton.alpha = Transparency.pointThree
            } else {
                addLevelButton.isEnabled = true
                addLevelButton.alpha = Transparency.opaque
            }
        }
    }
    
    private var nameAndAdressNotEmpty = false
    private var isThereAtLeastOneLevel = false
    private var operatesWholeWeek = false
    private var isThereAWorkingDay = false
    
    private lazy var levelTextFieldsView: TextFieldsStackView = {
        let stackView = TextFieldsStackView(frame: .zero)
        return stackView
    }()
    
    private lazy var confirmButton: CustomButton = {
        let button = CustomButton(isMainActor: true,
                                  isShadowActive: true,
                                  selector: #selector(confirmButtonWasTapped),
                                  target: self)
        return button
    }()
    
    lazy var customTextFieldViews = [CustomTextFieldView]()
    
    private lazy var userInfoTextFieldsView: TextFieldsStackView = {
        let stackView = TextFieldsStackView(frame: .zero)
        return stackView
    }()
    
    private lazy var keyboardView: KeyboardRelatedView = {
        let keyboardView = KeyboardRelatedView(targetView: self.view)
        keyboardView.translatesAutoresizingMaskIntoConstraints = false
        keyboardView.initialSetup()
        return keyboardView
    }()
    
    private let scrollView = UIScrollView()
    private let containterView = UIView()
    private lazy var maxOffset = CGFloat(
        scrollView.bounds.height + (navigationController?.navigationBar.bounds.height ?? 50.0)
    )
    private var operatingHoursCoveredLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = true
        label.isUserInteractionEnabled = true
        label.backgroundColor = .clear
        label.layer.masksToBounds = true
        return label
    }()
    
    //MARK: - LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupConfirmButton()
        setupScrollView()
        setupAddLevelButton()
        setupCancellables()
        setupInteractionDateTextFieldRecognizer()
        setupViewController()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        containterView.frame = CGRect(x: 0, y: 0, width: Int(scrollView.frame.width), height: scrollViewHeight)
        scrollView.contentSize = containterView.frame.size
        
        let userTextFields = userInfoTextFieldsView.stackView.arrangedSubviews as! [CustomTextFieldView]
        let customTextFieldView = userTextFields.first {
            $0.customTextField.restorationIdentifier == TextFieldsIdentifier.operatingHours.rawValue
        }!
        
        operatingHoursCoveredLabel.frame = customTextFieldView.bounds
        operatingHoursCoveredLabel.frame.origin.x = userInfoTextFieldsView.frame.origin.x
        operatingHoursCoveredLabel.frame.origin.y = customTextFieldView.frame.origin.y + CustomTextFieldConstants.spacingBetweenElementsInsideStackView
    }
    
    //MARK: - Setup DatePicker
    private func setupInteractionDateTextFieldRecognizer() {
        let tapGesture = UITapGestureRecognizer (target: self, action: #selector (operatingHoursTextFieldDidFocused) )
        operatingHoursCoveredLabel.addGestureRecognizer(tapGesture)
    }
    
    @objc private func operatingHoursTextFieldDidFocused() {
        datePickerViewController.modalPresentationStyle = .overCurrentContext
        datePickerViewController.delegate = self
        present(datePickerViewController, animated: true)
    }
    
    func receiveTime (from: String, to: String) {
        let userTextFields = userInfoTextFieldsView.stackView.arrangedSubviews as! [CustomTextFieldView]
        let customTextFieldView = userTextFields.first {
            $0.customTextField.restorationIdentifier == TextFieldsIdentifier.operatingHours.rawValue
        }!
        customTextFieldView.customTextField.text = "\(from)-\(to)"
    }
    
    //MARK: - Setup NavigationBar
    private func setupNavBar() {
        navigationItem.title = "Create Parking Lot"
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: Fonts.screenTitleLabel!
        ]
        
        let backButton = UIBarButtonItem(image: UIImage(named: "Vector"), style: .plain, target: self, action: #selector(goBack))
        navigationItem.leftBarButtonItems = [backButton]
    }
    
    @objc private func goBack() {
        let alertController = UIAlertController(title: "Are you sure that you want to continue?", message: "If going back, all your progress will be lost!", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default) {[weak self] _ in
            self?.navigationController?.popViewController(animated:true)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) {_ in }
        alertController.addAction(yesAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true)
    }
    
    private func deleteLastThreeChars(_ input: String) -> String {
        if input.count > 11 {
            return String(input.prefix(input.count - 3))
        } else { return input }
    }
    
    // MARK: - SETUP VIEW CONTROLLER
    private func setupViewController() {
        guard let parkingLot = self.parkingLot else { return }
        let parkingLotData = userInfoTextFieldsView.stackView.arrangedSubviews as! [CustomTextFieldView]
        parkingLotData.forEach { parkingLotDetails in
            switch parkingLotDetails.customTextField.restorationIdentifier {
            case TextFieldsIdentifier.operatingHours.rawValue:
                parkingLotDetails.customTextField.text = deleteLastThreeChars(parkingLot.workingHours)
                
            case TextFieldsIdentifier.parkingLotName.rawValue:
                parkingLotDetails.customTextField.text = parkingLot.name
                
            case TextFieldsIdentifier.parkingLotAddress.rawValue:
                parkingLotDetails.customTextField.text = parkingLot.address
            default:
                print("Error")
            }
        }
        
        if parkingLot.operatesNonStop {
            parkingLotOperatesOptionStackView.checkbox.buttonTapped()
            operatesWholeWeek = true
        }
        
        if parkingLot.isClosed {
            temporaryClosedOptionStackView.checkbox.buttonTapped()
        }
        
        isThereAWorkingDay = parkingLot.workingDays.count > 0 ? true : false
        
        let weekDays = weekDaysStackView.arrangedSubviews as! [CheckBoxCustomStackView]
        weekDays.forEach { weekDay in
            let workingDays = parkingLot.workingDays
            workingDays.forEach { workingDay in
                if weekDay.identifier == workingDay {
                    weekDay.checkbox.buttonTapped()
                }
            }
        }
        let requiredLeveldTextField = levelTextFieldsView.stackView.arrangedSubviews as! [CustomTextFieldView]
        requiredLeveldTextField.forEach { levelCustomTextField in
            levelCustomTextField.customTextField.text = String(parkingLot.levels.first?.numberOfSpaces ?? 0)
        }
        
        nameAndAdressNotEmpty = true
        isThereAtLeastOneLevel = true
        enableButton(for: true)
        for levelData in parkingLot.levels.dropFirst() {
            nrOfLevels += 1
            let level = ParkingLevelSectionStackView()
            level.section.translatesAutoresizingMaskIntoConstraints = false
            level.translatesAutoresizingMaskIntoConstraints = false
            let levelName = CreateParkingLotScreen.levelNames[currentLevelIndexName]
            level.setupLabel(labelText: levelName)
            self.currentLevelIndexName += 1
            
            level.setupSection(title: "Number of parking spots",
                               placeholder: "eg. 45",
                               isSecured: false,
                               identifier: .nrOfParkingSpots)
            
            parkingLevelsStackView.addArrangedSubview(level)
            
            let levelField = level.section.stackView.arrangedSubviews as! [CustomTextFieldView]
            levelField.forEach { levelCustomTextField in
                levelCustomTextField.customTextField.text = String(levelData.numberOfSpaces)
            }
            
            level.buttonTappedHandler = { [weak self] in
                guard let self else { return }
                self.nrOfLevels -= 1
                self.parkingLevelsStackView.removeArrangedSubview(level)
                level.removeFromSuperview()
                self.currentLevelIndexName -= 1
                self.updateNames()
                scrollViewHeight -= 105
                self.containterView.frame = CGRect(x: 0, y: 0, width: Int(self.scrollView.frame.width), height: scrollViewHeight)
                self.scrollView.contentSize = containterView.frame.size
            }
            scrollViewHeight += 105
            containterView.frame = CGRect(x: 0, y: 0, width: Int(scrollView.frame.width), height: scrollViewHeight)
            scrollView.contentSize = containterView.frame.size

        }
}

//MARK: - Setup scroll view
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Anchors.CreateParkingLotScreen.scrollViewTopAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: confirmButton.topAnchor, constant: Anchors.CreateParkingLotScreen.scrollViewBottomAcnhor)
        ])
        
        scrollView.addSubview(containterView)
        
        containterView.translatesAutoresizingMaskIntoConstraints = true
        
        setupUserInfoTextFieldsView()
        setupParkingLotOptionsView()
        setupParkingLevelsSection()
        setupAddLevelButton()
    }
    
    //MARK: - Setup userInfoTextFieldsView
    private func setupUserInfoTextFieldsView() {
        userInfoTextFieldsView.setupTextFields(
            with: [
                TextFieldDetails(
                    title: "Name",
                    placeholder: "Parking lot name",
                    isSecured: false,
                    restorationIdentifier: .parkingLotName
                ),
                TextFieldDetails(
                    title: "Address",
                    placeholder: "eg. str. Arborilor 21, or. Chisinau",
                    isSecured: false,
                    restorationIdentifier: .parkingLotAddress
                ),
                TextFieldDetails(
                    title: "Operating Hours",
                    placeholder: "HH:MM-HH:MM",
                    isSecured: false,
                    restorationIdentifier: .operatingHours)
            ]
        )
        
        userInfoTextFieldsView.translatesAutoresizingMaskIntoConstraints = false
        containterView.addSubview(userInfoTextFieldsView)
        containterView.addSubview(operatingHoursCoveredLabel)
        
        let height = userInfoTextFieldsView.getHeightOfStackView
        
        NSLayoutConstraint.activate([
            userInfoTextFieldsView.leadingAnchor.constraint(equalTo: containterView.leadingAnchor,
                                                            constant: Anchors.CreateParkingLotScreen.userInfoViewLeadingTrailingAnchor),
            userInfoTextFieldsView.trailingAnchor.constraint(equalTo: containterView.trailingAnchor,
                                                             constant: -Anchors.CreateParkingLotScreen.userInfoViewLeadingTrailingAnchor),
            userInfoTextFieldsView.topAnchor.constraint(equalTo: containterView.safeAreaLayoutGuide.topAnchor,
                                                        constant: Anchors.CreateParkingLotScreen.userInfoViewTopAnchor),
            userInfoTextFieldsView.centerXAnchor.constraint(equalTo: containterView.centerXAnchor),
            userInfoTextFieldsView.heightAnchor.constraint(equalToConstant: height)
        ])
    }
    
    //MARK: - Setup parking lot options
    private func setupParkingLotOptionsView() {
        parkingLotOptionsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        containterView.addSubview(parkingLotOptionsStackView)
        parkingLotOptionsStackView.axis = .vertical
        parkingLotOptionsStackView.spacing = 16
        
        NSLayoutConstraint.activate([
            parkingLotOptionsStackView.topAnchor.constraint(equalTo: userInfoTextFieldsView.bottomAnchor,
                                                            constant: Anchors.CreateParkingLotScreen.parkingLotOptionsTopAnchor),
            parkingLotOptionsStackView.leadingAnchor.constraint(equalTo: containterView.leadingAnchor,
                                                                constant: Anchors.CreateParkingLotScreen.userInfoViewLeadingTrailingAnchor)
        ])
        
        //MARK: - Parking lot operates option Stack
        parkingLotOperatesOptionStackView.axis = .horizontal
        parkingLotOperatesOptionStackView.spacing = 8
        parkingLotOperatesOptionStackView.setLabelText(text: "Parking lot operates 24/7")
        parkingLotOperatesOptionStackView.checkbox.handler = {
            (self.weekDaysStackView.arrangedSubviews as! [CheckBoxCustomStackView]).forEach {[weak self] checkBox in
                checkBox.changeCheckboxStatus()
                
                let userTextFields = self?.userInfoTextFieldsView.stackView.arrangedSubviews as! [CustomTextFieldView]
                let customTextFieldView = userTextFields.first {
                    $0.customTextField.restorationIdentifier == TextFieldsIdentifier.operatingHours.rawValue
                }!
                customTextFieldView.customTextField.delegate = self
                customTextFieldView.isUserInteractionEnabled.toggle()
                
                if customTextFieldView.isUserInteractionEnabled {
                    customTextFieldView.customTextField.alpha = Transparency.opaque
                } else {
                    customTextFieldView.customTextField.alpha = Transparency.pointThree
                }
            }
            self.viewModel.operateWholeWeek()
        }
        parkingLotOptionsStackView.addArrangedSubview(parkingLotOperatesOptionStackView)
        
        //MARK: - Parking lot temporary closed option StackView
        temporaryClosedOptionStackView.axis = .horizontal
        temporaryClosedOptionStackView.spacing = 8
        temporaryClosedOptionStackView.setLabelText(text: "Temporary Closed")
        parkingLotOptionsStackView.addArrangedSubview(temporaryClosedOptionStackView)
        
        //MARK: - Days of weak StackView
        weekDaysStackView.axis = .horizontal
        weekDaysStackView.spacing = 16
        
        let daysOfWeek = CreateParkingLotScreen.daysOfWeek

        for day in daysOfWeek {
            let weekDayStack = CheckBoxCustomStackView()
            weekDayStack.checkbox.handler = {
                var count = 0
                for weekDayStack in self.weekDaysStackView.arrangedSubviews {
                    let stack = weekDayStack as! CheckBoxCustomStackView
                    if stack.checkbox.isSelected {
                        count += 1
                    }
                }
                
                if count == 1 {
                    self.viewModel.parkingWorksAtLeastOneDay(state: true)
                }
                if count == 0 {
                    self.viewModel.parkingWorksAtLeastOneDay(state: false)
                }
            }
            weekDayStack.axis = .vertical
            weekDayStack.alignment = .center
            weekDayStack.spacing = CreateParkingLotScreen.weekDayStackSpacing
            weekDayStack.setLabelText(text: String(day.first ?? " "))
            weekDayStack.identifier = day
            weekDaysStackView.addArrangedSubview(weekDayStack)
        }
        
        parkingLotOptionsStackView.addArrangedSubview(weekDaysStackView)
        
        //MARK: - Separator
        separetorLineView.translatesAutoresizingMaskIntoConstraints = false
        separetorLineView.backgroundColor = .black
        containterView.addSubview(separetorLineView)
        
        NSLayoutConstraint.activate([
            separetorLineView.widthAnchor.constraint(equalTo: containterView.widthAnchor, multiplier: Anchors.CreateParkingLotScreen.separetorLineViewWidthMultiplier),
            separetorLineView.heightAnchor.constraint(equalToConstant: Anchors.CreateParkingLotScreen.separetorLineHeightAnchor),
            separetorLineView.topAnchor.constraint(equalTo: parkingLotOptionsStackView.bottomAnchor, constant: Anchors.CreateParkingLotScreen.separetorLineViewTopAnchor),
            separetorLineView.centerXAnchor.constraint(equalTo: containterView.centerXAnchor)
        ])
    }
    
    //MARK: - Setup add level option
    private func setupParkingLevelsSection() {
        
        parkingLevelsStackView.translatesAutoresizingMaskIntoConstraints = false
        parkingLevelsStackView.axis = .vertical
        containterView.addSubview(parkingLevelsStackView)
        parkingLevelsStackView.spacing = CreateParkingLotScreen.parkingLevelsStackViewSpacing
        
    NSLayoutConstraint.activate([
        parkingLevelsStackView.topAnchor.constraint(equalTo: separetorLineView.topAnchor, constant: Anchors.CreateParkingLotScreen.parkingLevelsStackViewTopAnchor),
            parkingLevelsStackView.leadingAnchor.constraint(equalTo: containterView.leadingAnchor,
                                                            constant: Anchors.CreateParkingLotScreen.levelsLeadingAnchor),
            parkingLevelsStackView.trailingAnchor.constraint(equalTo: containterView.trailingAnchor, constant: -Anchors.CreateParkingLotScreen.levelsLeadingAnchor),
        ])
        
        //MARK: Setup requred level
        let requriedLevelStackView = UIStackView()
        requriedLevelStackView.translatesAutoresizingMaskIntoConstraints = false
        requriedLevelStackView.axis = .vertical
        requriedLevelStackView.spacing = CreateParkingLotScreen.requriedLevelStackViewSpacing
        
        let levelNameLabel = UILabel()
        levelNameLabel.text = "Level A"
        levelNameLabel.font = Fonts.termsLabel
        levelNameLabel.textColor = .black.withAlphaComponent(Transparency.semi)
        
        levelTextFieldsView.setupTextFields(with: [
            TextFieldDetails(title: "Number of parking spots",
                             placeholder: "eg. 45",
                             isSecured: false,
                             restorationIdentifier: .nrOfParkingSpots)
        ])
        
        (levelTextFieldsView.stackView.arrangedSubviews as! [CustomTextFieldView]).forEach { CustomTextFieldView in
            CustomTextFieldView.customTextField.keyboardType = .numberPad
        }
        
        requriedLevelStackView.addArrangedSubview(levelNameLabel)
        requriedLevelStackView.addArrangedSubview(levelTextFieldsView)
        parkingLevelsStackView.addArrangedSubview(requriedLevelStackView)
        
        levelTextFieldsView.translatesAutoresizingMaskIntoConstraints = false
        let height = levelTextFieldsView.getHeightOfStackView
        
        NSLayoutConstraint.activate([
            levelTextFieldsView.heightAnchor.constraint(equalToConstant: height),
            
            requriedLevelStackView.topAnchor.constraint(equalTo: separetorLineView.topAnchor,
                                                        constant: Anchors.CreateParkingLotScreen.requriedLevelStackViewTopAnchor),
            requriedLevelStackView.leadingAnchor.constraint(equalTo: containterView.leadingAnchor,
                                                            constant: Anchors.CreateParkingLotScreen.levelsLeadingAnchor),
        ])
    }
    
    //MARK: - Setup add level button
    private func setupAddLevelButton() {
        addLevelButton.translatesAutoresizingMaskIntoConstraints = false
        
        addLevelButton.setTitleColor(.black, for: .normal)
        addLevelButton.setTitle("+ Add Level", for: .normal)
        addLevelButton.titleLabel?.font = Fonts.addNewLevelButton
        addLevelButton.tintColor = .black
        addLevelButton.addTarget(self, action: #selector(addNewLevel(sender: )), for: .touchUpInside)
        containterView.addSubview(addLevelButton)
        
        NSLayoutConstraint.activate([
            addLevelButton.topAnchor.constraint(equalTo: parkingLevelsStackView.bottomAnchor, constant: Anchors.CreateParkingLotScreen.addLevelButtonTopAnchor),
            addLevelButton.centerXAnchor.constraint(equalTo: containterView.centerXAnchor)
        ])
    }
    
    @objc private func addNewLevel(sender: UIButton) {
        nrOfLevels += 1
        let level = ParkingLevelSectionStackView()
        level.section.translatesAutoresizingMaskIntoConstraints = false
        level.translatesAutoresizingMaskIntoConstraints = false
        let levelName = CreateParkingLotScreen.levelNames[currentLevelIndexName]
        level.setupLabel(labelText: levelName)
        self.currentLevelIndexName += 1
        
        level.setupSection(title: "Number of parking spots",
                           placeholder: "eg. 45",
                           isSecured: false,
                           identifier: .nrOfParkingSpots)
        
        parkingLevelsStackView.addArrangedSubview(level)
        
        level.buttonTappedHandler = { [weak self] in
            guard let self else { return }
            self.nrOfLevels -= 1
            self.parkingLevelsStackView.removeArrangedSubview(level)
            level.removeFromSuperview()
            self.currentLevelIndexName -= 1
            self.updateNames()
            self.scrollViewHeight -= 105
            containterView.frame = CGRect(x: 0, y: 0, width: Int(scrollView.frame.width), height: scrollViewHeight)
            scrollView.contentSize = containterView.frame.size
        }
        scrollViewHeight += 105
        containterView.frame = CGRect(x: 0, y: 0, width: Int(scrollView.frame.width), height: scrollViewHeight)
        scrollView.contentSize = containterView.frame.size
    }

    private func updateNames() {
        let views = parkingLevelsStackView.arrangedSubviews
        if views.count >= 2 {
            for index in 1...views.count-1  {
                let levelStack = views[index] as! ParkingLevelSectionStackView
                levelStack.setupLabel(labelText: CreateParkingLotScreen.levelNames[index-1])
            }
        }
    }
    
    //MARK: - Setup confirm button
    private func setupConfirmButton() {
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.setTitle("Confirm", for: .normal)
        confirmButton.titleLabel?.font = Fonts.buttonText
        confirmButton.addTarget(self, action: #selector(confirmButtonWasTapped), for: .touchUpInside)
        confirmButton.isEnabled = false
        confirmButton.alpha = Transparency.pointThree
        view.addSubview(confirmButton)
        
        NSLayoutConstraint.activate([
            confirmButton.bottomAnchor.constraint(equalTo: keyboardView.topAnchor, constant: -Anchors.CreateParkingLotScreen.confirmButtonAnchor ),
            confirmButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            confirmButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: Anchors.CreateParkingLotScreen.confrimButtonWidthMultiplierAnchor),
            confirmButton.heightAnchor.constraint(equalToConstant: Anchors.CreateParkingLotScreen.confrimButtonHeightAnchor)
        ])
    }
    
    @objc private func confirmButtonWasTapped(sender: UIButton) {
        
        confirmButton.animateButtonWhenTapping()
        
        var levelTextFieldsView = [levelTextFieldsView]
        
        let views = parkingLevelsStackView.arrangedSubviews
        if views.count >= 2 {
            for index in 1...views.count-1  {
                let levelStack = views[index] as! ParkingLevelSectionStackView
                levelTextFieldsView.append(levelStack.section)
            }
        }
        
        let textFieldsView = [userInfoTextFieldsView] + levelTextFieldsView
        
        var days = [String]()
        let daysStack = weekDaysStackView.arrangedSubviews
        
        daysStack.forEach { day in
            let day = day as! CheckBoxCustomStackView
            if day.checkbox.isSelected {
                days.append(day.identifier ?? " ")
            }
        }
        
        var levels = [LevelCreate]()
        var levelIndex = 0
       
        levelTextFieldsView.forEach { level in
            let level = level.stackView.arrangedSubviews as! [CustomTextFieldView]
            level.forEach { level in
                let lvl = LevelCreate(floor: CreateParkingLotScreen.levels[levelIndex], numberOfSpaces: level.customTextField.text ?? " ")
                levelIndex += 1
                levels.append(lvl)
            }
        }
        
        customTextFieldViews = userInfoTextFieldsView.stackView.arrangedSubviews as! [CustomTextFieldView]
        
        if parkingLot != nil {
            viewModel.updateParkingLot(customTextFieldsStackView: textFieldsView,
                                       name: getTextFieldInput(by: .parkingLotName),
                                       address: getTextFieldInput(by: .parkingLotAddress),
                                       workingHours: getTextFieldInput(by: .operatingHours),
                                       operatingDays: days,
                                       isClosed:temporaryClosedOptionStackView.checkbox.isSelected,
                                       levels: levels,
                                       id: parkingLot?.id ?? 0)
        } else {
            viewModel.createNewParkingLot(customTextFieldsStackView: textFieldsView,
                                          name: getTextFieldInput(by: .parkingLotName),
                                          address: getTextFieldInput(by: .parkingLotAddress),
                                          workingHours: getTextFieldInput(by: .operatingHours),
                                          operatingDays: days,
                                          isClosed:temporaryClosedOptionStackView.checkbox.isSelected,
                                          levels: levels)
        }
    }
    
    private func enableButton(for state: Bool) {
        confirmButton.isEnabled = state
        confirmButton.alpha = state ? Transparency.opaque : Transparency.pointThree
    }
    
    private func setupCancellables() {
        levelTextFieldsView.$textFieldsEmptyStatePublisher.sink { [weak self] areEmptyTextFields in
            guard let self else { return }
            self.isThereAtLeastOneLevel = !areEmptyTextFields
            let isThereAWorkingProgram = self.operatesWholeWeek || self.isThereAWorkingDay
            self.enableButton(for: isThereAWorkingProgram && self.isThereAtLeastOneLevel && self.nameAndAdressNotEmpty)
        }.store(in: &cancellableStates)
        
        userInfoTextFieldsView.$textFieldsEmptyStatePublisher.sink { [weak self] areEmptyTextFields in
            guard let self else { return }
            self.nameAndAdressNotEmpty = !areEmptyTextFields
            let isThereAWorkingProgram = self.operatesWholeWeek || self.isThereAWorkingDay
            self.enableButton(for: isThereAWorkingProgram && self.isThereAtLeastOneLevel && self.nameAndAdressNotEmpty)
        }.store(in: &cancellableStates)
        
        viewModel.worksAtLeastOneDayPublisher.sink { [weak self] worksAtLeastOneDay in
            guard let self else { return }
            self.isThereAWorkingDay = worksAtLeastOneDay
            let isThereAWorkingProgram = self.operatesWholeWeek || self.isThereAWorkingDay
            self.enableButton(for: isThereAWorkingProgram && self.isThereAtLeastOneLevel && self.nameAndAdressNotEmpty)
        }.store(in: &cancellableStates)
        
        viewModel.operatesWholeWeekPublisher.sink { [weak self] operatesWholeWeek in
            guard let self else { return }
            self.operatesWholeWeek = operatesWholeWeek
            let isThereAWorkingProgram = self.operatesWholeWeek || self.isThereAWorkingDay
            self.enableButton(for: isThereAWorkingProgram && self.isThereAtLeastOneLevel && self.nameAndAdressNotEmpty)
        }.store(in: &cancellableStates)
        
        viewModel.createParkingLotQueryIsProcessing
            .receive(on: DispatchQueue.main)
            .sink { [weak self] createUserIsProcessing in
                guard let self, let createUserIsProcessing else { return }
                if createUserIsProcessing {
                    activityIndicatorViewController.modalPresentationStyle = .overCurrentContext
                    self.present(self.activityIndicatorViewController, animated: false)
                } else {
                    self.activityIndicatorViewController.dismiss(animated: false)
                }
                
        }.store(in: &cancellableStates)
        
        viewModel.isParkingLotCreated
            .receive(on: DispatchQueue.main)
            .sink { [weak self] successfulResponse in
                guard let successfulResponse, let self else { return }
                if !successfulResponse {
                    let allert = self.showAlertMessage(title: "An unexpected error ocurred",
                                                       desriptionMessage: "The parking lot you entered already exists in the system. Please provide a different name or address and try one more time.",
                                                       actionButtonTitle: "Close",
                                                       destructiveHandler: { _ in },
                                                       handler: { _ in })
                    
                    self.present(allert, animated: true)
                } else {
                    let message = parkingLot != nil ? "The parking lot was successfully updated!" : "The parking lot was successfully created!"
                    
                    let alert = self.showAlertMessage(title: "Succes",
                                                       desriptionMessage: message,
                                                       actionButtonTitle: "Close",
                                                       destructiveHandler: { _ in },
                                                       handler: { [weak self] _ in
                        if self?.parkingLot != nil {
                            self?.navigationController?.popViewController(animated:true)
                        } else {
                            self?.coordinator.openEditParkingLotScreen(parkingLot: self?.viewModel.getParkingLot(), fromCreate: true)
                        }
                    })
                    DispatchQueue.main.async {
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }.store(in: &cancellableStates)
    }
}
