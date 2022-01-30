//
//  TaskForceApp.swift
//  TaskForce
//
//  Created by Igor Kokoev on 30.01.2022.
//

import SwiftUI

@main
struct TaskForceApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
