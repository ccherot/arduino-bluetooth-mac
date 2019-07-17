//
//  BluetoothIO.swift
//  arduino-bluetooth-ios
//
//  Created by Colin Cherot on 7/11/19.
//  Copyright © 2019 Colin Cherot. All rights reserved.
//

import CoreBluetooth

protocol BlueToothIODelegate: class {
    func bluetoothIO(blueToothIO: BlueToothIO, didReceiveValue value: Int8)
}

class BlueToothIO: NSObject {
    // This is going to be the service UUID of the LED service
    // on the Arduino 101
    let serviceUUID: String
    // TODO: why is this a weak reference?
    weak var delegate: BlueToothIODelegate?
    
    // Core BlueTooth is based on the concept of a "central"
    // and various BT "peripherals" with various services
    // that have various "characteristics" with parameters that
    // can be read, written, or both
    var centralManager: CBCentralManager!
    var connectedPeripheral: CBPeripheral?
    var targetService: CBService?
    var writableCharacteristic: CBCharacteristic?
    
    // initializer for this class which gets passed an instantiation
    // of the BlueToothIODelegate defined above
    init(serviceUUID: String, delegate: BlueToothIODelegate?) {
        self.serviceUUID = serviceUUID
        self.delegate = delegate
        
        super.init()
        
        // create the central and use this class (self) as
        // the delegate
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        print("BlueToothIO > init > serviceUUID is \(self.serviceUUID)")
    }
    
    func writeValue(value: Int8){
        guard let peripheral = connectedPeripheral, let characteristic = writableCharacteristic else {
            print("BlueToothIO > writeValue > no peripheral or no characteristic")
            return
        }
        
        let data = Data.dataWithValue(value: value)
        peripheral.writeValue(data, for: characteristic, type: .withResponse)
        print("BlueToothIO > writeValue > writing \(value)")
    }
    
}

// here we extend on BlueToothIO to make it a CBCentralManagerDelegate

extension BlueToothIO: CBCentralManagerDelegate {
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("BlueToothIO > centrlManager > didConnect")
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover
        peripheral: CBPeripheral, advertisementData: [String : Any],
        rssi RSSI: NSNumber) {
        
        print("BlueToothIO > centralManager > peripheral discovered")
        connectedPeripheral = peripheral
        
        if let connectedPeripheral = connectedPeripheral {
            print("BlueToothIO > centralManager > connectedPeripheral found")
            connectedPeripheral.delegate = self
            centralManager.connect(peripheral, options: nil)
        }
        centralManager.stopScan();
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            print("BlueToothIO > centralManagerDidUpdateState > .poweredOn")

            centralManager.scanForPeripherals(withServices: [CBUUID(string: serviceUUID)], options: nil)
        }
        print("BlueToothIO > centralManagerDidUpdateState > central.state is \(central.state)")
    }
}

extension BlueToothIO: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else {
            print("BlueToothIO > peripheral > didDiscoverServices > no services on peripheral")
            return
        }
        
        targetService = services.first
        if let service = services.first {
            targetService = service
            peripheral.discoverCharacteristics(nil, for: service)
            print("BlueToothIO > peripheral > didDisocverServices > targetService found, discovering characteristics")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics  = service.characteristics else {
            print("BlueToothIO > peripheral > didDiscoverCharacteristicsFor > no characteristics found")
            return
        }
        
        for characteristic in characteristics {
            if characteristic.properties.contains(.write) || characteristic.properties.contains(.writeWithoutResponse){
            print("BlueToothIO > peripheral > didDiscoverCharacteristicsFor > writeableCharacterisitc found")
                writableCharacteristic = characteristic
            }
            peripheral.setNotifyValue(true, for: characteristic)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let data = characteristic.value, let delegate = delegate else {
            print("BlueToothIO > peripheral > didUpdateValueFor > no data")
            return
        }
        print("BlueToothIO > peripheral > didUpdateValueFor > \(data.int8Value())")
        delegate.bluetoothIO(blueToothIO: self, didReceiveValue: data.int8Value())
    }
}
