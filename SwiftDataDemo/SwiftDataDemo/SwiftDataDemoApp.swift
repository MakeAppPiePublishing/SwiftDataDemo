//
//  SwiftDataDemoApp.swift
//  SwiftDataDemo
//
//  Created by Steven Lipton on 6/14/23.
//

import SwiftUI
import SwiftData

@main
struct SwiftDataDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: UserPref.self)
    }
}
