//
//  ParkingLotTableViewCell.swift
//  ParkingLot
//
//  Created by Никита Данилович on 13.07.2023.
//

import UIKit

class ParkingLotTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var busyIndicator: UILabel! {
        didSet {
            busyIndicator.backgroundColor = .clear
            busyIndicator.layer.masksToBounds = true
            busyIndicator.layer.borderColor = UIColor.black.cgColor
            busyIndicator.layer.borderWidth = Constants.ParkingLotsListScreen.busyIndicatorBorderWidth
            busyIndicator.layer.cornerRadius = busyIndicator.bounds.width/2
        }
    }
    @IBOutlet private weak var name: UILabel!
    @IBOutlet private weak var workingPlan: UILabel!
    static let uiNib: UINib = {
        let nib = UINib(
            nibName: String(describing: ParkingLotTableViewCell.self),
            bundle: nil
        )
        return nib
    }()
    static let identifier = String(describing: type(of: ParkingLotTableViewCell.self))
    private let weekDays: [String] = Constants.ParkingLotsListScreen.weekDays
    private var parkingLot: ParkingLot?

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell(with parkingLot: ParkingLot) {
        self.parkingLot = parkingLot
        self.name.text = parkingLot.name
        configureParkingOccupancy()
        configureWorkingPlan()
        self.backgroundColor = .clear
    }
    
    private func configureWorkingPlan() {
        guard let parkingLot else { return }
        var planAttributedString: NSMutableAttributedString!
        let planAttributes: [NSAttributedString.Key : Any] = [
            .font: Fonts.textFieldName!,
            .foregroundColor: CustomSystemColors.subtitle
        ]
        if !parkingLot.isClosed && !parkingLot.operatesNonStop {
            let workingHours = parkingLot.workingHours
            planAttributedString = NSMutableAttributedString(
                string: "\(workingHours)  ",
                attributes: planAttributes
            )
            weekDays.forEach { weekDay in
                let attributtedCharacter = NSMutableAttributedString(
                    string: "\(weekDay.first!)",
                    attributes: planAttributes
                )
                attributtedCharacter.addAttribute(
                    .foregroundColor,
                    value: parkingLot.workingDays.contains(weekDay) ? CustomSystemColors.subtitle : UIColor.red,
                    range: NSRange(location: 0, length: 1)
                )
                let separator = NSMutableAttributedString(string: " / ", attributes: planAttributes)
                planAttributedString.append(attributtedCharacter)
                planAttributedString.append(separator)
            }
            planAttributedString.deleteCharacters(in: NSRange(planAttributedString.length - 2...planAttributedString.length-1))
        }
        if parkingLot.operatesNonStop {
            planAttributedString = NSMutableAttributedString(
                string: "24/7",
                attributes: planAttributes
            )
        }
        if parkingLot.isClosed {
            planAttributedString = NSMutableAttributedString(
                string: "Temporary not available",
                attributes: planAttributes
            )
        }
        self.workingPlan.attributedText = planAttributedString
    }
    
    private func configureParkingOccupancy() {
        guard let parkingLot else { return }
        if parkingLot.isClosed {
            busyIndicator.layer.borderWidth = 0
            let imageView = UIImageView(image: UIImage(named: "stopCircle")!)
            imageView.tintColor = .black
            imageView.frame = busyIndicator.bounds
            busyIndicator.addSubview(imageView)
            return
        }
        var indicatorColor: UIColor = .clear
        let lowIndicatorValue = Constants.ParkingLotsListScreen.busyIndicatorPassingColorLow
        let mediumIndicatorValue = Constants.ParkingLotsListScreen.busyIndicatorPassingColorMedium
        let highIndicatorValue = Constants.ParkingLotsListScreen.busyIndicatorPassingColorHigh
        switch parkingLot.levelOfOccupancy {
            // Indicator of Busy for 0-33 %
        case 0..<lowIndicatorValue:
            indicatorColor = .green
            // Indicator of occupancy for 33-66 %
        case lowIndicatorValue..<mediumIndicatorValue:
            indicatorColor = .yellow
            // Indicator of occupancy for 66-100 %
        case mediumIndicatorValue...highIndicatorValue:
            indicatorColor = .red
        default:
            indicatorColor = .white
        }
        busyIndicator.backgroundColor = indicatorColor
        let busyLayer = CALayer()
        busyLayer.backgroundColor = UIColor.white.cgColor
        busyLayer.masksToBounds = true
        let freeLots: CGFloat = ((100.0 - CGFloat(parkingLot.levelOfOccupancy))/100.0) * busyIndicator.bounds.height
        busyLayer.frame = CGRect(
            x: 0,
            y: 0,
            width: busyIndicator.bounds.width,
            height: freeLots
        )
        busyIndicator.layer.insertSublayer(busyLayer, above: busyIndicator.layer)
    }
}
