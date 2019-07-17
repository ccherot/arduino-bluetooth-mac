//
//  NSDataInt8Support.swift
//  arduino-bluetooth-ios
//
//  Created by Colin Cherot on 7/10/19.
//  Copyright © 2019 Colin Cherot. All rights reserved.
//
//  This is code borrowed from Nebojsa Petrovic from his
// Hellow BlueTooth project.  This extension to NSData is
// for the purpose of sending 8 bit values to a chacteristic
// for an Arduino based peripheral

import Foundation

extension Data {
    static func dataWithValue(value: Int8) -> Data {
        var variableValue = value
        return Data(buffer: UnsafeBufferPointer(start: &variableValue, count: 1))
    }
    
    func int8Value() -> Int8 {
        return Int8(bitPattern: self[0] )
    }
}
