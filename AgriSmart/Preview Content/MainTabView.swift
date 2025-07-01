//
//  MainTabView.swift
//  Agrismart
//
//  Created by Rohan Jain on 08/05/25.
//

import SwiftUICore
import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Explore Tab
            ExploreView()
                .tabItem {
                    
                    Label("Home", systemImage: "house")
                }
                .tag(0)
            // Home Tab
            NavigationView {
                AddToCartView()
            }
            .tabItem {
                Label("Explore", systemImage: "magnifyingglass")
            }
            .tag(1)
            
            
            // Farmers Tab
            OrderHistoryView()
                .tabItem {
                    Label("History", systemImage: "list.bullet")
                }
                .tag(2)

            
            // Chat Tab
            
            MainCropView()
                .tabItem {
                    Label("Add", systemImage: "square.and.arrow.up")
                }
                .tag(3)
            
            // Settings Tab
            ConsumerSettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(4)
        }
    }
}
#Preview {
    MainTabView()
}
