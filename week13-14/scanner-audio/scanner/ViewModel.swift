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
    
    // Vibration pattern dictionary
    private let vibrationPattern: [Character: String] = [
        "A": "S", "B": "S P S", "C": "S P L", "D": "L P S", "E": "L",
        "F": "D", "G": "T", "H": "S P S P S", "I": "S P L P S", "J": "L P S P L",
        "K": "D P S", "L": "T P L", "M": "D P D", "N": "T P T", "O": "L P L P L",
        "P": "S P D", "Q": "L P T", "R": "S P T P S", "S": "L P D P L", "T": "T P D",
        "U": "D P L", "V": "T P S", "W": "L P D", "X": "D P T", "Y": "T P D P T",
        "Z": "L P T P L", "1": "S", "2": "S P S", "3": "S P S P S", "4": "S P S P S P S",
        "5": "S P S P S P S P S", "6": "L P L", "7": "L P L P L", "8": "L P L P L P L",
        "9": "L P L P L P L P L", "0": "D P D", " ": "P P"
    ]
    
    override init() {
        super.init()
        setupCamera()
        configureAudioSession()
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
                // Send OCR results to OpenAI
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
        let fullPrompt = "This is a software for BlindDeaf, efficient word is important. Here is OCR results from an image: \"\(text)\". Can you summarize/guess it to make people cannot understand what's it under 3 words, please strictly reply with the 3 words about the content in the image. Please Strickly 3 words"
        
        askForWords(prompt: fullPrompt) { [weak self] result in
                   DispatchQueue.main.async {
                       self?.isLoading = false
                       switch result {
                       case .success(let responseText):
                           self?.lastScannedText = responseText
                           self?.speak(text: responseText)  // Speaking the response
                           let vibrationPattern = self?.textToVibration(responseText) ?? ""
                           self?.playVibration(vibrationPattern)
                       case .failure(let error):
                           print("Error fetching from OpenAI: \(error.localizedDescription)")
                           self?.lastScannedText = "Error: Could not fetch response."
                       }
                   }
               }
    }
    func speak(text: String) {
          let utterance = AVSpeechUtterance(string: text)
          utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
          let synthesizer = AVSpeechSynthesizer()
          synthesizer.speak(utterance)
      }
    func textToVibration(_ text: String) -> String {
        let uppercasedText = text.uppercased()
        return uppercasedText.map { vibrationPattern[$0, default: ""] }.joined(separator: " P ")
    }

    func playVibration(_ pattern: String) {
        print("Playing Vibration Pattern: \(pattern)")
        DispatchQueue.global(qos: .userInitiated).async {
            for part in pattern.split(separator: " ") {
                switch part {
                case "S":
                    AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                    usleep(200000) // Short vibration
                case "L":
                    AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                    usleep(600000) // Long vibration
                case "D":
                    AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                    usleep(100000) // Pause then vibrate again quickly
                    AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                case "T":
                    AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                    usleep(100000)
                    AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                    usleep(100000)
                    AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                case "P":
                    usleep(300000) // Pause
                default:
                    usleep(300000) // Default pause
                }
            }
        }
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
