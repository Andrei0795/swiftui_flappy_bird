//
//  Untitled.swift
//  Flappy Bird Swift UI
//
//  Created by Andrei Ionescu on 24.02.2025.
//

import SwiftUI
import Combine
import SwiftData

class GameViewModel: ObservableObject {
    @Published var birdPosition: CGFloat = 300
    @Published var velocity: CGFloat = 0
    @Published var pipes: [Pipe] = []
    @Published var score: Int = 0
    @Published var isGameOver = false
    @Published var birdCanFly = false
    @Published var hasStarted = false  // Track if the game has started
    @Published var countdown: Int? = nil  // No countdown on resets
    
    private var modelContext: ModelContext
    private var firstTime = true  // Track if it's the first time
    
    private var timer: Timer?
    private let gravity: CGFloat = 0.8
    private let jumpStrength: CGFloat = -12.0
    private let pipeSpeed: CGFloat = 3.0
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func resetGame(firstTime: Bool = false) {
        birdPosition = UIScreen.main.bounds.height / 2
        velocity = 0
        pipes.removeAll()
        score = 0
        isGameOver = false
        hasStarted = false
        
        lastGapY = 300
        lastPipeX = UIScreen.main.bounds.width + 200  // Ensure pipes start far away after reset
        
        if firstTime {
            self.firstTime = false
            startCountdown()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.startGame()
            }
        }
    }
    
    func startCountdown() {
        countdown = 3
        var timeLeft = 3
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            self.countdown = timeLeft
            timeLeft -= 1
            
            if timeLeft < 0 {
                timer.invalidate()
                self.countdown = nil  // Hide countdown text
                self.startGame()
                self.birdCanFly = true
            }
        }
    }
    
    func startGame() {
        hasStarted = true
        isGameOver = false
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.025, repeats: true) { _ in
            self.updateGame()
        }
        
        pipes.removeAll()
        lastPipeX = UIScreen.main.bounds.width
        spawnPipes()
    }
    
    func updateGame() {
        guard hasStarted, !isGameOver else { return }
        
        withAnimation(.easeInOut(duration: 0.025)) {
            velocity += gravity
            birdPosition += velocity
        }
        
        for index in pipes.indices {
            pipes[index].x -= pipeSpeed
            
            // Check if the bird successfully passed a pipe and update score
            if pipes[index].x + pipes[index].width < 100, !pipes[index].hasScored {
                pipes[index].hasScored = true
                score += 1
            }
        }
        
        checkCollisions()
        removeOffscreenPipes()
    }
    
    func jump() {
        if isGameOver {
            resetGame()
        } else if !hasStarted {
            startGame()
            velocity = jumpStrength  // First jump starts game
        } else {
            velocity = jumpStrength
        }
    }
    
    var lastGapY: CGFloat = 300  // Track last pipe's Y position
    var lastPipeX: CGFloat = 0   // Track last pipe's X position
    
    func spawnPipes() {
        Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
            guard self.hasStarted, !self.isGameOver else { return }
            
            let screenWidth = UIScreen.main.bounds.width
            let screenHeight = UIScreen.main.bounds.height
            let gapHeight: CGFloat = 220
            let minGapY: CGFloat = gapHeight
            let maxGapY: CGFloat = screenHeight - gapHeight
            let maxGapShift: CGFloat = 100
            let minGapSpacingY: CGFloat = 180
            let minPipeSpacingX: CGFloat = 200  // ✅ Increased spacing for fairness
            
            var newGapY = self.lastGapY + CGFloat.random(in: -maxGapShift...maxGapShift)
            
            // Ensure gap is always spaced properly from last one
            if abs(newGapY - self.lastGapY) < minGapSpacingY {
                newGapY = self.lastGapY + (newGapY > self.lastGapY ? minGapSpacingY : -minGapSpacingY)
            }
            
            newGapY = max(minGapY + gapHeight / 2, min(newGapY, maxGapY - gapHeight / 2))
            
            self.lastGapY = newGapY
            
            // Ensure horizontal spacing is always correct after reset
            let newPipeX = max(self.lastPipeX + minPipeSpacingX, screenWidth + 200)  // ✅ Forces proper spacing
            self.lastPipeX = newPipeX
            
            let newPipe = Pipe(x: newPipeX, gapPosition: newGapY, gapHeight: gapHeight)
            
            DispatchQueue.main.async {
                withAnimation {
                    self.pipes.append(newPipe)
                }
            }
        }
    }
    
    func checkCollisions() {
        guard !isGameOver else { return }
        
        let birdX: CGFloat = 100  // Bird's fixed X position
        let birdSize: CGFloat = 40  // Bird's size
        
        for pipe in pipes {
            if pipe.isColliding(with: birdX, birdY: birdPosition, birdSize: birdSize) {
                gameOver(modelContext: modelContext)
                return  // ✅ Stop checking once collision is detected
            }
        }
        
        // ✅ If bird falls below the screen, trigger game over
        if birdPosition > UIScreen.main.bounds.height {
            gameOver(modelContext: modelContext)
        }
    }
    
    func removeOffscreenPipes() {
        pipes.removeAll { $0.x < -100 }  // Increased threshold to remove pipes earlier
    }
    
    func gameOver(modelContext: ModelContext) {
        guard !isGameOver else { return }
        
        isGameOver = true
        timer?.invalidate()
        
        let request = FetchDescriptor<HighScore>()
        
        do {
            if let highScore = try modelContext.fetch(request).first {
                if score > highScore.score {
                    highScore.score = score  // Update high score
                    try modelContext.save()  // Ensure the change is saved
                    print("High Score Updated: \(highScore.score)")
                }
            } else {
                print("No high score found, creating a new one.")
                let newHighScore = HighScore(score: score)
                modelContext.insert(newHighScore)  // Insert into SwiftData
                try modelContext.save()  // Save the new high score
                print("New High Score Created: \(newHighScore.score)")
            }
        } catch {
            print("Error saving high score: \(error.localizedDescription)")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.velocity = 0
        }
    }
}

struct Pipe: Equatable {
    var x: CGFloat
    var gapPosition: CGFloat
    var gapHeight: CGFloat
    let width: CGFloat = 50
    var hasScored: Bool = false

    func isColliding(with birdX: CGFloat, birdY: CGFloat, birdSize: CGFloat) -> Bool {
        let birdLeft = birdX - birdSize / 2
        let birdRight = birdX + birdSize / 2
        let birdTop = birdY - birdSize / 2
        let birdBottom = birdY + birdSize / 2

        let pipeLeft = x
        let pipeRight = x + width

        // Correct horizontal collision check
        let horizontalCollision = birdRight + 10 > pipeLeft && birdLeft < pipeRight

        // Define gap area correctly
        let gapTop = gapPosition - (gapHeight / 2)
        let gapBottom = gapPosition + (gapHeight / 2)

        // Only check vertical collision **if** bird is inside the pipe's X range
        if horizontalCollision {
            let verticalCollision = birdTop + birdSize * 1.5 < gapTop || birdBottom + birdSize / 1.5 > gapBottom - 5  // ✅ Added small buffer
            if verticalCollision {
                return true
            }
            return false  // Only return true if both horizontal & vertical collision occur
        }

        return false  // If bird has moved past, ignore collision
    }
}
