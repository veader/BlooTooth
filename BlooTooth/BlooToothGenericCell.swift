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

    let checkMark = "☑"
    let xCheckMark = "☒"

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var uuidLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var expandedIndicationLabel: UILabel!

    @IBOutlet weak var genericTypeLabel: UILabel!
    @IBOutlet weak var genericTypeView: UIView!

    @IBOutlet weak var infoButton: UIButton!

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
        self.valueLabel.hidden = true
        self.infoButton.hidden = true
        setType(.serviceCell)

        if let characteristics = service.characteristics {
            if characteristics.count > 0 {
                self.expandedIndicationLabel.hidden = false
            } else {
                self.expandedIndicationLabel.hidden = true
            }
        } else {
            self.expandedIndicationLabel.hidden = true
        }
    }

    func setCharacteristicInfo() {
        guard let char = self.characteristic else { return }
        // self.nameLabel.text = char.description
        self.nameLabel.text = char.friendlyName()
        var finalString = "Notifying: \(char.isNotifying == true ? checkMark : xCheckMark)  |  UUID: "
        finalString.appendContentsOf(char.UUID.UUIDString)
        self.uuidLabel.text = finalString
        if let valueString = stringForValue(char.value) {
            self.valueLabel.hidden = false
            self.valueLabel.text = valueString
        } else {
            self.valueLabel.hidden = true
        }
        self.infoButton.hidden = false
        setType(.characteristicCell)

        if let descriptors = char.descriptors {
            if descriptors.count > 0 {
                self.expandedIndicationLabel.hidden = false
            } else {
                self.expandedIndicationLabel.hidden = true
            }
        } else {
            self.expandedIndicationLabel.hidden = true
        }
    }

    func setDescriptorInfo() {
        guard let descriptor = self.descriptor else { return }
        // self.nameLabel.text = descriptor.description
        self.nameLabel.text = descriptor.friendlyName()
        self.uuidLabel.text = descriptor.UUID.UUIDString
        self.valueLabel.hidden = false
        if let valueString = stringForValue(descriptor.value) {
            self.valueLabel.hidden = false
            self.valueLabel.text = valueString
        } else {
            self.valueLabel.hidden = true
        }
        self.infoButton.hidden = true
        self.expandedIndicationLabel.hidden = true
        setType(.descriptorCell)
    }

    func setIndentLevel(numberOfIndents: Int) {
        let paddingSize: CGFloat = 12.0
        let marginSize: CGFloat = 4.0
        let padding: CGFloat = CGFloat(numberOfIndents - 1)
        self.leftConstraint.constant = marginSize + (padding * paddingSize)
    }

    func stringForValue(value: AnyObject?) -> String? {
        guard let data = value as? NSData else { return nil }
        let string = String(data: data, encoding: NSUTF8StringEncoding)
        if string?.isEmpty == true || string == "\0" {
            let result = NSKeyedUnarchiver.unarchiveObjectWithData(data)
            print(data)
            print(result)
            return nil
        } else {
            return string
        }
    }

    func setType(type: BTGenericCellType) {
        switch type {
        case .serviceCell:
            self.genericTypeView.backgroundColor = UIColor.blackColor()
        case .characteristicCell:
            self.genericTypeView.backgroundColor = UIColor.darkGrayColor()
        case .descriptorCell:
            self.genericTypeView.backgroundColor = UIColor.lightGrayColor()
        }
        self.genericTypeLabel.textColor = UIColor.whiteColor()
        self.genericTypeLabel.text = type.rawValue
    }

    func updateExpandedIndicator() {
        if self.cellExpanded == true {
            self.expandedIndicationLabel.text = "-"
        } else {
            self.expandedIndicationLabel.text = "+"
        }
    }
}
