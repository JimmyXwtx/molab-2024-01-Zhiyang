//
//  ContentView.swift
//  video
//
//  Created by 王至扬 on 3/30/24.
//
import SwiftUI
import AVFoundation
import FirebaseDatabase
//
//
//struct ContentView: View {
//    @StateObject private var viewModel = ViewModel()
//    
//    var body: some View {
//        VStack {
//                    if viewModel.isLoading {
//                        Text("Loading...")
//                            .padding()
//                            .background(Color.blue.opacity(0.5))
//                            .cornerRadius(10)
//                            .foregroundColor(.white)
//                    } else if !viewModel.lastScannedText.isEmpty {
//                        Text(viewModel.lastScannedText)
//                            .padding()
//                            .background(Color.gray.opacity(0.5))
//                            .cornerRadius(10)
//                            .foregroundColor(.white)
//                    }
//            
//            ZStack {
//                if let image = viewModel.capturedImage {
//                    Image(uiImage: image)
//                        .resizable()
//                        .scaledToFit()
//                } else {
//                    CameraView(session: viewModel.session)
//                        .edgesIgnoringSafeArea(.all)
//                }
//            }
//            
//            Button(action: {
//                if viewModel.capturedImage != nil {
//                    viewModel.capturedImage = nil // Reset to show camera again
//                    viewModel.lastScannedText = "" // Clear the text
//                } else {
//                    viewModel.capturePhoto()
//                }
//            }) {
//                Text(viewModel.capturedImage == nil ? "Capture Text" : "Reset")
//                    .foregroundColor(.white)
//                    .padding()
//                    .background(Color.blue)
//                    .cornerRadius(10)
//            }
//        }
//    }
//}
//

struct ContentView: View {
    @StateObject private var viewModel = ViewModel()
    @State private var showingMessageHistory = false // For showing the message history

    var body: some View {
        VStack {
            if viewModel.isLoading {
                Text("Loading...")
                    .padding()
                    .background(Color.blue.opacity(0.5))
                    .cornerRadius(10)
                    .foregroundColor(.white)
            } else if !viewModel.lastScannedText.isEmpty {
                Text(viewModel.lastScannedText)
                    .padding()
                    .background(Color.gray.opacity(0.5))
                    .cornerRadius(10)
                    .foregroundColor(.white)
            }

            ZStack {
                if let image = viewModel.capturedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                } else {
                    CameraView(session: viewModel.session)
                        .edgesIgnoringSafeArea(.all)
                }
            }

            Button(action: {
                if viewModel.capturedImage != nil {
                    viewModel.capturedImage = nil // Reset to show camera again
                    viewModel.lastScannedText = "" // Clear the text
                } else {
                    viewModel.capturePhoto()
                }
            }) {
                Text(viewModel.capturedImage == nil ? "Capture Text" : "Reset")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            
            Button("Show Message History") {
                showingMessageHistory.toggle()
            }
            .foregroundColor(.white)
            .padding()
            .background(Color.green)
            .cornerRadius(10)
        }
        .sheet(isPresented: $showingMessageHistory) {
            MessageHistoryView()
        }
    }
}

// New struct to display message history
struct MessageHistoryView: View {
    @State private var messages: [String] = []
    
    var body: some View {
        List(messages, id: \.self) { message in
            Text(message)
        }
        .onAppear {
            fetchMessagesFromFirebase()
        }
    }
    
    private func fetchMessagesFromFirebase() {
        let messagesRef = Database.database().reference().child("messages")
        messagesRef.observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value as? [String: Any] else { return }
            self.messages = value.compactMap { $0.value as? [String: Any] }.compactMap { $0["text"] as? String }
        })
    }
}
