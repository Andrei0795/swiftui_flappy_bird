//
//  HighScore.swift
//  Flappy Bird Swift UI
//
//  Created by Andrei Ionescu on 24.02.2025.
//

import SwiftData

@Model
class HighScore {
    var score: Int

    init(score: Int = 0) {
        self.score = score
    }
}
