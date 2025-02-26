//
//  PipeView.swift
//  Flappy Bird Swift UI
//
//  Created by Andrei Ionescu on 24.02.2025.
//

import SwiftUI

struct PipeView: View {
    var pipe: Pipe

    var body: some View {
        ZStack {
            // Upper Pipe
            Rectangle()
                .frame(width: pipe.width, height: pipe.gapPosition - pipe.gapHeight / 2 + 50) // Extend pipe into safe area
                .foregroundColor(.green)
                .position(x: pipe.x, y: (pipe.gapPosition - pipe.gapHeight / 2) / 2 - 25) // Shift up slightly

            // Lower Pipe
            Rectangle()
                .frame(width: pipe.width, height: UIScreen.main.bounds.height - (pipe.gapPosition + pipe.gapHeight / 2))
                .foregroundColor(.green)
                .position(
                    x: pipe.x,
                    y: (UIScreen.main.bounds.height + pipe.gapPosition + pipe.gapHeight / 2) / 2
                )

        }
        .edgesIgnoringSafeArea(.all) // Ignore safe area so pipes go to the top
    }
}
