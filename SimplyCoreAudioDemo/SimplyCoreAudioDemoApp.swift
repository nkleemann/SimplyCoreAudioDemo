//
//  SimplyCoreAudioDemoApp.swift
//  SimplyCoreAudioDemo
//
//  Created by Ruben Nine on 27/3/21.
//

import SwiftUI

@main
struct SimplyCoreAudioDemoApp: App {
    private let sca = ObservableSCA()
    private let monitor = AudioMonitorManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 650, idealWidth: 650, minHeight: 300, idealHeight: 300)
                .environmentObject(sca)
                .environmentObject(monitor)
        }
        .commands {
            SidebarCommands()
        }
    }
}
