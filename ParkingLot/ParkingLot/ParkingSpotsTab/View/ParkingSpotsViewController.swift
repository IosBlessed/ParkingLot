//
//  ParkingSpotsViewController.swift
//  ParkingLot
//
//  Created by Никита Данилович on 16.07.2023.
//

import UIKit
import Combine

class ParkingSpotsViewController: UIViewController {
    var coordinator: ParkingLotCoordinatorProtocol!
    var viewModel: ParkingSpotsViewModelProtocol!
    
    private var cancellable: [AnyCancellable] = []
    
    private var nrOfLevels = 0
    private var parkingSpots = [ParkingSpot]() {
        didSet {
            collectionView.reloadData()
        }
    }
    private var levelNames = [
        "Level A",
        "Level B",
        "Level C",
        "Level D",
        "Level E",
    ]
    
    private var cancellableStates = [AnyCancellable]()
    
    private var menu = UIMenu()
    private var levelButton = UIButton()
    private var collectionView: UICollectionView!
    private var scrollView = UIScrollView()
    private var contentView = UIView()
    
}

// MARK: - LIFE CYCLE
extension ParkingSpotsViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        setupLevelButton()
        setupScrollView()
        setupCollectionView()
        setupCancellables()
        viewModel.requestForParkingSpots(parkingLevel: 0)
    }
}

// MARK: - DROP DOWN BUTTON SETUP
extension ParkingSpotsViewController {
    
    private func setupMenuElements(for levels: Int) -> [UIAction] {
        var elements = [UIAction]()
        
        let levelA = UIAction(title: "Level A") { [weak self] action in
            guard let self else {return}
            self.levelButton.setTitle(elements[0].title, for: .normal)
            viewModel.requestForParkingSpots(parkingLevel: 0)
        }
        
        let levelB = UIAction(title: "Level B") {[weak self] _ in
            guard let self else {return}
            self.levelButton.setTitle(elements[1].title, for: .normal)
            viewModel.requestForParkingSpots(parkingLevel: 1)
        }
        
        let levelC = UIAction(title: "Level C") {[weak self] _ in
            guard let self else {return}
            self.levelButton.setTitle(elements[2].title, for: .normal)
            viewModel.requestForParkingSpots(parkingLevel: 2)
        }
        
        let levelD = UIAction(title: "Level D") {[weak self] _ in
            guard let self else {return}
            self.levelButton.setTitle(elements[3].title, for: .normal)
            viewModel.requestForParkingSpots(parkingLevel: 3)
        }
        
        let levelE = UIAction(title: "Level E") {[weak self] _ in
            guard let self else {return}
            self.levelButton.setTitle(elements[4].title, for: .normal)
            viewModel.requestForParkingSpots(parkingLevel: 4)
        }
        
        switch levels {
        case 1:
            elements = [levelA]
        case 2:
            elements = [levelA, levelB]
        case 3:
            elements = [levelA, levelB, levelC]
        case 4:
            elements = [levelA, levelB, levelC, levelD]
        case 5:
            elements = [levelA, levelB, levelC, levelD, levelE]
        default:
            elements = []
        }
        
        return elements
    }
    
    private func setupLevelButton() {
        var buttonConfig = UIButton.Configuration.plain()
        
        buttonConfig.image = UIImage(systemName: "chevron.down")
        buttonConfig.title = levelNames[0]
        buttonConfig.baseForegroundColor = CustomSystemColors.contrastText
        buttonConfig.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
        buttonConfig.imagePlacement = .trailing
        
        levelButton = UIButton(configuration: buttonConfig)
        levelButton.titleLabel?.font = Fonts.parkingSpotLevelButton
        levelButton.showsMenuAsPrimaryAction = true
        levelButton.menu = menu
        
        levelButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(levelButton)
        
        NSLayoutConstraint.activate([
            levelButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            levelButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
}

// MARK: - SETUP CANCELLABLES

extension ParkingSpotsViewController {
    private func setupCancellables() {
        viewModel.parkingLot
            .receive(on: DispatchQueue.main)
            .sink { [weak self] parkingLot in
                guard let self else {return}
                self.nrOfLevels = parkingLot?.levels.count ?? 0
                self.menu = UIMenu(children: setupMenuElements(for: nrOfLevels))
                levelButton.menu = menu
            }
        .store(in: &cancellableStates)
        
        viewModel.parkingSpotsListResult
            .receive(on: DispatchQueue.main)
            .sink { [weak self] queryResult in
                guard let self else { return }
                switch queryResult {
                case .success(let parkingLots):
                    self.parkingSpots = parkingLots
                    
                case .failure(_):
                    let alertController = self.showAlertMessage(
                        title: "Oops..",
                        desriptionMessage: "Looks like went wrong, please try one more time!",
                        actionButtonTitle: "OK",
                        destructiveHandler: { _ in },
                        handler: { _ in }
                    )
                    self.present(alertController, animated: true)
                    
                case .none:
                    return
                }
            }.store(in: &cancellable)
    }
}

// MARK: - COLLECTION VIEW SETUP
extension ParkingSpotsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
       
        scrollView.addSubview(contentView)
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: levelButton.bottomAnchor, constant: 16),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.heightAnchor.constraint(equalToConstant: 1500),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ])
    }
    
    private func setupCollectionView() {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: 100, height: 20)
        layout.sectionInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(ParkingSpotCollectionViewCell.self, forCellWithReuseIdentifier: ParkingSpotCollectionViewCell.identifier)
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.contentMode = .scaleToFill
        contentView.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return parkingSpots.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
       return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ParkingSpotCollectionViewCell.identifier, for: indexPath) as! ParkingSpotCollectionViewCell
        var image = UIImage()
        switch parkingSpots[indexPath.row].type {
        case "FAMILY": image = UIImage(named: "family") ?? UIImage()
        case "DISABILITY": image = UIImage(named: "disability") ?? UIImage()
        default: image = UIImage()
        }
        
        let isAvailable = parkingSpots[indexPath.row].state == "AVAILABLE" ? true : false
        
        cell.configure(image: image,
                       label: parkingSpots[indexPath.row].number, free: isAvailable)
        return cell
    }
}
