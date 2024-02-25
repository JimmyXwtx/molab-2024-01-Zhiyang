//
//  WEEK_4_AUDIO_SOUNDApp.swift
//  WEEK-4-AUDIO-SOUND
//
//  Created by 王至扬 on 2/24/24.
// Learned from JHT's https://github.com/molab-itp/content-2024-01/blob/main/weeks/04_swiftui.md#:~:text=AVAudioPlayer%20docs-,04%2DSlideShowDemo,-audio%20playback%20over
// Use GPT for debugging
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
