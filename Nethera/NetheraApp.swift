//
//  NetheraApp.swift
//  Nethera
//
//  Created by Nico Hofer on 08.03.26.
//

import SwiftUI
import UIKit

@main
struct NetheraApp: App {
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        appearance.backgroundColor = UIColor(red: 0.01, green: 0.03, blue: 0.05, alpha: 0.72)
        appearance.shadowColor = .clear

        let normalColor = UIColor.white.withAlphaComponent(0.55)
        let selectedColor = UIColor(red: 0.35, green: 0.75, blue: 0.90, alpha: 1)
        for itemAppearance in [appearance.stackedLayoutAppearance, appearance.inlineLayoutAppearance, appearance.compactInlineLayoutAppearance] {
            itemAppearance.normal.iconColor = normalColor
            itemAppearance.normal.titleTextAttributes = [.foregroundColor: normalColor]
            itemAppearance.selected.iconColor = selectedColor
            itemAppearance.selected.titleTextAttributes = [.foregroundColor: selectedColor]
        }

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().isTranslucent = true
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    NetheraBackend.refreshFromMongoDB()
                    NetheraWidgetDataStore.syncSnapshot()
                    NotificationManager.shared.startAutomaticMonitoring()
                }
        }
    }
}
