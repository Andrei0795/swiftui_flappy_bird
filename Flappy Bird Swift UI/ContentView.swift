//
//  ContentView.swift
//  Flappy Bird Swift UI
//
//  Created by Andrei Ionescu on 24.02.2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var highScores: [HighScore]
    @State private var highScore: Int = 0

    var body: some View {
        NavigationStack {
            ZStack {
                Color.blue.edgesIgnoringSafeArea(.all)

                VStack(spacing: 40) {
                    Text("Flappy Bird")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.white)

                    NavigationLink(destination: GameView(game: GameViewModel(modelContext: modelContext), onExit: {
                        fetchHighScore()
                    })) {
                        Text("Play")
                            .font(.title)
                            .bold()
                            .frame(width: 150, height: 50)
                            .background(Color.white)
                            .foregroundColor(.blue)
                            .cornerRadius(10)
                    }

                    Text("High Score: \(highScore)")
                        .font(.title2)
                        .foregroundColor(.white)

                    VStack(alignment: .center, spacing: 10) {
                        Text("About")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.white)

                        Text("This is a Flappy Bird clone built with SwiftUI and SwiftData. Tap to make the bird jump, avoid the pipes, and try to get the highest score possible!")
                            .font(.body)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }

                    Spacer()
                }
                .padding(.top, 60)
            }
        }
        .onAppear {
            fetchHighScore()
        }
    }

    // Fetch the latest high score
    private func fetchHighScore() {
        let request = FetchDescriptor<HighScore>()

        do {
            let highScoreEntry = try modelContext.fetch(request)
            
            if let firstEntry = highScoreEntry.first {
                highScore = firstEntry.score
                print("High Score Loaded: \(highScore)")
            } else {
                highScore = 0
                print("No High Score Found, Setting to 0")
            }
        } catch {
            print("Error fetching high score: \(error.localizedDescription)")
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: HighScore.self, inMemory: true)
}
