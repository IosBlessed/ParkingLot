//
//  CollectionViewCell.swift
//  ParkingLot
//
//  Created by Никита Данилович on 16.07.2023.
//

import UIKit

class ParkingSpotCollectionViewCell: UICollectionViewCell {
    static let identifier = "ParkingSpotCollectionViewCell"
    
    private let image = UIImageView()
    private let freeView = UIView()
    private let label = UILabel()
        
    override func prepareForReuse() {
        super.prepareForReuse()
        image.image = nil
        label.text = nil
    }
    
    func setup() {
        contentView.addSubview(freeView)
        freeView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            freeView.heightAnchor.constraint(equalToConstant: 16),
            freeView.widthAnchor.constraint(equalToConstant: 20),
            freeView.topAnchor.constraint(equalTo: contentView.topAnchor),
            freeView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            freeView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)
        ])
        freeView.clipsToBounds = true

        freeView.layer.cornerRadius = 10
        
        freeView.layer.borderWidth = 1
        freeView.layer.borderColor = UIColor.black.cgColor
        freeView.addSubview(image)
        image.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            image.centerYAnchor.constraint(equalTo: freeView.centerYAnchor),
            image.centerXAnchor.constraint(equalTo: freeView.centerXAnchor)
        ])
        
        label.font = Fonts.parkingSpotCellLabel
        contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: freeView.trailingAnchor, constant: 8)
        ])
    }
    
    func configure(image: UIImage, label: String, free: Bool) {
        self.image.image = image
        self.label.text = label
        freeView.backgroundColor = free ? CustomSystemColors.availableParkingSpotGreen : CustomSystemColors.unavailableParkingSpotRed
        setup()
    }
}
