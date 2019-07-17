//
//  ViewController.swift
//  arduino-bluetooth-ios
//
//  Created by Colin Cherot on 7/10/19.
//  Copyright © 2019 Colin Cherot. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // create reference to our BlueToothIO
    var blueToothIO: BlueToothIO!

    // reference for our LED Button in the UI
    @IBOutlet weak var ledControlButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // here we initialize the BlueToothIO with the Service UUID
        // for the LED code running on the Arduino 101
        blueToothIO = BlueToothIO(serviceUUID: "19B10010-E8F2-537E-4F6C-D104768A1214", delegate: self)
        print("ViewController > ViewDidLoad")
    }
    
    // define func for LED button press
    @IBAction func ledControlButtonDown(_ sender: UIButton){
        print("ViewConrtoller > ledControlButtonDown")
        blueToothIO.writeValue(value: 1)
    }
    
    @IBAction func ledControllButtonUp(_ sender: UIButton){
        print("ViewController > ledControlButtonUp")
        blueToothIO.writeValue(value: 0)
    }
}

// here we extend the ViewController class to add
// the BlueToothIODelegate functionality which allows
// the button on the Arduino board to change the background
// color of the app
extension ViewController: BlueToothIODelegate {
    func bluetoothIO(blueToothIO: BlueToothIO, didReceiveValue value: Int8) {
        if value > 0 {
           view.backgroundColor = UIColor.yellow
        } else {
            view.backgroundColor = UIColor.blue
        }
    }
}

