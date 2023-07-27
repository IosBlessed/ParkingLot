//
//  ParkingLotLevelModel.swift
//  ParkingLot
//
//  Created by Никита Данилович on 30.06.2023.
//

import Foundation

enum ParkingLotSections: String {
    case main = "Main"
}

struct CreateParkingLot: Codable {
    var name: String
    var address: String
    var workingHours: String
    var workingDays: [String]
    var closed: String
    var operatesNonStop: String
    var levels: [LevelCreate]
}

struct LevelCreate: Codable {
    var floor: String
    var numberOfSpaces: String
}

struct ParkingLot: Codable, Hashable {
    var id: Int
    var name: String
    var address: String
    var workingHours: String
    var workingDays: [String]
    var levels: [Level]
    var operatesNonStop: Bool
    var isClosed: Bool
    var levelOfOccupancy: Int
    var countOfAccessibleParkingSpots: Int
    var countOfFamilyFriendlyParkingSpots: Int
}

struct Level: Codable, Hashable {
    var id: Int
    var floor: String
    var numberOfSpaces: Int
}

struct ParkingSpot: Codable {
    var number: String
    var type: String
    var state: String
}
