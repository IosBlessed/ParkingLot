//
//  Extension+NSRegularExpression.swift
//  ParkingLot
//
//  Created by Никита Данилович on 22.06.2023.
//

import Foundation

extension NSRegularExpression {
    func matches(_ string: String) -> Bool {
        let range = NSRange(location: 0, length: string.utf16.count)
        let matches = self.matches(in: string, options: [], range: range)
        return !matches.isEmpty
    }
}
