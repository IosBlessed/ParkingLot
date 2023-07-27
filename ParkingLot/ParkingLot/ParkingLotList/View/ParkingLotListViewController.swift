//
//  ParkingLotListViewController.swift
//  ParkingLot
//
//  Created by Никита Данилович on 05.07.2023.
//

import UIKit
import Combine

protocol ParkingLotListViewControllerProtocol: AnyObject {
    var coordinator: ParkingLotCoordinatorProtocol! { get set }
    var viewModel: ParkingLotListViewModelProtocol! { get set }
}

final class ParkingLotListViewController: UIViewController, ParkingLotListViewControllerProtocol {
    // MARK: - Properties
    var coordinator: ParkingLotCoordinatorProtocol!
    var viewModel: ParkingLotListViewModelProtocol!
    private lazy var addParkingLotAdminButton: CustomButton = {
        let button = CustomButton(
            isMainActor: true,
            isShadowActive: true,
            selector: #selector(addParkingLotLevelButtonTapped),
            target: self
        )
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        button.layer.masksToBounds = true
        return button
    }()
    private lazy var parkingLotListTableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.layer.masksToBounds = true
        tableView.layer.cornerRadius = Constants.ParkingLotsListScreen.tableViewLayerCornerRadius
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.register(ParkingLotTableViewCell.uiNib, forCellReuseIdentifier: ParkingLotTableViewCell.identifier)
        tableView.backgroundColor = .clear
        return tableView
    }()
    private lazy var tableViewDataSource: UITableViewDiffableDataSource<ParkingLotSections, ParkingLot> = {
        let dataSource = UITableViewDiffableDataSource<ParkingLotSections, ParkingLot>(
            tableView: self.parkingLotListTableView) { (tableView, indexPath, itemIdentifier) -> UITableViewCell in
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: ParkingLotTableViewCell.identifier,
                    for: indexPath
                ) as! ParkingLotTableViewCell
                cell.configureCell(with: self.parkingLots[indexPath.row])
                return cell
            }
        return dataSource
    }()
    private var addLotButtonBackgroundImageView: UIImageView = {
        let imageFont = Constants.ParkingLotsListScreen.actionButtonImageFont
        let imageConfiguration = UIImage.SymbolConfiguration(font: imageFont)
        var image: UIImage!
        if GlobalUser.role == UserRole.admin.rawValue {
            image = UIImage(named: "plusIcon", in: Bundle.main, with: imageConfiguration)
        } else {
            image =  UIImage(named: "scanIcon", in: Bundle.main, with: imageConfiguration)
        }
        let imageView = UIImageView(image: image)
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFill
        imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
        return imageView
    }()
    private var actionBottomButton: NSLayoutConstraint!
    private var animationIsRunningFirstTime: Bool = true
    private var cancellable: [AnyCancellable] = []
    private var parkingLots = [ParkingLot]()
    private lazy var emptyTableViewLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textAlignment = .center
        label.attributedText = NSAttributedString(
            string: "No parking lots yet",
            attributes: [
                NSAttributedString.Key.foregroundColor: CustomSystemColors.subtitle,
                NSAttributedString.Key.font: Fonts.buttonText!
            ]
        )
        label.isHidden = true
        return label
    }()
    private var refreshControl = UIRefreshControl()
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = CustomSystemColors.primary
        configureRefreshController()
        setupNavigationBar()
        setupConstraints()
        setupCancellables()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel.requestParkingLots()
        self.updateSnapshot()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateButtonAppearance()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.emptyTableViewLabel.frame = self.parkingLotListTableView.bounds
        configureLayoutParkingLotActionButtonImage()
    }
    // MARK: - Behaviour
    private func configureRefreshController() {
        self.refreshControl.addTarget(self, action: #selector(tableViewShouldRefreshData), for: .valueChanged)
        self.parkingLotListTableView.addSubview(refreshControl)
    }
    
    private func setupNavigationBar() {
        self.title = "Parking Lots"
        navigationItem.hidesBackButton = true
        navigationController?.navigationBar.tintColor = .black
        let settingsButtonItem = configureNavigationBarButton(
            imageName: "settingsIcon",
            selector: #selector(navigtionBarSettingsButtonDidTapped)
        )
        let searchButtonItem = configureNavigationBarButton(
            imageName: "searchIcon",
            selector: #selector(navigationBarMagnifyingGlassButtonDidTap)
            )
        navigationItem.leftBarButtonItem = settingsButtonItem
        navigationItem.rightBarButtonItem = searchButtonItem
    }
    
    private func setupConstraints() {
        view.addSubview(parkingLotListTableView)
        view.addSubview(addParkingLotAdminButton)
        addParkingLotAdminButton.addSubview(addLotButtonBackgroundImageView)
        view.addSubview(emptyTableViewLabel)
    
        // Table view
        parkingLotListTableView.topAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.topAnchor,
            constant: Anchors.ParkingLotsListScreen.parkingListTableViewTopConstant
        ).isActive = true
        parkingLotListTableView.leadingAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.leadingAnchor,
            constant: Anchors.ParkingLotsListScreen.parkingListTableViewLeadingTrailingConstant
        ).isActive = true
        parkingLotListTableView.trailingAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.trailingAnchor,
            constant: -Anchors.ParkingLotsListScreen.parkingListTableViewLeadingTrailingConstant
        ).isActive = true
        parkingLotListTableView.bottomAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.bottomAnchor,
            constant: Anchors.ParkingLotsListScreen.parkingListTableViewBottomConstant
        ).isActive = true
        // add parking lot button
        self.actionBottomButton = addParkingLotAdminButton
            .trailingAnchor
            .constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: Anchors.ParkingLotsListScreen.actionBottomButtonBeforeTrailingConstant
            )
        actionBottomButton.isActive = true
        addParkingLotAdminButton.bottomAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.bottomAnchor,
            constant: Anchors.ParkingLotsListScreen.actionBottomButtonBottomConstant
        ).isActive = true
        addParkingLotAdminButton.heightAnchor.constraint(
            equalToConstant: Anchors.ParkingLotsListScreen.actionBottomButtonWidthHeightConstant
        ).isActive = true
        addParkingLotAdminButton.widthAnchor.constraint(
            equalToConstant: Anchors.ParkingLotsListScreen.actionBottomButtonWidthHeightConstant
        ).isActive = true
    }
    
    private func setupCancellables() {
        viewModel.parkingLotsListResult
            .receive(on: DispatchQueue.main)
            .sink { [weak self] queryResult in
                guard let self else { return }
                switch queryResult {
                case .success(let parkingLots):
                    if parkingLots.isEmpty {
                        self.emptyTableViewLabel.isHidden = false
                    } else {
                        self.parkingLots = parkingLots
                        self.updateSnapshot()
                    }
                    
                case .failure(_):
                    let alertController = self.showAlertMessage(
                        title: "Oops..",
                        desriptionMessage: "Looks like your token expired, please, login in once again!",
                        actionButtonTitle: "OK",
                        destructiveHandler: { _ in },
                        handler: { _ in
                            // TODO: Drop user to login
                            KeychainService.shared.deleteUser(handler: { _ in})
                            self.navigationController?.popToRootViewController(animated: true)
                        }
                    )
                    self.present(alertController, animated: true)
                    
                case .none:
                    return
                }
            }.store(in: &cancellable)
    }
    
    private func animateButtonAppearance() {
        addParkingLotAdminButton.isHidden = false
        if animationIsRunningFirstTime {
            UIView.animate(withDuration: 1.0) { [weak self] in
                self?.actionBottomButton.constant = Anchors.ParkingLotsListScreen.actionBottomButtonAfterTrailingConstant
                self?.addParkingLotAdminButton.rotate()
                self?.view.layoutIfNeeded()
            }
        }
        animationIsRunningFirstTime = false
    }
    
    private func configureLayoutParkingLotActionButtonImage() {
        addParkingLotAdminButton.layer.cornerRadius = addParkingLotAdminButton.bounds.height / 2
        let marginOffset: CGFloat = Constants.ParkingLotsListScreen.actionBottomButtonImageMarginOffset
        let imageViewFrame = CGRect(
            x: marginOffset,
            y: marginOffset,
            width: addParkingLotAdminButton.bounds.width - marginOffset * 2,
            height: addParkingLotAdminButton.bounds.height - marginOffset * 2
        )
        addLotButtonBackgroundImageView.frame = imageViewFrame
    }
    
    private func updateSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<ParkingLotSections, ParkingLot>()
        snapshot.appendSections([.main])
        snapshot.appendItems(parkingLots)
        tableViewDataSource.apply(snapshot, animatingDifferences: true)
        self.refreshControl.endRefreshing()
    }
    
    private func configureNavigationBarButton(imageName: String, selector: Selector) -> UIBarButtonItem {
        let customButton = UIButton(type: .custom)
        customButton.frame = CGRect(x: 0.0, y: 0.0, width: 20, height: 20)
        customButton.setImage(UIImage(named: imageName), for: .normal)
        customButton.addTarget(self, action: selector, for: .touchUpInside)

        let menuBarItem = UIBarButtonItem(customView: customButton)
        menuBarItem.customView?.translatesAutoresizingMaskIntoConstraints = false
        let currWidth = menuBarItem.customView?.widthAnchor.constraint(equalToConstant: Anchors.ParkingLotsListScreen.navigationBarButtonItemsWidthHeightConstant)
        currWidth?.isActive = true
        let currHeight = menuBarItem.customView?.heightAnchor.constraint(equalToConstant: Anchors.ParkingLotsListScreen.navigationBarButtonItemsWidthHeightConstant)
        currHeight?.isActive = true
        return menuBarItem
    }
    // MARK: - Selectors
    @objc private func addParkingLotLevelButtonTapped() {
        addParkingLotAdminButton.animateButtonWhenTapping()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let role = GlobalUser.role else { return }
            switch role {
            case UserRole.admin.rawValue:
                self?.coordinator.openCreateParkingLotScreen()
            case UserRole.regular.rawValue:
                self?.coordinator.regularUserWantsToScanLot()
            default:
                return
            }
        }
    }
    
    @objc private func tableViewShouldRefreshData() {
        self.viewModel.requestParkingLots()
        self.updateSnapshot()
    }
    
    @objc private func navigationBarMagnifyingGlassButtonDidTap() {
        
    }
    
    @objc private func navigtionBarSettingsButtonDidTapped() {
        coordinator.configureSettingsScreen()
    }
}

extension ParkingLotListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.ParkingLotsListScreen.heightForParkingLotListRow
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.coordinator.openEditParkingLotScreen(parkingLot: parkingLots[indexPath.row], fromCreate: false)
        tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
    }
}

