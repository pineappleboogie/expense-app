//
//  MyFirstAppApp.swift
//  MyFirstApp
//
//  Created by Jian Hong Chen on 23/9/25.
//

import SwiftUI
import SwiftData

@main
struct MyFirstAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    // Set to true to load dummy data for testing
    #if DEBUG
    private static let useDummyData = true
    #else
    private static let useDummyData = false
    #endif

    let sharedModelContainer: ModelContainer

    init() {
        let schema = Schema([
            CreditCard.self,
            Expense.self,
            CategoryCap.self
        ])

        if Self.useDummyData {
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            do {
                let container = try ModelContainer(for: schema, configurations: [config])
                PreviewData.insertSampleData(into: container.mainContext)
                sharedModelContainer = container
            } catch {
                fatalError("Could not create ModelContainer with dummy data: \(error)")
            }
        } else {
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false
            )

            do {
                sharedModelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            } catch {
                fatalError("Could not create ModelContainer: \(error)")
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
