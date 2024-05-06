import SwiftUI
import UIKit
import AVFoundation


struct CameraView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var image: UIImage?
    @Binding var imageDescription: String

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: CameraView

        init(_ parent: CameraView) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
                parent.presentationMode.wrappedValue.dismiss()
                uploadImageToAPI(image: image)
            }
        }

        func uploadImageToAPI(image: UIImage) {
            guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }
            let base64ImageString = imageData.base64EncodedString()

            let url = URL(string: "https://replicate-api-proxy.glitch.me/create_n_get/")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body: [String: Any] = [
                "version": "2e1dddc8621f72155f24cf2e0adbde548458d3cab9f00c0139eea840d0ac4746", // 
                "input": [
                    "task": "image_captioning",
                    "image": base64ImageString
                ]
            ]
            
            request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    DispatchQueue.main.async {
                        self.parent.imageDescription = responseString
                        speak(description: responseString)
                    }
                }
            }.resume()
        }
    }
}


func speak(description: String) {
    let utterance = AVSpeechUtterance(string: description)
    utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
    let synthesizer = AVSpeechSynthesizer()
    synthesizer.speak(utterance)
}
