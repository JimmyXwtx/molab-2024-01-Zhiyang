//
//  ContentView.swift
//  readpng
//
//  Created by 王至扬 
//

import SwiftUI
import AVFoundation
import Vision

struct ContentView: View {
    @State private var image: UIImage? = nil
    @State private var showingImagePicker = false
    @State private var recognizedText = "Select an image to start."

    var body: some View {
        NavigationView {
            VStack {
                Image(uiImage: self.image ?? UIImage(systemName: "photo")!)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
                    .padding()

                Text(recognizedText)
                    .padding()

                Button("Select Image") {
                    self.showingImagePicker = true
                }
                .padding()
                .foregroundColor(.white)
                .background(Color.blue)
                .clipShape(Capsule())

                Button("Read Text") {
                    readText(self.recognizedText)
                }
                .padding()
                .foregroundColor(.white)
                .background(Color.green)
                .clipShape(Capsule())
            }
            .navigationTitle("READ YOUR IMAGE")
            .sheet(isPresented: $showingImagePicker, onDismiss: recognizeText) {
                ImagePicker(image: self.$image)
            }
        }
    }

    func recognizeText() {
        guard let cgImage = image?.cgImage else { return }

        // Vision framework for OCR
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let request = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            let recognizedStrings = observations.compactMap { $0.topCandidates(1).first?.string }
            self.recognizedText = recognizedStrings.joined(separator: "\n")
        }

        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
    }

    func readText(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
    }
}

