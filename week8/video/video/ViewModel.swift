//
//  ViewModel.swift
//  video
//
//  Created by 王至扬 on 3/30/24.
//
import SwiftUI
import AVFoundation
import Foundation
import Vision
import Speech

private func configureAudioSession() {
    do {
        try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
        try AVAudioSession.sharedInstance().setActive(true)
    } catch {
        print("Audio session configuration failed")
    }
}


struct CameraView: UIViewControllerRepresentable {
    var session: AVCaptureSession
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = viewController.view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        viewController.view.layer.addSublayer(previewLayer)
        
        DispatchQueue.global(qos: .userInitiated).async { [weak session] in
            session?.startRunning()
        }
        return viewController
    }

    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

class ViewModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    let session = AVCaptureSession()
    let photoOutput = AVCapturePhotoOutput()
    @Published var capturedImage: UIImage?
    @Published var lastScannedText: String = ""
    
    override init() {
        super.init()
        setupCamera()
        configureAudioSession() // Add this line
    }

    private func setupCamera() {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device) else {
            return
        }
        if session.canAddInput(input) && session.canAddOutput(photoOutput) {
            session.addInput(input)
            session.addOutput(photoOutput)
        }
    }
    
    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            return
        }
        DispatchQueue.main.async {
            self.capturedImage = image
        }
        performOCR(image: image)
    }
    
    private func performOCR(image: UIImage) {
        guard let cgImage = image.cgImage else { return }
        let request = VNRecognizeTextRequest { [weak self] request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            let recognizedStrings = observations.compactMap { $0.topCandidates(1).first?.string }
            DispatchQueue.main.async {
                let recognizedText = recognizedStrings.joined(separator: "\n")
                self?.lastScannedText = recognizedText.isEmpty ? "No text found." : recognizedText
                // Call `speak` directly with the recognized text, avoiding the optional issue
                self?.speak(text: recognizedText.isEmpty ? "No text found." : recognizedText)
            }
        }
        request.recognitionLevel = .accurate
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            try? handler.perform([request])
        }
    }

    
    private func speak(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
    }
}
