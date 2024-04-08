//
//  ContentView.swift
//  scanner
//
//  Created by 王至扬 on 4/7/24.
//
//
//import SwiftUI
//import AVFoundation
//
//struct ContentView: View {
//    @StateObject private var viewModel = ViewModel()
//    
//    var body: some View {
//        VStack {
//            if !viewModel.lastScannedText.isEmpty {
//                Text(viewModel.lastScannedText)
//                    .padding()
//                    .background(Color.gray.opacity(0.5))
//                    .cornerRadius(10)
//                    .foregroundColor(.white)
//            }
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



import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject private var viewModel = ViewModel()
    
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
        }
    }
}
