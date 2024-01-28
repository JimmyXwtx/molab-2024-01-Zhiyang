// Code Reference: JHT-https://github.com/molab-itp/01-Playground/blob/main/01-Playground.playground/Pages/generative%20random.xcplaygroundpage/Contents.swift

import Foundation

let moonString = "🌚🌕🌖🌗🌘🌑🌒🌓🌔"

func charAt(_ str: String, _ offset: Int) -> String {
    let index = str.index(str.startIndex, offsetBy: offset)
    let char = str[index]
    return String(char)
}

func generateLine(_ n: Int) -> String {
    var randomPick = ""
    for _ in 0..<n {
        let randomInt = Int.random(in: 0..<moonString.count)
        randomPick += charAt(moonString, randomInt)
    }
    return randomPick
}

func drawShape() {
    var currentLine = generateLine(moonString.count)
    let maxWidth = currentLine.count
    print(currentLine)
    for _ in 1..<moonString.count/2+1 {
        currentLine = String(currentLine.dropFirst().dropLast())
        let padding = String(repeating: "〰️", count: (maxWidth - currentLine.count) / 2)
        print(padding + currentLine + padding)
    }
}
func drawReversedShape() {
    var currentLine = generateLine(1)
    let maxWidth = moonString.count
    
    for i in stride(from: 1, through: moonString.count, by: 2) {
        if(maxWidth - currentLine.count >= 0){
            let padding = String(repeating: "〰️", count: (maxWidth - currentLine.count) / 2)
            print(padding + currentLine + padding)
            currentLine = generateLine(i + 2)
        }
       
    }
}


drawShape()
drawReversedShape()
