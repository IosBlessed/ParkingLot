//
//  TextFieldModel.swift
//  ParkingLot
//
//  Created by Никита Данилович on 15.06.2023.
//

enum TextFieldsIdentifier: String, CaseIterable {
    case name = "Name"
    case password = "Password"
    case phoneNumber = "Phone number"
    case email = "Email"
    case operatingHours = "Operating Hours"
    case parkingLotName = "ParkingLotName"
    case parkingLotAddress = "Address"
    case nrOfParkingSpots = "Number of parking spots"
}

enum TextFieldsErrors: String {
    case nameLength = "Length should be between 1 and 30 characters"
    case nameSpecialSymbols = "Special symbols are not allowed"
    case emailLength = "Length should be between 5 and 320 characters"
    case email = "Must match the email pattern"
    case passwordSpecialSymbols = "Should contain 1 symbol, 1 upper case, 1 lower case, 1 digit"
    case passwordLength = "Length should be between 5 and 10 characters"
    case phoneStartFromZeroAndContainDigits = "Should start from zero and contain only digits"
    case phoneLength = "Length should be equal to 9"
    case nrOfParkingSpots = "Number of parking spots should be between 1 and 150"
    case parkingLotNameAdressLength = "Length should be max 70 characters"
    case parkingLotNameAdressEmoji = "Only latin characters are allowed"
    case parkingLotNameAdressRussian = "Emojis are not allowed for this field."
}

struct TextFieldDetails {
    let title: String
    let placeholder: String
    let restorationIdentifier: TextFieldsIdentifier
    let isSecured: Bool
    
    init(
        title: String,
        placeholder: String,
        isSecured: Bool,
        restorationIdentifier: TextFieldsIdentifier
    ) {
        self.title = title
        self.placeholder = placeholder
        self.isSecured = isSecured
        self.restorationIdentifier = restorationIdentifier
    }
}
