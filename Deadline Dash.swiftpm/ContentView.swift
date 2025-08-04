import SwiftUI

struct ContentView: View {
    enum Direction {
        case up, down, left, right, none
    }
    
    let gridSize = 20
    let cellSize: CGFloat = 35
    
    let hardRoast = [
        "Game Over! Even a snail finishes more tasks than you 🐌💤",
        "Game Over! My grandma types faster than you 👵⌨️",
        "Game Over! Productivity level: potato 🥔",
        "Game Over! You call that effort? Pathetic 🙄",
        "Game Over! You move slower than a dial-up connection 📞🐢",
        "Game Over! I've seen rocks be more productive 🪨",
        "Game Over! Did you even try or just nap? 🛌",
        "Game Over! You make procrastination look like a sport 🏆",
        "Game Over! Even the loading bar is faster than you ⏳",
        "Game Over! Your focus lasted shorter than a TikTok video 🎬",
        "Game Over! You got speed of a sloth on vacation 🦥",
        "Game Over! Your brain went on holiday without telling you 🧠✈️",
        "Game Over! Watching paint dry is more exciting than your progress 🎨🧱",
        "Game Over! You have the urgency of a cat ignoring you 🐱🙄",
        "Game Over! Your work ethic is taking a permanent coffee break ☕️💤",
        "Game Over! Even your shadow is faster than you 🕶️💨",
        "Game Over! Are you sure you're not competing in a nap contest? 💤🥇"
    ]
    
    let lightRoast = [
        "Game Over! Not the worst, but seriously, step it up 🙄",
        "Game Over! You're barely hanging in there... 🥴",
        "Game Over! Could do better, but hey, at least you showed up 🤷‍♂️",
        "Game Over! You tried, but let's not get comfortable 😏",
        "Game Over! Meh... could be worse, could be better 🤡",
        "Game Over! Almost had it, but close only counts in horseshoes 🐴",
        "Game Over! You gave a decent effort, but I expected fireworks 🎆",
        "Game Over! Better luck next time, champ 🏅",
        "Game Over! You're like a slow loading page, but at least you load... eventually 📶",
        "Game Over! Could be worse — you could have stayed in bed all day 🛏️"
    ]
    
    @State private var gameStarted = false
    @State private var openGame = true
    
    @State private var pacmanPosition = CGPoint(x: 10, y: 10)
    @State private var direction: Direction = .none
    @State private var foodPositions: [CGPoint] = []
    @State private var score = 0
    @State private var gameMessage = ""
    
    @State private var wallPositions: [CGPoint] = []
    
    @State private var enemyPosition = CGPoint(x: 0, y: 0)
    
    let timer = Timer.publish(every: 0.2, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 20) {
            
            Text("Deadline Dash")
                .font(.largeTitle)
            
            Text("\(scoreEmoji()) Completed Tasks: \(score)")
                .font(.title)
            
            ZStack {
                Rectangle()
                    .fill(Color.black)
                    .frame(width: CGFloat(gridSize) * cellSize,
                           height: CGFloat(gridSize) * cellSize)
                    .border(Color.gray)
                    .position(x: (CGFloat(gridSize) * cellSize) / 2, y: (CGFloat(gridSize) * cellSize) / 2)
                
                ForEach(wallPositions, id: \.self) { pos in
                    Rectangle()
                        .fill(Color.gray)
                        .frame(width: cellSize, height: cellSize)
                        .position(x: pos.x * cellSize + cellSize/2,
                                  y: pos.y * cellSize + cellSize/2)
                }
                
                ForEach(foodPositions, id: \.self) { pos in
                    Text("📗")
                        .frame(width: cellSize, height: cellSize)
                        .position(x: pos.x * cellSize + cellSize/2,
                                  y: pos.y * cellSize + cellSize/2)
                }
                
                Text("\(scoreEmoji())")
                    .font(.largeTitle)
                    .frame(width: cellSize, height: cellSize)
                    .position(x: pacmanPosition.x * cellSize + cellSize/2,
                              y: pacmanPosition.y * cellSize + cellSize/2)
                
                Text("⏰")
                    .font(.title)
                    .frame(width: cellSize, height: cellSize)
                    .position(x: enemyPosition.x * cellSize + cellSize/2,
                              y: enemyPosition.y * cellSize + cellSize/2)

            }
            .frame(width: CGFloat(gridSize) * cellSize, height: CGFloat(gridSize) * cellSize)
            
            Text("Complete all tasks before the deadline!!!")
            
            if(gameStarted) {
                HStack {
                    Button("⬅️") {
                        direction = .left
                    }
                    Button("⬆️") {
                        direction = .up
                    }
                    Button("⬇️") {
                        direction = .down
                    }
                    Button("➡️") {
                        direction = .right
                    }
                }
                .font(.largeTitle)
            } else {
                Button(action: {
                    if(openGame) {
                        openGame = false                        
                    } else {
                        resetGame()
                    }
                    gameStarted = true
                }) {
                    Text("Start")
                        .foregroundColor(.white)
                        .frame(width: 100, height: 40)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.green)
                        )
                }
                if(!openGame) {
                    Text(gameMessage)
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                }
            }
        }
        .onAppear() {
            resetGame()
        }
        .onReceive(timer) { _ in
            if(gameStarted) {
                            movePacman()
                            moveEnemy()
                            checkFoodEaten()
            }
        }
    }
    
    func scoreEmoji() -> String {
        switch score {
        case 0..<5:
            return "😭"
        case 5..<10:
            return "😢"
        case 10..<15:
            return "🙁"
        case 15..<20:
            return "🙂"
        case 20..<25:
            return "😁"
        default:
            return "😆"
        }
    }
    
    func resetGame() {
        enemyPosition = CGPoint(x: 0, y: 0)
        // Set posisi awal pacman di tengah grid
        pacmanPosition = CGPoint(x: CGFloat(gridSize/2), y: CGFloat(gridSize/2))
        direction = .none
        score = 0
        
        wallPositions = []        
        wallPositions = generateRandomWalls(count: 30)
        
        foodPositions = []
        while foodPositions.count < 30 {
            let x = CGFloat(Int.random(in: 0..<gridSize))
            let y = CGFloat(Int.random(in: 0..<gridSize))
            let pos = CGPoint(x: x, y: y)
            if pos != pacmanPosition && !wallPositions.contains(pos) && !foodPositions.contains(pos) {
                foodPositions.append(pos)
            }
        }
    }
    
    func generateRandomWalls(count: Int) -> [CGPoint] {
        var walls: [CGPoint] = []
        
        func neighbors(of point: CGPoint) -> [CGPoint] {
            let deltas = [
                (-1, -1), (0, -1), (1, -1),
                (-1,  0),          (1,  0),
                (-1,  1), (0,  1), (1,  1)
            ]
            return deltas.map { CGPoint(x: point.x + CGFloat($0.0), y: point.y + CGFloat($0.1)) }
                .filter { $0.x >= 0 && $0.x < CGFloat(gridSize) && $0.y >= 0 && $0.y < CGFloat(gridSize) }
        }
        
        func canPlaceWall(at point: CGPoint) -> Bool {
            if walls.contains(point) {
                return false
            }
            let adjacentPoints = neighbors(of: point)
            for adj in adjacentPoints {
                if walls.contains(adj) {
                    return false
                }
            }
            return true
        }
        
        var attempts = 0
        let maxAttempts = 1000
        
        while walls.count < count && attempts < maxAttempts {
            let x = CGFloat(Int.random(in: 0..<gridSize))
            let y = CGFloat(Int.random(in: 0..<gridSize))
            let pos = CGPoint(x: x, y: y)
            
            if pos != pacmanPosition && canPlaceWall(at: pos) {
                walls.append(pos)
            }
            attempts += 1
        }
        
        return walls
    }
    
    
    func movePacman() {
        var newPos = pacmanPosition
        
        switch direction {
        case .up:
            newPos.y -= 1
        case .down:
            newPos.y += 1
        case .left:
            newPos.x -= 1
        case .right:
            newPos.x += 1
        case .none:
            return
        }
        
        if newPos.x < 0 {
            newPos.x = CGFloat(gridSize - 1)
        } else if newPos.x >= CGFloat(gridSize) {
            newPos.x = 0
        }
        
        if newPos.y < 0 {
            newPos.y = CGFloat(gridSize - 1)
        } else if newPos.y >= CGFloat(gridSize) {
            newPos.y = 0
        }
        
        if wallPositions.contains(newPos) {
            return
        }
        
        pacmanPosition = newPos
    }
    
    func moveEnemy() {
        var newPos = enemyPosition
        
        let dx = pacmanPosition.x - enemyPosition.x
        let dy = pacmanPosition.y - enemyPosition.y
        
        if abs(dx) > abs(dy) {
            newPos.x += dx > 0 ? 1 : -1
        } else if dy != 0 {
            newPos.y += dy > 0 ? 1 : -1
        }
        
        if newPos.x < 0 {
            newPos.x = CGFloat(gridSize - 1)
        } else if newPos.x >= CGFloat(gridSize) {
            newPos.x = 0
        }
        if newPos.y < 0 {
            newPos.y = CGFloat(gridSize - 1)
        } else if newPos.y >= CGFloat(gridSize) {
            newPos.y = 0
        }
        
        if wallPositions.contains(newPos) {
            if abs(dx) > abs(dy) && dy != 0 {
                newPos = enemyPosition
                newPos.y += dy > 0 ? 1 : -1
            } else if dx != 0 {
                newPos = enemyPosition
                newPos.x += dx > 0 ? 1 : -1
            }
            
            if newPos.x < 0 { newPos.x = CGFloat(gridSize - 1) }
            if newPos.x >= CGFloat(gridSize) { newPos.x = 0 }
            if newPos.y < 0 { newPos.y = CGFloat(gridSize - 1) }
            if newPos.y >= CGFloat(gridSize) { newPos.y = 0 }
            
            if wallPositions.contains(newPos) {
                newPos = enemyPosition
            }
        }
        
        enemyPosition = newPos
        
        if enemyPosition == pacmanPosition {
            gameOver()
        }
    }
    
    func checkFoodEaten() {
        if let index = foodPositions.firstIndex(where: { $0 == pacmanPosition }) {
            foodPositions.remove(at: index)
            score += 1
        }
        
        if foodPositions.isEmpty {
            gameWon()
        }
    }
    
    func gameOver() {
        gameStarted = false
        let totalTasks = 30
        
        if score < totalTasks / 2 {
            gameMessage = hardRoast.randomElement() ?? "Game Over! Try harder!"
        } else {
            gameMessage = lightRoast.randomElement() ?? "Game Over! Keep pushing!"
        }
    }

    func gameWon() {
        gameStarted = false
        gameMessage = "🎉 You completed all tasks! Congratulations! 🏆"
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
