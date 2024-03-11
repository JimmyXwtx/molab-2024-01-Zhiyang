//
//  UIViewController.swift
//  week-5-sensor
//
//  Created by 王至扬 on 3/2/24.
//

import UIKit
import SwiftUI
import Foundation
class ShakeDetectingViewController: UIViewController {
    var onShake: () -> Void = {}
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            onShake()
        }
    }
}
struct ShakeDetectingView: UIViewControllerRepresentable {
    var onShake: () -> Void

    func makeUIViewController(context: Context) -> ShakeDetectingViewController {
        ShakeDetectingViewController()
    }

    func updateUIViewController(_ uiViewController: ShakeDetectingViewController, context: Context) {
        uiViewController.onShake = onShake
    }
}


struct ShakeRecord: Codable {
    var count: Int
    
    static let fileName = "shakeRecord.json"
    
    static func loadFromFile() -> ShakeRecord {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName)
        if let data = try? Data(contentsOf: path), let record = try? JSONDecoder().decode(ShakeRecord.self, from: data) {
            return record
        }
        return ShakeRecord(count: 0)
    }
    
    func saveToFile() {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(ShakeRecord.fileName)
        if let data = try? JSONEncoder().encode(self) {
            try? data.write(to: path, options: .atomicWrite)
        }
    }
}
