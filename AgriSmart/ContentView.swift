import SwiftUI

struct ContentView: View {
    @State private var isLoggedIn = false  // ← controls whether to show MainTabView or WelcomeView

    var body: some View {
        if isLoggedIn {
            MainTabView()
        } else {
            WelcomeView()
        }
    }
}

#Preview {
    ContentView()
}

