//
//  FlappyBirdView.swift
//  Flappy Bird Swift UI
//
//  Created by Andrei Ionescu on 24.02.2025.
//
import SwiftUI

struct FlappyBirdView: View {
    var body: some View {
        Image(systemName: "bird.fill")
            .resizable()
            .frame(width: 40, height: 40)
            .foregroundColor(.yellow)
    }
}
