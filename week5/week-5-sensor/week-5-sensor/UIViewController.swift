//
//  UIViewController.swift
//  week-5-sensor
//
//  Created by 王至扬 on 3/2/24.
//

import UIKit
import SwiftUI

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
