import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        ZStack {
            // CameraView as the base layer, full screen
            CameraView(session: viewModel.session)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                if viewModel.isLoading {
                    // Loading indicator
                    Text("Loading...")
                        .padding()
                        .background(Color.blue.opacity(0.5))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .padding(.top, 20) // Padding at the top for visibility
                } else if !viewModel.lastScannedText.isEmpty {
                    // Display last scanned text, which is the OpenAI summarized response
                    Text(viewModel.lastScannedText)
                        .padding()
                        .background(Color.gray.opacity(0.5))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .padding(.top, 20) // Padding at the top for visibility
                }
                
                Spacer() // Pushes everything to the top
                
                if let image = viewModel.capturedImage {
                    // Display captured image with option to reset
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                }
            }
            
            VStack {
                Spacer() // Makes sure button is at the bottom
                // Double tap gesture to trigger photo capture or reset
                Text(viewModel.capturedImage == nil ? "Tap anywhere to Capture" : "Tap anywhere to Reset")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                    .padding(.bottom, 50) // Padding at the bottom for visibility
            }
        }
        .onTapGesture(count: 2) {
            if viewModel.capturedImage != nil {
                viewModel.capturedImage = nil // Reset to show camera again
                viewModel.lastScannedText = "" // Clear the text
            } else {
                viewModel.capturePhoto()
            }
        }
    }
}
