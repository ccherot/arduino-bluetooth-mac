//
//  ViewController.swift
//  arduino-bluetooth-mac
//
//  Created by Colin Cherot on 7/16/19.
//  Copyright © 2019 Colin Cherot. All rights reserved.
//

import Cocoa

final class ViewController: NSViewController {
    
    // simple button for our Mac OS App
    private var blueToothIO: BlueToothIO!
    
    override func loadView() {
        // define and size the view for this app
        let view = NSView(frame: NSMakeRect(0, 0, 360, 230))
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.blue.cgColor
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("ViewController > viewDidLoad")
        
        // create a reference to the BlueToothIO
        blueToothIO = BlueToothIO(serviceUUID: "19B10010-E8F2-537E-4F6C-D104768A1214", delegate: self)
        
        // now we programmatically create a button and add it to the view
        let button = NSButton(title: "LED Control", target: self, action: #selector(buttonPressed(_:)))
        button.sendAction(on: [.leftMouseDown, .leftMouseUp])
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
    }
    
    @objc func buttonPressed(_ sender:NSButton){
        let value = Int8(NSEvent.pressedMouseButtons)
        blueToothIO.writeValue(value: value)
    }
}

extension ViewController: BlueToothIODelegate {
    func bluetoothIO(blueToothIO: BlueToothIO, didReceiveValue value: Int8) {
        view.layer?.backgroundColor = value > 0 ? NSColor.yellow.cgColor : NSColor.blue.cgColor
    }
}
