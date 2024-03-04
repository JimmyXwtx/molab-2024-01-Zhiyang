//
//  week_5_sensorApp.swift
//  week-5-sensor
//
//  Created by 王至扬 on 3/2/24.
//

import SwiftUI

@main
struct SlideShowDemoApp: App {
    @StateObject var audioDJ = AudioDJ()
    var body: some Scene {
        WindowGroup {
            RouletteSlideShowView()
                .environmentObject(audioDJ)
        }
    }
}
