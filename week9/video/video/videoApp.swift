//
//  videoApp.swift
//  video
//
//  Created by 王至扬 on 3/30/24.
//

import SwiftUI
import Firebase

@main
struct videoApp: App {
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
