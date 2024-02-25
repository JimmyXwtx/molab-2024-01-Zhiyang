// Use GPT to convert code from css into swift/ gradient
// convert code from class #1
// https://zhiyangwang.hosting.nyu.edu/hh/week3/

import SwiftUI

struct ContentView: View {
    @State private var dateTime = Date()
    @State private var showShape = false
    @State private var shapeContent: String = "" // Store the current shape content

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    let gradient = LinearGradient(
        gradient: Gradient(colors: [Color(red: 106/255, green: 216/255, blue: 240/255), Color(red: 212/255, green: 233/255, blue: 148/255)]),
        startPoint: .leading,
        endPoint: .trailing
    )
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                dateTimeView.frame(maxWidth: .infinity).foregroundColor(.white)
                Button("MOON") {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        if showShape {
                            self.showShape = false
                        } else {
                            self.showShape = true
                            self.shapeContent = drawShapes()
                        }
                    }
                }
                .padding()
                .background(Color.green.opacity(0.2))
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 25))
                
                if showShape {
                    Text(shapeContent) // Use the stored
                        .padding()
                }
            }
            .padding()
        }
        .onReceive(timer) { input in
            dateTime = input
        }
        .background(gradient)
    }
    
    var dateTimeView: some View {
        Text("\(dateTime, formatter: itemFormatter)")
            .padding()
            .background(Color.green.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 25))
    }
}

var itemFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    formatter.timeStyle = .long
    return formatter
}
extension ContentView {
    func drawShapes() -> String {
        let moonString = "🌚🌕🌖🌗🌘🌑🌒🌓🌔"
        var output = ""
        
        func charAt(_ str: String, _ offset: Int) -> String {
            let index = str.index(str.startIndex, offsetBy: offset)
            return String(str[index])
        }
        
        func generateLine(_ n: Int) -> String {
            var randomPick = ""
            for _ in 0..<n {
                let randomInt = Int.random(in: 0..<moonString.count)
                randomPick += charAt(moonString, randomInt)
            }
            return randomPick
        }
        
        func drawShape() -> String {
            var result = ""
            var currentLine = generateLine(moonString.count)
            let maxWidth = currentLine.count
            result += currentLine + "\n"
            for _ in 1..<moonString.count/2+1 {
                currentLine = String(currentLine.dropFirst().dropLast())
                let padding = String(repeating: " ", count: (maxWidth - currentLine.count) / 2)
                result += padding + currentLine + padding + "\n"
            }
            return result
        }
        
        func drawReversedShape() -> String {
            var result = ""
            var currentLine = generateLine(1)
            let maxWidth = moonString.count
            
            for i in stride(from: 1, through: moonString.count, by: 2) {
                if maxWidth - currentLine.count >= 0 {
                    let padding = String(repeating: " ", count: (maxWidth - currentLine.count) / 2)
                    result += padding + currentLine + padding + "\n"
                    currentLine = generateLine(i + 2)
                }
            }
            return result
        }
        
        output += drawShape()
        output += drawReversedShape()
        output += drawShape()
        output += drawReversedShape()
        return output
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


