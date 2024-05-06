import SwiftUI

struct ContentView: View {
    @State private var isCameraPresented = false
    @State private var image: UIImage?
    @State private var imageDescription = ""

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                Text("Double tap to capture")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black)
            }

            TextOverlay(description: $imageDescription)
        }
        .onTapGesture(count: 2) {
            isCameraPresented = true
        }
        .fullScreenCover(isPresented: $isCameraPresented) {
            CameraView(image: $image, imageDescription: $imageDescription)
        }
    }
}

struct TextOverlay: View {
    @Binding var description: String

    var body: some View {
        Text(description)
            .padding()
            .background(Color.black.opacity(0.7))
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding()
            .transition(.slide)
            .animation(.easeInOut)
    }
}
