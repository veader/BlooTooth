//
//  BlooToothConstants.swift
//  BlooTooth
//
//  Created by Shawn Veader on 10/5/15.
//  Copyright © 2015 V8 Logic. All rights reserved.
//

import Foundation

enum BlueToothKnownServices: String {
    case ServiceHTTPProxy = "1823"
    case ServiceAlertNotification = "1811"
    case ServiceAutomationIO = "1815"
    case ServiceBattery = "180F"
    case ServiceBloodPressure = "1810"
    case ServiceBodyComposition = "181B"
    case ServiceBondManagement = "181E"
    case ServiceContinuousGlucoseMonitoring = "181F"
    case ServiceCurrentTime = "1805"
    case ServiceCyclingPower = "1818"
    case ServiceCyclingSpeedAndCadence = "1816"
    case ServiceDeviceInfo = "180A"
    case ServiceEnvSensing = "181A"
    case ServiceGenericAccess = "1800"
    case ServiceGenericAttribute = "1801"
    case ServiceGlucose = "1808"
    case ServiceHealthThermometer = "1809"
    case ServiceHeartRate = "180D"
    case ServiceHumanInterfaceDevice = "1812"
    case ServiceImmediateAlert = "1802"
    case ServiceIndoorPositioning = "1821"
    case ServiceInternetProtocolSupport = "1820"
    case ServiceLinkLoss = "1803"
    case ServiceLocationAndNavigation = "1819"
    case ServiceNextDSTChange = "1807"
    case ServicePhoneAlertStatus = "180E"
    case ServicePulseOximeter = "1822"
    case ServiceReferenceTimeUpdate = "1806"
    case ServiceRunningSpeedAndCadence = "1814"
    case ServiceScanParameters = "1813"
    case ServiceTxPower = "1804"
    case ServiceUserData = "181C"
    case ServiceWeightScale = "181D"
}

let BlueToothKnownServicesLookup: [BlueToothKnownServices: String] = [
    .ServiceHTTPProxy:          "HTTP Proxy",
    .ServiceAlertNotification:  "Alert Notification Service",
    .ServiceAutomationIO:       "Automation IO",
    .ServiceBattery:            "Battery Service",
    .ServiceBloodPressure:      "Blood Pressure",
    .ServiceBodyComposition:    "Body Composition",
    .ServiceBondManagement:     "Bond Management",
    .ServiceContinuousGlucoseMonitoring: "Continuous Glucose Monitoring",
    .ServiceCurrentTime:        "Current Time Service",
    .ServiceCyclingPower:       "Cycling Power",
    .ServiceCyclingSpeedAndCadence: "Cycling Speed and Cadence",
    .ServiceDeviceInfo:         "Device Information",
    .ServiceEnvSensing:         "Environmental Sensing",
    .ServiceGenericAccess:      "Generic Access",
    .ServiceGenericAttribute:   "Generic Attribute",
    .ServiceGlucose:            "Glucose",
    .ServiceHealthThermometer:  "Health Thermometer",
    .ServiceHeartRate:          "Heart Rate",
    .ServiceHumanInterfaceDevice: "Human Interface Device",
    .ServiceImmediateAlert:     "Immediate Alert",
    .ServiceIndoorPositioning:  "Indoor Positioning",
    .ServiceInternetProtocolSupport: "Internet Protocol Support",
    .ServiceLinkLoss:           "Link Loss",
    .ServiceLocationAndNavigation: "Location and Navigation",
    .ServiceNextDSTChange:      "Next DST Change Service",
    .ServicePhoneAlertStatus:   "Phone Alert Status Service",
    .ServicePulseOximeter:      "Pulse Oximeter",
    .ServiceReferenceTimeUpdate: "Reference Time Update Service",
    .ServiceRunningSpeedAndCadence: "Running Speed and Cadence",
    .ServiceScanParameters:     "Scan Parameters",
    .ServiceTxPower:            "Tx Power",
    .ServiceUserData:           "User Data",
    .ServiceWeightScale:        "Weight Scale",
]


