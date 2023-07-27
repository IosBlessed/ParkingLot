//
//  Constants.swift
//  ParkingLot
//
//  Created by Никита Данилович on 14.06.2023.
//

import UIKit

struct TextFieldsOptions {
    // TODO: Add space to namecand verification
    static let nameMinimumLength: Int = 1
    static let nameMaximumLength: Int = 30
    static let passwordMinimumLength: Int = 5
    static let passwordMaximumLength: Int = 10
    static let phoneNumberLength: Int = 9
    static let nameRegex = try! NSRegularExpression(pattern: "^[\\p{L}\\s]+$")
    static let emailRegex = try! NSRegularExpression(
        pattern: "^(?=.{5,320}$)(?=[a-zA-Z0-9])[a-zA-Z0-9._!#$%&'*+/=?^`{|}~-]{1,64}@[a-zA-Z0-9.-]{1,255}\\.[a-zA-Z]{1,63}$"
    )
    static let passwordRegex = try! NSRegularExpression(pattern: "^(?=.{5,10}$)(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(.*[\\W_])")
    static let phoneRegex = try! NSRegularExpression(pattern: "^0[0-9]*$")
    static let nrOfParkingRegex = try! NSRegularExpression(pattern: "^(?:[1-9]|[1-9][0-9]|1[0-4][0-9]|150)$")
    static let adressNameMaximumLength: Int = 70
    static let emailNameRussianRegex = ".*[А-Яа-яЁё]+.*"
    static let adressNameMinimumLength: Int = 1
}

struct CustomTextFieldConstants {
    static let maxWidthOfFrame: CGFloat = UIScreen.main.bounds.width - 20
    static let heightOfCustomTextField: CGFloat = 70
    static let spacingBetweenElementsInsideStackView: CGFloat = 15
    static let heightForCustomTextFieldView: CGFloat = 60
}

struct Fonts {
    static let customTextField = UIFont(name: "Mulish-Regular", size: 16)
    static let parkingSpotLevelButton = UIFont(name: "Mulish-Regular", size: 16)
    static let parkingSpotCellLabel = UIFont(name: "Mulish-Regular", size: 14)
    static let textFieldName = UIFont(name: "Mulish-Regular", size: 12)
    static let screenTitleLabel = UIFont(name: "Mulish-Black", size: 20)
    static let customTextFieldErrorLabel = UIFont(name: "Mulish-Black", size: 10)
    static let termsLabel = UIFont(name: "Mulish-Regular", size: 12)
    static let buttonText = UIFont(name: "Mulish-Black", size: 18)
    static let tabButtonText = UIFont(name: "Mulish-Black", size: 15)
    static let addNewLevelButton = UIFont(name: "Mulish-Black", size: 12)
}

struct AnimationDuration {
    static let keyboard = 0.5
}

struct CornerRadious {
    static let customTextFiel = CGFloat(5)
}

struct BorderWidth {
    static let customTextField = CGFloat(1)
}

struct Transparency {
    static let pointTwo = 0.2
    static let semi = 0.5
    static let pointThree = 0.3
    static let opaque = 1.0
}

struct TextFieldsCount {
    static let textFieldsStackView = CGFloat(0)
}

struct Padding {
    static let customTextFieldTexTop = CGFloat(5)
    static let customTextFieldTexLeft = CGFloat(30)
    static let customTextFieldTexBottom = CGFloat(5)
    static let customTextFieldTexRight = CGFloat(50)
}

struct NrOfLines {
    static let termsLabel = 0
}

struct UIButtonExtension {
    static let animationDuration: CGFloat = 0.2
    static let transformingOffsetScale: CGFloat = 0.6
    static let layerShadowOpacity: Float = 0.8
    static let layerShadowRadius: CGFloat = 5
    static let borderWidth: CGFloat = 1
    static let cornerRadius: CGFloat = 5
}

struct CreateParkingLotScreen {
    static let levelNames = ["Level B", "Level C", "Level D", "Level E"]
    static let levels = ["A", "B", "C", "D", "E"]
    static let startingNrOfLevels = 1
    static let maximNrOfLevels = 5
    static let currentLevelIndexName = 0
    static let scrollViewHeight = Int(780)
    static let daysOfWeek = ["SUNDAY", "MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY"]
    static let weekDayStackSpacing = CGFloat(10)
    static let parkingLevelsStackViewSpacing = CGFloat(8)
    static let requriedLevelStackViewSpacing = CGFloat(10)
    static let maxOffset = CGFloat(120)

}

struct Anchors {
    struct CreateParkingLotScreen {
        static let userInfoViewTopAnchor: CGFloat = 15
        static let userInfoViewLeadingTrailingAnchor: CGFloat = 16
        static let parkingLotOptionsTopAnchor: CGFloat = 8.5
        static let parkingLotOptionsLeadingAnchor: CGFloat = 1.5
        static let parkinLotLevelsTopAnchor: CGFloat = 18
        static let levelsLeadingAnchor: CGFloat = 17
        static let confirmButtonAnchor: CGFloat = 16
        static let addLevelButtonTopAnchor: CGFloat = 15
        static let parkingLevelsStackViewTopAnchor: CGFloat = 15
        static let requriedLevelStackViewTopAnchor: CGFloat = 16
        static let separetorLineViewTopAnchor: CGFloat = 16
        static let scrollViewTopAnchor: CGFloat = 10
        static let scrollViewBottomAcnhor: CGFloat = -30
        static let confrimButtonWidthMultiplierAnchor: CGFloat = 0.8
        static let confrimButtonHeightAnchor: CGFloat = 56
        static let separetorLineViewWidthMultiplier: CGFloat = 0.9
        static let separetorLineHeightAnchor: CGFloat = 1
    }
    
    struct CreateAccountScreen {
        static let termsLabelBottomAnchorConstraint = CGFloat(-88)
        static let termsLabelWidthAnchorConstraint = CGFloat(160)
        static let textFieldsViewLeadingTrailingAnchorConstant = CGFloat(16.5)
        static let textFieldsViewTopAnchorConstant = CGFloat(30)
        static let createAccountButtonBottomAnchorConstraint = CGFloat(-16)
        static let createAccountButtonLeadingTrailingAnchorConstraint = CGFloat(16)
        static let createAccountButtonHeightAnchorConstraint = CGFloat(56)
        static let createAccountButtonBottomConstarintKeyboardDifference = CGFloat(20)
        static let termLabelBottomConstarintKeyboardDifference = CGFloat(16)
        static let forgotPasswordLabelAtSignUpSectionTopAnchorConstant = CGFloat(15)
    }
    struct CustomTextFields {
        static let customTextFieldTopAnchorConstraint = CGFloat(2)
        static let customTextFieldLeadingAnchorConstraint = CGFloat(2)
        static let customTextFieldTrailingAnchorConstraint = CGFloat(-2)
        static let customTextFieldBottomAnchorConstraint = CGFloat(-5)
        static let titleLabelTopAnchorConstraint = CGFloat(-8)
        static let titleLabelHeightAnchorConstrain = CGFloat(15)
        static let titleLabelLeadingAnchorConstrain = CGFloat(10)
        static let errorLabelLeadingAnchorConstraint = CGFloat(10)
        static let errorLabelTrailingAnchorConstraint = CGFloat(-5)
        static let errorLabelHeightAnchorConstraint = CGFloat(15)
        static let eyePasswordButtonTrailingAnchorConstraint = CGFloat(-15)
        static let eyePasswordButtonWidthAnchorConstraint = CGFloat(30)
        static let eyePasswordButtonHeightAnchorConstraint = CGFloat(25)
    }
    struct SignInScreen {
        static let textFieldsViewTopAnchorConstant: CGFloat = 16
        static let textFieldsViewLeadingTrailingAnchorConstant: CGFloat = 16
        static let termLabelBottomConstarintKeyboardDifference = CGFloat(16)
        static let termsLabelBottomConstant: CGFloat = -16
        static let forgotPasswordLabelTopAnchorConstant: CGFloat = CGFloat(15)
        static let conifrmButtonBottomConstant: CGFloat = -16
        static let confirmButtonLeadingTrailingConstant: CGFloat = 16
        static let confirmButtonHeightConstant: CGFloat = 56
    }
    struct ForgotPasswordScreen {
        static let notificationLabelTopAnchorConstant: CGFloat = 16
        static let notificationLabelLeadingTrailingAnchorConstant: CGFloat = 16
        static let notificationLabelHeightAnchorConstant: CGFloat = 40
        static let customTextFieldsStackViewTopAnchorConstant: CGFloat = 16
        static let customTextFieldsStackViewLeadingTrailingAnchorConstant: CGFloat = 16
        static let submitButtonLeadingTrailingAnchorConstant: CGFloat = 16
        static let submitButtonBottomAnchorConstant: CGFloat = -16
        static let submitButtonHeightAnchorConstant: CGFloat = 56
    }
    struct ParkingLotsListScreen {
        static let parkingListTableViewTopConstant: CGFloat = 10
        static let parkingListTableViewLeadingTrailingConstant: CGFloat = 5
        static let parkingListTableViewBottomConstant: CGFloat = -5
        
        static let actionBottomButtonBeforeTrailingConstant: CGFloat = -400
        static let actionBottomButtonAfterTrailingConstant: CGFloat = -30
        static let actionBottomButtonWidthHeightConstant: CGFloat = 60
        static let actionBottomButtonBottomConstant: CGFloat = -30
        static let navigationBarButtonItemsWidthHeightConstant: CGFloat = 24
    }
    struct SettingsScreen {
        static let settingsTableViewMarginConstant: CGFloat = 5
        
        static let sectionImageViewLeadingConstant: CGFloat = 20
        static let sectionImageViewHeightConstant: CGFloat = 40
        static let sectionImageViewWidthConstant: CGFloat = 30
        
        static let sectionLabelTopConstant: CGFloat = 5
        static let sectionLabelLeadingConstant: CGFloat = 20
        static let sectionLabelTrailingConstant: CGFloat = -5
        static let sectionLabelBottomConstant: CGFloat = -5
        
        static let sectionSwitchCenterYPosConstant: CGFloat = 5
        static let sectionSwitchTrailingConstant: CGFloat = -30
        static let sectionSwitchHeightConstant: CGFloat = 30
        static let sectionSwitchWidthConstant: CGFloat = 40
    }
}

struct Constants {
    struct ForgotPasswordScreen {
        static let screenTitle: String = "Restore Password"
        static let textFieldTitle: String = "Email"
        static let textFieldPlaceholder: String = "eg. example@email.com"
        static let numberOfLinesOfInformationalLabel: Int = 3
        static let infromationalLabelText: String = "Please enter the email that you originally registered your\n account with. You will receive an email with new password."
        static let confirmButtonTitle: String = "Submit"
    }
    struct ParkingLotsListScreen {
        static let weekDays: [String] = ["SUNDAY","MONDAY","TUESDAY","WEDNESDAY","THURSDAY","FRIDAY","SATURDAY"]
        static let tableViewLayerCornerRadius: CGFloat = 10
        static let actionBottomButtonImageMarginOffset: CGFloat = 18
        static let actionButtonImageFont = UIFont.systemFont(ofSize: 16, weight: .bold)
        static let heightForParkingLotListRow: CGFloat = 60
        static let busyIndicatorBorderWidth: CGFloat = 1.0
        static let busyIndicatorPassingColorLow: Int = 33
        static let busyIndicatorPassingColorMedium: Int = 66
        static let busyIndicatorPassingColorHigh: Int = 100
    }
    struct SettingsScreen {
        static let tableViewHeightForRow: CGFloat = 56.0
    }
}
