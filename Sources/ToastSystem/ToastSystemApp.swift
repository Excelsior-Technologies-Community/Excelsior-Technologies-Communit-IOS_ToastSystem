//
//  ToastSystemApp.swift
//  ToastSystem
//
//  Created by Noman Belim on 04/12/25.
//

import SwiftUI
 
@main
struct ToastSystemApp: App {
    @StateObject var toast = ToastManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(toast)
                .overlay(
                    ToastView()
                        .environmentObject(toast)
                        .ignoresSafeArea()
                )
        }
    }
}
