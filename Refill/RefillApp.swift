//
//  RefillApp.swift
//  Refill
//
//  Created by Karuturi Siva Rama Krishna on 17/06/25.
//

import SwiftUI

@main
struct RefillApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            DashboardView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

