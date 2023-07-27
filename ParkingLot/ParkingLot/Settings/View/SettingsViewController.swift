//
//  SettingsViewController.swift
//  ParkingLot
//
//  Created by Никита Данилович on 19.07.2023.
//

import UIKit

enum TypeOfSection: String {
    case notification
    case signOut
    case deleteUser
}

struct SettingsSection: Hashable {
    let section: TypeOfSection
    var image: String? = nil
    let title: String
}

class SettingsViewController: UIViewController, SettingsViewControllerProtocol {
    
    var coordinator: ParkingLotCoordinatorProtocol!
    private lazy var settingsTableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(SettingsTableViewCell.nib, forCellReuseIdentifier: SettingsTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    private var settingsSections: [SettingsSection] = [
        SettingsSection(section: .notification, title: "Receive Notifications"),
        SettingsSection(section: .signOut, image: "exitIcon", title: "Sign Out"),
        SettingsSection(section: .deleteUser, image: "binIcon", title: "Delete User")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = CustomSystemColors.primary
        setupNavigationBar()
        setupConstraints()
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "Settings"
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: Fonts.screenTitleLabel!
        ]
        let backButtonItem = UIBarButtonItem(
            image: UIImage(named: "Vector"),
            style: .plain,
            target: self,
            action: #selector(navigationBarBackButtonTapped)
        )
        navigationItem.leftBarButtonItem = backButtonItem
    }
    
    private func setupConstraints() {
        view.addSubview(settingsTableView)
        
        settingsTableView.topAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.topAnchor,
            constant: Anchors.SettingsScreen.settingsTableViewMarginConstant
        ).isActive = true
        settingsTableView.leadingAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.leadingAnchor,
            constant: Anchors.SettingsScreen.settingsTableViewMarginConstant
        ).isActive = true
        settingsTableView.trailingAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.trailingAnchor,
            constant: -Anchors.SettingsScreen.settingsTableViewMarginConstant
        ).isActive = true
        settingsTableView.bottomAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.bottomAnchor,
            constant: -Anchors.SettingsScreen.settingsTableViewMarginConstant
        ).isActive = true
    }
    
    @objc private func navigationBarBackButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.SettingsScreen.tableViewHeightForRow
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var alertController: UIAlertController!
        switch settingsSections[indexPath.row].section {
        case .deleteUser:
            alertController = self.showAlertMessage(
                title: "Be careful!",
                desriptionMessage: "Are you sure that you want to delete account?",
                actionButtonTitle: "No",
                destructiveButtonTitle: "Yes",
                destructiveHandler: { _ in },
                handler: { _ in }
            )
        case .signOut:
            alertController = self.showAlertMessage(
                title: "Time to say goodbye...",
                desriptionMessage: "Are you sure that you want to exit?",
                actionButtonTitle: "No",
                destructiveButtonTitle: "Yes",
                destructiveHandler: { _ in
                    KeychainService.shared.deleteUser(handler: { _ in})
                    self.navigationController?.popToRootViewController(animated: true)
                },
                handler: { _ in }
            )
        default:
            return
        }
        self.present(alertController, animated: true)
    }
}

extension SettingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsSections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: SettingsTableViewCell.identifier) as? SettingsTableViewCell {
            cell.configureCell(by: settingsSections[indexPath.row])
            return cell
        }
        return UITableViewCell(frame: .zero)
    }
}
