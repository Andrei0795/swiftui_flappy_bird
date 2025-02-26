//
//  GameView.swift
//  Flappy Bird Swift UI
//
//  Created by Andrei Ionescu on 24.02.2025.
//

import SwiftUI

struct GameView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var game: GameViewModel
    var onExit: () -> Void  // Callback when exiting the game

    var body: some View {
        ZStack {
            Color.blue.edgesIgnoringSafeArea(.all)

            // Bird
            FlappyBirdView()
                .position(x: 100, y: game.birdPosition)
                .animation(.easeInOut(duration: 0.2), value: game.birdPosition)

            // Pipes
            ForEach(game.pipes, id: \.x) { pipe in
                PipeView(pipe: pipe)
                    .transition(.move(edge: .trailing))
                    .animation(.linear(duration: 1), value: game.pipes)
            }

            // Score
            Text("Score: \(game.score)")
                .font(.largeTitle)
                .foregroundColor(.white)
                .position(x: UIScreen.main.bounds.width / 2, y: 50)
                .animation(.easeInOut(duration: 0.3), value: game.score)
            
            if game.isGameOver {
                ZStack {
                    Color.black.opacity(0.5)
                                .edgesIgnoringSafeArea(.all)
                                .transition(.opacity)
                                .animation(.easeInOut(duration: 0.5))
                    VStack {
                        Text("Game Over")
                            .font(.title)
                            .bold()
                            .foregroundColor(.red)
                            .opacity(game.isGameOver ? 1 : 0)  // ✅ Smooth fade-in
                            .animation(.easeOut(duration: 0.5))
                        
                        Text("Tap to Restart")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
                    .transition(.opacity)
                }
            }

            // Countdown Display (only on first load)
            if let countdown = game.countdown {
                Text(countdown == 0 ? "Go!" : "\(countdown)")
                    .font(.system(size: 80, weight: .bold))
                    .foregroundColor(.white)
                    .transition(.scale)
                    .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
            }

            // Exit Button (X)
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        onExit()  // Call onExit when exiting
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                Spacer()
            }
        }
        .onTapGesture {
            if game.birdCanFly {
                game.jump()
            }
        }.onAppear() {
            game.resetGame(firstTime: true)
        }
        .navigationBarHidden(true)
    }
}
