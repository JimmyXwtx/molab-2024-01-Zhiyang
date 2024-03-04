//
//  ContentView.swift
//  week-5-sensor
//
//  Created by 王至扬 on 3/2/24.
//

import SwiftUI
import AVFoundation

let slides = ["globe.asia.australia.fill", "sun.min.fill", "airplane.arrival", "sailboat.circle.fill", "scooter"]

struct RouletteSlideShowView: View {
    @State private var slideIndex = Int.random(in: 0..<slides.count)
    @State private var dateTime = Date()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    let gradient = LinearGradient(
        gradient: Gradient(colors: [Color(red: 106/255, green: 216/255, blue: 240/255), Color(red: 212/255, green: 233/255, blue: 148/255)]),
        startPoint: .leading,
        endPoint: .trailing
    )

    @EnvironmentObject var audioDJ: AudioDJ

    var body: some View {
        NavigationView {
            VStack {
                Text("Roulette")
                    .font(.title)
                dateTimeView.frame(maxWidth: .infinity).foregroundColor(.white)
                SingleSlideView(name: slides[slideIndex])
                    .padding()

                Button(action: {
                    spinTheRoulette()
                }) {
                    Image(systemName: "shuffle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                        .padding()
                }
                
          
                ShakeDetectingView {
                    //
                    spinTheRoulette()
                }
                .frame(width: 0, height: 0) //set to 0 view
                
            }
            .onReceive(timer) { input in
                dateTime = input
            }
            .background(gradient)
            .navigationBarHidden(true)
        }
    }

    

    
    var dateTimeView: some View {
        Text("\(dateTime, formatter: itemFormatter)")
            .padding()
            .background(Color.green.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 25))
    }

    func spinTheRoulette() {
        slideIndex = Int.random(in: 0..<slides.count)
        audioDJ.chooseRandom()
        audioDJ.play()
    }
}


var itemFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    formatter.timeStyle = .long
    return formatter
}

struct RouletteSlideShowView_Previews: PreviewProvider {
    static var previews: some View {
        RouletteSlideShowView()
            .environmentObject(AudioDJ())
    }
}

struct SingleSlideView: View {
    var name: String
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer() // Vertical centering content
                Image(systemName: name)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: geometry.size.width * 1)
                    .alignmentGuide(HorizontalAlignment.center) { d in d[HorizontalAlignment.center] } // HorizontalAlignment
                Text(name)
                Spacer() // Vertical centering content
            }
        }
    }
}


class AudioDJ: ObservableObject {
    @Published var soundIndex = 0
    @Published var soundFile = AudioDJ.audioRef[0]
    var player: AVAudioPlayer?

    func play() {
        player?.stop()
        player = loadAudio(soundFile)
        player?.numberOfLoops = 0
        player?.play()
    }

    func stop() {
        player?.stop()
    }

    func chooseRandom() {
        soundIndex = Int.random(in: 0..<AudioDJ.audioRef.count)
        soundFile = AudioDJ.audioRef[soundIndex]
    }
    func loadAudio(_ str:String) -> AVAudioPlayer? {
        if (str.hasPrefix("https://")) {
            return loadUrlAudio(str)
        }
        return loadBundleAudio(str)
    }
    
    func loadUrlAudio(_ urlString:String) -> AVAudioPlayer? {
        let url = URL(string: urlString)
        do {
            let data = try Data(contentsOf: url!)
            return try AVAudioPlayer(data: data)
        } catch {
            print("loadUrlSound error", error)
        }
        return nil
    }
    
    func loadBundleAudio(_ fileName:String) -> AVAudioPlayer? {
        let path = Bundle.main.path(forResource: fileName, ofType:nil)!
        let url = URL(fileURLWithPath: path)
        do {
            return try AVAudioPlayer(contentsOf: url)
        } catch {
            print("loadBundleAudio error", error)
        }
        return nil
    }
    
    static let audioRef = ["epic.mp3", "water.mp3", "piano.mp3"]

    
}
