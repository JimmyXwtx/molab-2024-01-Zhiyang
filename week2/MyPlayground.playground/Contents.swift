import SwiftUI
import PlaygroundSupport

let wide = 1024.0;
let high = 1024.0;

struct ContentView: View {
  var body: some View {
    ZStack {
      Ellipse()
        .fill(Color.blue)
        .mask(
          Image(systemName: "rectangle")
            .resizable()
            .aspectRatio(contentMode: .fit)
        )
        .frame(width: wide, height: high)
        
      Ellipse()
        .fill(Color.white.opacity(0.7))
        .mask(
          Image(systemName: "circle")
            .resizable()
            .aspectRatio(contentMode: .fit)
        )
        .frame(width: wide*0.7, height: high*1.0)
      Ellipse()
        .fill(Color.white.opacity(0.5))
        .frame(width: wide*0.5, height: high*1.0)
        VStack(spacing: 0.05) {
        Color.green.opacity(0.9)
        Color.green.opacity(0.7)
        Color.green.opacity(0.5)
        Color.green.opacity(0.3)
        Color.green.opacity(0.5)
        Color.green.opacity(0.7)
        Color.green.opacity(0.9)
      }
      .mask(
        Image(systemName: "circle")
          .resizable()
          .aspectRatio(contentMode: .fit)
      )
      .frame(width: wide*0.8, height: high*0.8)
    Ellipse()
      .fill(Color.black.opacity(0.3))
      .frame(width: wide*0.1, height: high*0.7)
    Ellipse()
      .fill(Color.black.opacity(0.3))
      .frame(width: high*0.7, height: wide*0.1)
    }
  }
}

PlaygroundPage.current.setLiveView(
  ContentView()
    .frame(width: wide, height: high)
)

