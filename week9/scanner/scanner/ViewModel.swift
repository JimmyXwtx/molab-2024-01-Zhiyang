//
//  ViewModel.swift
//  scanner
//
//  Created by 王至扬 on 4/7/24.
//
//
//
//import SwiftUI
//import AVFoundation
//import Foundation
//import Vision
//import Speech
//import FirebaseDatabase
//
//class ViewModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
//    let session = AVCaptureSession()
//    let photoOutput = AVCapturePhotoOutput()
//    @Published var capturedImage: UIImage?
//    @Published var lastScannedText: String = ""
//    @Published var isLoading = false
//    
//    // 指向您的OpenAI API代理服务器的URL
//    let openAIProxy = "https://openai-api-proxy.glitch.me/AskOpenAI/"
//
//    override init() {
//        super.init()
//        setupCamera()
//        configureAudioSession()
//    }
//
//    private func setupCamera() {
//        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
//              let input = try? AVCaptureDeviceInput(device: device) else {
//            return
//        }
//        if session.canAddInput(input) && session.canAddOutput(photoOutput) {
//            session.addInput(input)
//            session.addOutput(photoOutput)
//        }
//    }
//    
//    func capturePhoto() {
//        let settings = AVCapturePhotoSettings()
//        photoOutput.capturePhoto(with: settings, delegate: self)
//    }
//    
//    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
//        guard let imageData = photo.fileDataRepresentation(),
//              let image = UIImage(data: imageData) else {
//            return
//        }
//        DispatchQueue.main.async {
//            self.capturedImage = image
//            self.performOCR(image: image) // OCR处理
//        }
//    }
//    
//    private func performOCR(image: UIImage) {
//        guard let cgImage = image.cgImage else { return }
//        let request = VNRecognizeTextRequest { [weak self] request, error in
//            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
//            let recognizedStrings = observations.compactMap { $0.topCandidates(1).first?.string }
//            DispatchQueue.main.async {
//                let recognizedText = recognizedStrings.joined(separator: "\n")
//                self?.lastScannedText = recognizedText.isEmpty ? "No text found." : recognizedText
//                if !recognizedText.isEmpty {
//                    self?.fetchResponseFromOpenAI(for: recognizedText) // 调用OpenAI API
//                }
//            }
//        }
//        request.recognitionLevel = .accurate
//        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
//        DispatchQueue.global(qos: .userInitiated).async {
//            try? handler.perform([request])
//        }
//    }
//
//    private func fetchResponseFromOpenAI(for text: String) {
//        self.isLoading = true
//        
//        askForWords(prompt: text) { [weak self] result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let responseText):
//                    self?.lastScannedText = responseText
//                    // 成功获取到OpenAI的回复后保存到Firebase
//                    self?.saveMessageToFirebase(text: responseText)
//                case .failure(let error):
//                    print("Error fetching from OpenAI: \(error.localizedDescription)")
//                    self?.lastScannedText = "Error: Could not fetch response."
//                }
//                self?.isLoading = false
//            }
//        }
//    }
//    
//    private func saveMessageToFirebase(text: String) {
//        let messagesRef = Database.database().reference().child("messages")
//        let messageItemRef = messagesRef.childByAutoId()
//        messageItemRef.setValue(["text": text])
//    }
//    
//    // 使用您提供的代码实现askForWords
//    func askForWords(prompt: String, completion: @escaping (Result<String, Error>) -> Void) {
//        guard let url = URL(string: openAIProxy) else {
//            print("Invalid URL")
//            return
//        }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        
//        let requestBody: [String: Any] = [
//            "model": "gpt-3.5-turbo-instruct",
//            "prompt": prompt,
//            "temperature": 0,
//            "max_tokens": 1000
//        ]
//        
//        do {
//            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
//        } catch let error {
//            completion(.failure(error))
//            return
//        }
//        
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            DispatchQueue.main.async {
//                if let error = error {
//                    completion(.failure(error))
//                    return
//                }
//                
//                guard let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 else {
//                    print("No data or statusCode not OK")
//                    completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
//                    return
//                }
//                
//                do {
//                    if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any], let choices = jsonObject["choices"] as? [[String: Any]], !choices.isEmpty, let text = choices[0]["text"] as? String {
//                        completion(.success(text))
//                    } else {
//                        completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Error parsing JSON"])))
//                    }
//                } catch let error {
//                    completion(.failure(error))
//                }
//            }
//        }
//        task.resume()
//    }
//    
//    private func configureAudioSession() {
//        do {
//            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
//            try AVAudioSession.sharedInstance().setActive(true)
//        } catch {
//            print("Audio session configuration failed")
//        }
//    }
//}
//
//struct CameraView: UIViewControllerRepresentable {
//    var session: AVCaptureSession
//
//    func makeUIViewController(context: Context) -> UIViewController {
//        let viewController = UIViewController()
//        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
//        previewLayer.frame = viewController.view.bounds
//        previewLayer.videoGravity = .resizeAspectFill
//        viewController.view.layer.addSublayer(previewLayer)
//
//        session.startRunning()
//        return viewController
//    }
//
//    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
//        // Leave this empty if there's no need to update your UI dynamically
//    }
//}

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
    @Published var isLoading = false

    
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
                // Here, before calling speak, make the OpenAI API call
                if !recognizedText.isEmpty {
                    self?.fetchResponseFromOpenAI(for: recognizedText)
                }
            }
        }
        request.recognitionLevel = .accurate
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            try? handler.perform([request])
        }
    }

    private func fetchResponseFromOpenAI(for text: String) {
        self.isLoading = true // Indicate loading
        
        // Concatenating your specific instruction with the OCR'd text
        let fullPrompt = "Here is OCR results from an image: \"\(text)\". Can you summarize it to make people cannot understand what's it under 10 words, please strictly reply with the 10 words."
        
        askForWords(prompt: fullPrompt) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let responseText):
                    self?.lastScannedText = responseText
                case .failure(let error):
                    print("Error fetching from OpenAI: \(error.localizedDescription)")
                    self?.lastScannedText = "Error: Could not fetch response."
                }
                self?.isLoading = false // Reset loading state
            }
        }
    }

    
    private func speak(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
    }
}

let openAIProxy = "https://openai-api-proxy.glitch.me/AskOpenAI/"

func askForWords(prompt: String, completion: @escaping (Result<String, Error>) -> Void) {
    guard let url = URL(string: openAIProxy) else {
        print("Invalid URL")
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let requestBody: [String: Any] = [
        "model": "gpt-3.5-turbo-instruct",
        "prompt": prompt,
        "temperature": 0,
        "max_tokens": 1000
    ]
    
    do {
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
    } catch let error {
        completion(.failure(error))
        return
    }
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        DispatchQueue.main.async {
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                print("No data or statusCode not OK")
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                return
            }
            
            do {
                if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any], let choices = jsonObject["choices"] as? [[String: Any]], !choices.isEmpty, let text = choices[0]["text"] as? String {
                    completion(.success(text))
                } else {
                    completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Error parsing JSON"])))
                }
            } catch let error {
                completion(.failure(error))
            }
        }
    }
    task.resume()
}
