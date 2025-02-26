//
//  Flappy_Bird_Swift_UIApp.swift
//  Flappy Bird Swift UI
//
//  Created by Andrei Ionescu on 24.02.2025.
//

import SwiftUI
import SwiftData

@main
struct Flappy_Bird_Swift_UIApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            HighScore.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
