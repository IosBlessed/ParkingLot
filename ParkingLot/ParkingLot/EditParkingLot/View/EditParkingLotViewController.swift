//
//  EditParkingLotViewController.swift
//  ParkingLot
//
//  Created by Никита Данилович on 07.07.2023.
//

import UIKit
import Combine

protocol EditParkingLotViewControllerProtocol: AnyObject {
    var coordinator: ParkingLotCoordinatorProtocol! { get set }
    var parkingLot: ParkingLot? { get set }
    var fromCreate: Bool { get set }
}

class EditParkingLotViewController: UIViewController, EditParkingLotViewControllerProtocol {
    
    var parkingLot: ParkingLot?
    var coordinator: ParkingLotCoordinatorProtocol!
    var viewModel:  EditParkingLotViewModelProtocol!
    private var cancellableStates = [AnyCancellable]()
    
    var fromCreate = false
    
    private lazy var detailsParkingLotVc: CreateParkingLotViewController = {
        var vc = CreateParkingLotBuilder.build(parkingLot: parkingLot) as! CreateParkingLotViewController
        vc.coordinator = self.coordinator
        return vc
    }()
    
    private lazy var parkingSpotsVc = ParkingSpotsBuilder.build(parkingLot: parkingLot!)
    
    private let containerView = UIView()
    
    private var lineView: UIView!
    private var detailsButton: UIButton!
    private var paekingSpotsButton: UIButton!
    private var lineLeadingConstraint: NSLayoutConstraint!
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavBar()
        setupNavigationBarButtons()
        setupContainerView()
        addChilds()
        setupCancellables()
    }
    //MARK: - Setup NavigationBar
    private func setupNavBar() {
        navigationItem.title = parkingLot?.name ?? "Some name"
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: Fonts.screenTitleLabel!
        ]
        
        let backButton = UIBarButtonItem(image: UIImage(named: "Vector"), style: .plain, target: self, action: #selector(goBack))
        navigationItem.leftBarButtonItems = [backButton]
        
        let deleteButton = UIBarButtonItem(image: UIImage(named: "bin"), style: .plain, target: self, action: #selector(deleteLot))
        navigationItem.rightBarButtonItems = [deleteButton]
    }
    
    @objc private func goBack() {
        let alertController = UIAlertController(title: "Are you sure that you want to continue?", message: "If going back, all your progress will be lost!", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default) {[weak self] _ in
            guard let self else { return }
            if self.fromCreate {
                if let viewControllers = navigationController?.viewControllers {
                    if viewControllers.count >= 3 {
                        let viewControllerToPopBackTo = viewControllers[viewControllers.count - 3]
                        navigationController?.popToViewController(viewControllerToPopBackTo, animated: true)
                    }
                }
            } else {
                self.navigationController?.popViewController(animated:true)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) {_ in }
        alertController.addAction(yesAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true)
    }
    
    @objc private func deleteLot() {
        let alertController = UIAlertController(title: "Are you sure that you want to delete this parking lot?", message: "Parking lot and all related info will be deleted", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { [weak self] _ in
            guard let self else { return }
            self.viewModel.deleteParkingLot(with: self.parkingLot?.id ?? 0)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) {_ in }
        alertController.addAction(yesAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true)
    }
    
    private func setupCancellables() {
        viewModel.deletionResult.receive(on: DispatchQueue.main)
            .sink { [weak self] queryResult in
                guard let self else { return }
                switch queryResult {
                case true:
                    self.navigationController?.popViewController(animated:true)
                case false:
                    let alertController = self.showAlertMessage(
                        title: "Oops..",
                        desriptionMessage: "Looks like something went wrong, please try one more time!",
                        actionButtonTitle: "OK",
                        destructiveHandler: { _ in },
                        handler: { _ in }
                    )
                    self.present(alertController, animated: true)
                default: break
                }
            }.store(in: &cancellableStates)
    }
    
    //MARK: - Setup container
    private func setupContainerView() {
        self.containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: detailsButton.bottomAnchor, constant: 5),
            containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
    }
    
    //MARK: - Setup navigation tab bar
    private func setupNavigationBarButtons() {
        
        detailsButton = UIButton(type: .system)
        detailsButton.setTitle("Details", for: .normal)
        detailsButton.titleLabel?.font = Fonts.tabButtonText
        detailsButton.titleLabel?.tintColor = .black
        detailsButton.addTarget(self, action: #selector(button1Tapped), for: .touchUpInside)
        
        paekingSpotsButton = UIButton(type: .system)
        paekingSpotsButton.setTitle("Parking spots", for: .normal)
        paekingSpotsButton.titleLabel?.font = Fonts.tabButtonText
        paekingSpotsButton.titleLabel?.tintColor = .black
        paekingSpotsButton.addTarget(self, action: #selector(button2Tapped), for: .touchUpInside)
        
        lineView = UIView()
        lineView.backgroundColor = CustomSystemColors.secondary
        
        view.addSubview(detailsButton)
        view.addSubview(paekingSpotsButton)
        view.addSubview(lineView)
        
        detailsButton.translatesAutoresizingMaskIntoConstraints = false
        paekingSpotsButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            detailsButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            detailsButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            detailsButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            detailsButton.heightAnchor.constraint(equalToConstant: 50),
            
            paekingSpotsButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            paekingSpotsButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            paekingSpotsButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            paekingSpotsButton.heightAnchor.constraint(equalToConstant: 50),
        ])
        
        lineView.translatesAutoresizingMaskIntoConstraints = false
        
        lineLeadingConstraint = lineView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        NSLayoutConstraint.activate([
            lineLeadingConstraint,
            lineView.widthAnchor.constraint(equalTo: detailsButton.widthAnchor),
            lineView.heightAnchor.constraint(equalToConstant: 2),
            lineView.topAnchor.constraint(equalTo: detailsButton.bottomAnchor),
        ])
    }
    
    @objc private  func button1Tapped() {
        moveLineToButton(button: detailsButton)
        showDetailsVC()
    }
    
    @objc private  func button2Tapped() {
        moveLineToButton(button: paekingSpotsButton)
        showParkingSpotsVC()
    }
    
    private func moveLineToButton(button: UIButton) {
        lineLeadingConstraint.constant = button.frame.origin.x
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func addChilds() {
        addChild(detailsParkingLotVc)
        containerView.addSubview(detailsParkingLotVc.view)
        didMove(toParent: self)
        
        detailsParkingLotVc.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            detailsParkingLotVc.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            detailsParkingLotVc.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            detailsParkingLotVc.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            detailsParkingLotVc.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
        
        addChild(parkingSpotsVc)
        containerView.addSubview(parkingSpotsVc.view)
        parkingSpotsVc.view.isHidden = true
        didMove(toParent: self)
        
        parkingSpotsVc.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            parkingSpotsVc.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            parkingSpotsVc.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            parkingSpotsVc.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            parkingSpotsVc.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
    }
    
    private func showParkingSpotsVC() {
        parkingSpotsVc.view.isHidden = false
        detailsParkingLotVc.view.isHidden = true
    }
    
    private func showDetailsVC() {
        parkingSpotsVc.view.isHidden = true
        detailsParkingLotVc.view.isHidden = false
    }
}
