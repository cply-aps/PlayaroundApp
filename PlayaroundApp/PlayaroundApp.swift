//
//  PlayaroundApp.swift
//  PlayaroundApp
//
//  Created by Casper Lykke Andersen on 19/11/2024.
//

import SwiftUI
import SwiftData

@main
struct PlayaroundApp: App {
    let container: ModelContainer
       
       init() {
           do {
               container = try ModelContainer(
                   for: User.self, Entry.self,
                   configurations: ModelConfiguration(isStoredInMemoryOnly: false)
               )
           } catch {
               fatalError("Failed to initialize ModelContainer")
           }
       }
       
       var body: some Scene {
           WindowGroup {
               ContentView(modelContext: container.mainContext)
           }
           .modelContainer(container)
       }
}
