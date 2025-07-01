////
////  AuthView.swift
////  QuickBite
////
////  Created by Rohan Jain on 05/05/25.
////
//
//import SwiftUI
//import Supabase
//
//struct AuthView: View {
//    @State private var isSignUp = false
//    @State private var email = ""
//    @State private var password = ""
//    @State private var confirmPassword = ""
//    @State private var isLoading = false
//    @State private var errorMessage: String?
//    @State private var isSignedIn = false
//
//    var body: some View {
//        if isSignedIn {
//            // Navigate to main screen after authentication
//            MainTabView()
//        } else {
//            NavigationView {
//                VStack(spacing: 20) {
//                    Text(isSignUp ? "Sign Up" : "Sign In")
//                        .font(.largeTitle)
//                        .fontWeight(.bold)
//                        .padding(.top)
//                    
//                    VStack(spacing: 15) {
//                        TextField("Email", text: $email)
//                            .textFieldStyle(RoundedBorderTextFieldStyle())
//                            .keyboardType(.emailAddress)
//                            .autocapitalization(.none)
//                        
//                        SecureField("Password", text: $password)
//                            .textFieldStyle(RoundedBorderTextFieldStyle())
//                        
//                        if isSignUp {
//                            SecureField("Confirm Password", text: $confirmPassword)
//                                .textFieldStyle(RoundedBorderTextFieldStyle())
//                        }
//                    }
//                    .padding(.horizontal)
//                    
//                    if let errorMessage = errorMessage {
//                        Text(errorMessage)
//                            .foregroundColor(.red)
//                            .font(.footnote)
//                    }
//                    
//                    Button(action: { handleAuth() }) {
//                        if isLoading {
//                            ProgressView()
//                                .frame(maxWidth: .infinity)
//                                .padding()
//                        } else {
//                            Text(isSignUp ? "Create Account" : "Sign In")
//                                .foregroundColor(.white)
//                                .frame(maxWidth: .infinity)
//                                .padding()
//                        }
//                    }
//                    .background(Color.green)
//                    .cornerRadius(12)
//                    .padding(.horizontal)
//                    .disabled(isLoading)
//                    
//                    Button(action: {
//                        withAnimation {
//                            isSignUp.toggle()
//                            errorMessage = nil
//                        }
//                    }) {
//                        Text(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
//                            .font(.footnote)
//                            .foregroundColor(.blue)
//                    }
//                    .padding(.top, 10)
//                    
//                    Spacer()
//                }
//                .padding(.top)
//            }
//        }
//    }
//    
//    private func handleAuth() {
//        errorMessage = nil
//        isLoading = true
//
//        if isSignUp {
//            guard password == confirmPassword else {
//                errorMessage = "Passwords do not match."
//                isLoading = false
//                return
//            }
//
//            Task {
//                do {
//                    // Sign up user via Supabase authentication
//                    let signUpResponse = try await SupabaseManager.shared.signUp(email: email, password: password)
//
//                    // Extract user ID after successful sign up
//                    let userID = signUpResponse.user.id
//                    // Insert user into Supabase 'users' table
//                    try await SupabaseManager.shared.insertUser(userID: userID, profileID: nil, settingsID: nil)
//
//                    await MainActor.run {
//                        isSignedIn = true
//                        isLoading = false
//                    }
//                } catch {
//                    await MainActor.run {
//                        errorMessage = error.localizedDescription
//                        isLoading = false
//                    }
//                }
//            }
//        } else {
//            Task {
//                do {
//                    // Sign in user via Supabase authentication
//                    let _ = try await SupabaseManager.shared.signIn(email: email, password: password)
//                    await MainActor.run {
//                        isSignedIn = true
//                        isLoading = false
//                    }
//                } catch {
//                    await MainActor.run {
//                        errorMessage = error.localizedDescription
//                        isLoading = false
//                    }
//                }
//            }
//        }
//    }
//}
//
//#Preview {
//    AuthView()
//}


//
//  AuthView.swift
//  QuickBite
//
//  Created by Rohan Jain on 05/05/25.
//

import SwiftUI
import Supabase

struct AuthView: View {
    @State private var isSignUp = false
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var isSignedIn = false

    var body: some View {
        if isSignedIn {
            // Navigate to main screen after authentication
            MainTabView()
        } else {
            NavigationView {
                VStack(spacing: 20) {
                    Text(isSignUp ? "Sign Up" : "Sign In")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top)
                    
                    VStack(spacing: 15) {
                        TextField("Email", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        
                        SecureField("Password", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        if isSignUp {
                            SecureField("Confirm Password", text: $confirmPassword)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }
                    .padding(.horizontal)
                    
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.footnote)
                    }
                    
                    Button(action: handleAuth) {
                        if isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else {
                            Text(isSignUp ? "Create Account" : "Sign In")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                    }
                    .background(Color.green)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .disabled(isLoading)
                    
                    Button(action: {
                        withAnimation {
                            isSignUp.toggle()
                            errorMessage = nil
                        }
                    }) {
                        Text(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                            .font(.footnote)
                            .foregroundColor(.blue)
                    }
                    .padding(.top, 10)
                    
                    Spacer()
                }
                .padding(.top)
            }
        }
    }
    
    private func handleAuth() {
        errorMessage = nil
        isLoading = true

        if isSignUp {
            guard password == confirmPassword else {
                errorMessage = "Passwords do not match."
                isLoading = false
                return
            }

            Task {
                do {
                    // 1. Sign up with Supabase
                    let signUpResponse = try await SupabaseManager.shared.signUp(
                        email: email,
                        password: password
                    )

                    // 2. Get the new user's UUID
                    let userID = signUpResponse.user.id

                    // 3. Insert into your "users" table (minimal fields)
                    try await SupabaseManager.shared.insertUser(
                        id: userID,
                        email: email,
                        profileId: nil,
                        settingsId: nil
                    )

                    // 4. Update UI on success
                    await MainActor.run {
                        isSignedIn = true
                        isLoading = false
                    }
                } catch {
                    // 5. Handle errors
                    await MainActor.run {
                        errorMessage = error.localizedDescription
                        isLoading = false
                    }
                }
            }
        } else {
            Task {
                do {
                    // Sign in with Supabase
                    _ = try await SupabaseManager.shared.signIn(
                        email: email,
                        password: password
                    )
                    await MainActor.run {
                        isSignedIn = true
                        isLoading = false
                    }
                } catch {
                    await MainActor.run {
                        errorMessage = error.localizedDescription
                        isLoading = false
                    }
                }
            }
        }
    }
}

#Preview {
    AuthView()
}
