//
//  WelcomeView.swift
//  Agrismart
//
//  Created by Rohan Jain on 08/05/25.
//

import SwiftUI

struct WelcomeView: View {
    @State private var showAuthView = false  // To trigger full-screen cover
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.green.opacity(0.8), Color("AccentColor  1")]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 30) {
                // App Icon / Emoji
                Text("🌾🚜🐄")
                    .font(.system(size: 80))

                // Title
                Text("Welcome to AgriSmart")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)

                // Subtitle
                Text("Connecting farmers and buyers directly")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)

                Spacer().frame(height: 50)

                // Sign In Button
                Button(action: {
                    showAuthView = true
                }) {
                    Text("Sign In")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(Color.green)
                        .cornerRadius(12)
                        .shadow(radius: 4)
                }

                Spacer()
            }
            .padding()
        }
        .fullScreenCover(isPresented: $showAuthView) {
            AuthView() // ✅ THIS is your existing AuthView
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
