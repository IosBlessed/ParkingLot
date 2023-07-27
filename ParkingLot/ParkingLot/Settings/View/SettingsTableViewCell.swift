//
//  SettingsTableViewCell.swift
//  ParkingLot
//
//  Created by Никита Данилович on 19.07.2023.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var sectionImageView: UIImageView!
    @IBOutlet private weak var sectionLabel: UILabel!
    @IBOutlet private weak var sectionSwitch: UISwitch! {
        didSet {
            sectionSwitch.isOn = false
        }
    }
    private var setting: SettingsSection!
    
    static let identifier: String = String(describing: SettingsTableViewCell.self)
    static let nib: UINib = {
        let nib = UINib(
            nibName: String(describing: SettingsTableViewCell.self),
            bundle: Bundle.main
        )
        return nib
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func configureCell(by setting: SettingsSection) {
        self.setting = setting
        self.backgroundColor = .clear
        self.sectionLabel.text = setting.title
        switch setting.section {
        case .notification:
            self.sectionImageView.isHidden = true
        default:
            self.sectionSwitch.isHidden = true
            let image = UIImage(named: setting.image ?? "homekit")
            self.sectionImageView.image = image?.withRenderingMode(.alwaysTemplate)
            self.sectionImageView.tintColor = setting.section == .deleteUser ? .red : .black
        }
        setupConstraints()
    }
    private func setupConstraints() {
        
        sectionImageView.translatesAutoresizingMaskIntoConstraints = false
        sectionLabel.translatesAutoresizingMaskIntoConstraints = false
        sectionSwitch.translatesAutoresizingMaskIntoConstraints = false
        
        
        sectionImageView.centerYAnchor.constraint(
            equalTo: self.centerYAnchor
        ).isActive = true
        sectionImageView.leadingAnchor.constraint(
            equalTo: self.leadingAnchor,
            constant: Anchors.SettingsScreen.sectionImageViewLeadingConstant
        ).isActive = true
        sectionImageView.heightAnchor.constraint(
            equalToConstant: Anchors.SettingsScreen.sectionImageViewHeightConstant
        ).isActive = true
        sectionImageView.widthAnchor.constraint(
            equalToConstant: Anchors.SettingsScreen.sectionImageViewWidthConstant
        ).isActive = true
        
        sectionLabel.topAnchor.constraint(
            equalTo: self.topAnchor,
            constant: Anchors.SettingsScreen.sectionLabelTopConstant
        ).isActive = true
        sectionLabel.leadingAnchor.constraint(
            equalTo: setting.section == .notification ? self.leadingAnchor : sectionImageView.trailingAnchor,
            constant: Anchors.SettingsScreen.sectionImageViewLeadingConstant
        ).isActive = true
        sectionLabel.trailingAnchor.constraint(
            equalTo: sectionSwitch.leadingAnchor,
            constant: Anchors.SettingsScreen.sectionLabelTrailingConstant
        ).isActive = true
        sectionLabel.bottomAnchor.constraint(
            equalTo: self.bottomAnchor,
            constant: Anchors.SettingsScreen.sectionLabelBottomConstant
        ).isActive = true
        
        sectionSwitch.centerYAnchor.constraint(
            equalTo: self.centerYAnchor,
            constant: Anchors.SettingsScreen.sectionSwitchCenterYPosConstant
        ).isActive = true
        sectionSwitch.trailingAnchor.constraint(
            equalTo: self.trailingAnchor,
            constant: Anchors.SettingsScreen.sectionSwitchTrailingConstant
        ).isActive = true
        sectionSwitch.heightAnchor.constraint(
            equalToConstant: Anchors.SettingsScreen.sectionSwitchWidthConstant
        ).isActive = true
        sectionSwitch.widthAnchor.constraint(
            equalToConstant: Anchors.SettingsScreen.sectionSwitchHeightConstant
        ).isActive = true
    }
}
