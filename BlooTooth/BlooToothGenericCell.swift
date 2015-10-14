//
//  BlooToothGenericCell.swift
//  BlooTooth
//
//  Created by Shawn Veader on 10/12/15.
//  Copyright © 2015 V8 Logic. All rights reserved.
//

import UIKit
import CoreBluetooth

enum BTGenericCellType: String {
    case serviceCell = "S"
    case characteristicCell = "C"
    case descriptorCell = "D"
}

class BlooToothGenericCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var uuidLabel: UILabel!
    @IBOutlet weak var expandedIndicationLabel: UILabel!
    @IBOutlet weak var genericTypeLabel: UILabel!
    @IBOutlet weak var genericTypeView: UIView!
    @IBOutlet weak var leftConstraint: NSLayoutConstraint!

    var service: CBService? {
        didSet {
            setServiceInfo()
        }
    }

    var characteristic: CBCharacteristic? {
        didSet {
            setCharacteristicInfo()
        }
    }

    var descriptor: CBDescriptor? {
        didSet {
            setDescriptorInfo()
        }
    }

    var cellExpanded: Bool = false {
        didSet {
            updateExpandedIndicator()
        }
    }

    // MARK: - Override Methods
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCellStyle.Subtitle, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        print("GenericCell: awakeFromNib")
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    override func prepareForReuse() {
        clearState()
    }

    func clearState() {
        self.service = nil
        self.characteristic = nil
        self.descriptor = nil
    }

    // MARK: - Setup Methods
    func setServiceInfo() {
        guard let service = self.service else { return }
        // self.nameLabel.text = BlooToothManager.sharedInstance.serviceNameFromUUID(service.UUID.UUIDString)
        self.nameLabel.text = service.friendlyName()
        self.uuidLabel.text = service.UUID.UUIDString
        setType(.serviceCell)
    }

    func setCharacteristicInfo() {
        guard let char = self.characteristic else { return }
        // self.nameLabel.text = char.description
        self.nameLabel.text = char.friendlyName()
        self.uuidLabel.text = char.UUID.UUIDString
        setType(.characteristicCell)
    }

    func setDescriptorInfo() {
        guard let descriptor = self.descriptor else { return }
        // self.nameLabel.text = descriptor.description
        self.nameLabel.text = descriptor.friendlyName()
        self.uuidLabel.text = descriptor.UUID.UUIDString
        setType(.descriptorCell)
    }

    func setIndentLevel(numberOfIndents: Int) {
        let paddingSize: CGFloat = 12.0
        let marginSize: CGFloat = 4.0
        let padding: CGFloat = CGFloat(numberOfIndents - 1)
        self.leftConstraint.constant = marginSize + (padding * paddingSize)
    }

    func setType(type: BTGenericCellType) {
        switch type {
            case .serviceCell:
                self.genericTypeLabel.text = "S"
                self.genericTypeLabel.textColor = UIColor.whiteColor()
                self.genericTypeView.backgroundColor = UIColor.blackColor()
            case .characteristicCell:
                self.genericTypeLabel.text = "C"
                self.genericTypeLabel.textColor = UIColor.whiteColor()
                self.genericTypeView.backgroundColor = UIColor.darkGrayColor()
            case .descriptorCell:
                self.genericTypeLabel.text = "D"
                self.genericTypeLabel.textColor = UIColor.whiteColor()
                self.genericTypeView.backgroundColor = UIColor.lightGrayColor()
        }
    }

    func updateExpandedIndicator() {
        if self.cellExpanded == true {
            self.expandedIndicationLabel.text = "-"
        } else {
            self.expandedIndicationLabel.text = "+"
        }
    }
}
