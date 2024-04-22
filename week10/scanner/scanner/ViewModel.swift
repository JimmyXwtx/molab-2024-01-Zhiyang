

import SwiftUI
import AVFoundation
import Foundation
import Vision
import Speech
import AudioToolbox

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
    // Morse code dictionary
        private let morseCode: [Character: String] = [
            "A": ".-", "B": "-...", "C": "-.-.", "D": "-..", "E": ".",
            "F": "..-.", "G": "--.", "H": "....", "I": "..", "J": ".---",
            "K": "-.-", "L": ".-..", "M": "--", "N": "-.", "O": "---",
            "P": ".--.", "Q": "--.-", "R": ".-.", "S": "...", "T": "-",
            "U": "..-", "V": "...-", "W": ".--", "X": "-..-", "Y": "-.--",
            "Z": "--..", "1": ".----", "2": "..---", "3": "...--", "4": "....-",
            "5": ".....", "6": "-....", "7": "--...", "8": "---..", "9": "----.",
            "0": "-----", " ": " "
        ]
    
    override init() {
           super.init()
           setupCamera()
           configureAudioSession() // Ensure this line is correctly called in init
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
    
    func textToMorse(_ text: String) -> String {
            let uppercasedText = text.uppercased()
            return uppercasedText.map { morseCode[$0, default: ""] }.joined(separator: " ")
        }

    func playMorse(_ morse: String) {
        print("Playing Morse Code: \(morse)") // Debug: 输出摩斯代码
        DispatchQueue.global(qos: .userInitiated).async {
            let dotDuration: UInt32 = 200000 // microseconds
            let dashDuration: UInt32 = 800000 // microseconds
            let gapDuration: UInt32 = 400000 // microseconds between elements

            for char in morse {
                switch char {
                case ".":
                    AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                    usleep(dotDuration)
                case "-":
                    AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                    usleep(dashDuration)
                default:
                    usleep(gapDuration)
                }
                usleep(gapDuration) // Gap between dots/dashes
                print("Vibrated for \(char)") // Debug: 输出震动的字符
            }
        }
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
        self.isLoading = true
        let fullPrompt = "Here is OCR results from an image: \"\(text)\". Can you summarize it to make people cannot understand what's it under 10 words, please strictly reply with the 10 words."
        
        askForWords(prompt: fullPrompt) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let responseText):
                    self?.lastScannedText = responseText
                    let morse = self?.textToMorse(responseText) ?? ""
                    self?.playMorse(morse)
                case .failure(let error):
                    print("Error fetching from OpenAI: \(error.localizedDescription)")
                    self?.lastScannedText = "Error: Could not fetch response."
                }
                self?.isLoading = false
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
