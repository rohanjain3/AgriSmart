//
//  SupabaseManager.swift
//  QuickBite
//
//  Created by Rohan Jain on 05/05/25.
//

//import Supabase
//import Foundation
//
//class SupabaseManager {
//    static let shared = SupabaseManager()
//    
//    let client: SupabaseClient
//    
//    private init() {
//        client = SupabaseClient(
//            supabaseURL: URL(string: "https://jklvimetkzltafgccroy.supabase.co")!,
//            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImprbHZpbWV0a3psdGFmZ2Njcm95Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY2Nzc5MDIsImV4cCI6MjA2MjI1MzkwMn0.U8LH9xnzWXLJcPotaNNxb1i6ezzSr2nEDAzAqqhNP7E"
//        )
//    }
//}

//import UIKit
//import Foundation
//import Supabase
//
//class SupabaseManager {
//    static let shared = SupabaseManager()
//    
//    private let client: SupabaseClient
//    
//    private init() {
//        // Initialize Supabase client with your project URL and public anon key
//        // Replace with your actual Supabase project URL and anon key
//        let supabaseUrl = URL(string: "https://jklvimetkzltafgccroy.supabase.co")!
//        let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImprbHZpbWV0a3psdGFmZ2Njcm95Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY2Nzc5MDIsImV4cCI6MjA2MjI1MzkwMn0.U8LH9xnzWXLJcPotaNNxb1i6ezzSr2nEDAzAqqhNP7E"
//        self.client = SupabaseClient(supabaseURL: supabaseUrl, supabaseKey: supabaseKey)
//    }
//    
//    // Fetch all products from Supabase
//    func fetchProducts() async throws -> [Product] {
//        do {
//            let response = try await client
//                .from("products")
//                .select()
//                .execute()
//            
//            let products = try JSONDecoder().decode([Product].self, from: response.data)
//            print("Fetched \(products.count) products from Supabase")
//            return products
//        } catch {
//            print("Error fetching products: \(error.localizedDescription)")
//            throw error
//        }
//    }
//    
//    // Upload product to Supabase
//    func uploadProduct(_ product: Product) async throws {
//        do {
//            let response = try await client
//                .from("products")
//                .insert(product)
//                .execute()
//            
//            print("Product uploaded to Supabase: \(response)")
//        } catch {
//            print("Error uploading product: \(error.localizedDescription)")
//            throw error
//        }
//    }
//    
//    // Upload image to Supabase storage and return public URL
//    func uploadImage(_ image: UIImage, name: String) async throws -> String {
//        guard let data = image.jpegData(compressionQuality: 0.8) else {
//            let error = NSError(domain: "SupabaseManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to JPEG"])
//            print("Error: \(error.localizedDescription)")
//            throw error
//        }
//        
//        let filePath = "\(name).jpg"
//        do {
//            let response = try await client
//                .storage
//                .from("crop")
//                .upload(
//                    path: filePath,
//                    file: data,
//                    options: FileOptions(contentType: "image/jpeg")
//                )
//            
//            let publicURL = try await client.storage
//                .from("crop")
//                .getPublicURL(path: filePath)
//            print("Image uploaded to Supabase at URL: \(publicURL.absoluteString)")
//            return publicURL.absoluteString
//        } catch {
//            print("Error uploading image: \(error.localizedDescription)")
//            throw error
//        }
//    }
//    
//    // Fetch current user session
//    func fetchUserSession() async throws -> Session {
//        do {
//            let session = try await client.auth.session
//            print("Fetched user session for user ID: \(session.user.id)")
//            return session
//        } catch {
//            print("Error fetching user session: \(error.localizedDescription)")
//            throw error
//        }
//    }
//    
//    // Sign out the current user
//    func signOut() async throws {
//        do {
//            try await client.auth.signOut()
//            print("User signed out successfully")
//        } catch {
//            print("Error signing out: \(error.localizedDescription)")
//            throw error
//        }
//    }
//    
//    // Sign up a new user
//    func signUp(email: String, password: String) async throws -> Session {
//        do {
//            let response = try await client.auth.signUp(email: email, password: password)
//            print("User signed up with email: \(email)")
//            return response.session!
//        } catch {
//            print("Error signing up: \(error.localizedDescription)")
//            throw error
//        }
//    }
//    
//    // Sign in an existing user
//    func signIn(email: String, password: String) async throws -> Session {
//        do {
//            let session = try await client.auth.signIn(email: email, password: password)
//            print("User signed in with email: \(email)")
//            return session
//        } catch {
//            print("Error signing in: \(error.localizedDescription)")
//            throw error
//        }
//    }
//    
//    // Struct for user data to ensure Encodable compliance
//    struct UserData: Encodable {
//        let id: UUID
//        let profile_id: UUID?
//        let settings_id: UUID?
//    }
//    
//    // Insert user into the users table
//    func insertUser(userID: UUID, profileID: UUID?, settingsID: UUID?) async throws {
//        do {
//            let userData = UserData(id: userID, profile_id: profileID, settings_id: settingsID)
//            let response = try await client
//                .from("users")
//                .insert(userData)
//                .execute()
//            
//            print("User inserted into users table: \(response)")
//        } catch {
//            print("Error inserting user: \(error.localizedDescription)")
//            throw error
//        }
//    }
//}

import UIKit
import Foundation
import Supabase

class SupabaseManager {
    static let shared = SupabaseManager()
    
    let client: SupabaseClient
    
    private init() {
        let supabaseUrl = URL(string: "https://jklvimetkzltafgccroy.supabase.co")!
        let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImprbHZpbWV0a3psdGFmZ2Njcm95Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY2Nzc5MDIsImV4cCI6MjA2MjI1MzkwMn0.U8LH9xnzWXLJcPotaNNxb1i6ezzSr2nEDAzAqqhNP7E"
        self.client = SupabaseClient(supabaseURL: supabaseUrl, supabaseKey: supabaseKey)
    }
    
    // MARK: - Auth
    
    func signUp(email: String, password: String) async throws -> Session {
        let response = try await client.auth.signUp(email: email, password: password)
        
        // `response.user` is non-optional in your client
        let user = response.user
        
        // Insert minimal user record
        try await insertUser(
            id: user.id,
            email: email,
            profileId: nil,
            settingsId: nil
        )
        
        guard let session = response.session else {
            throw AuthError.signUpRequiresEmailVerification(
                message: "Please verify your email to complete sign-up."
            )
        }
        
        return session
    }
    
    func signIn(email: String, password: String) async throws -> Session {
        let session = try await client.auth.signIn(email: email, password: password)
        return session
    }
    
    func signOut() async throws {
        try await client.auth.signOut()
    }
    
    func fetchUserSession() async throws -> Session {
        let session = try await client.auth.session
        return session
    }
    
    // MARK: - User Table
    
    struct UserData: Encodable {
        let id: UUID
        let email: String
        let profile_id: UUID?
        let settings_id: UUID?
        
        enum CodingKeys: String, CodingKey {
            case id
            case email
            case profile_id
            case settings_id
        }
    }
    
    /// Inserts only the minimal fields into your `users` table.
    func insertUser(
        id: UUID,
        email: String,
        profileId: UUID?,
        settingsId: UUID?
    ) async throws {
        let userData = UserData(
            id: id,
            email: email,
            profile_id: profileId,
            settings_id: settingsId
        )
        _ = try await client
            .from("users")
            .insert(userData)
            .execute()
    }
    
    // Existing fetchUser function
        func fetchUser(by id: UUID) async throws -> User {
            let response = try await client
                .database
                .from("users") // Ensure this matches your Supabase table name for users
                .select()
                .eq("id", value: id.uuidString)
                .single() // Expecting a single user
                .execute()
                
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601 // Crucial for decoding Date properties
            
            // If your database columns are snake_case (e.g., "profile_image_url"),
            // add this strategy to automatically convert them to camelCase in your Swift struct.
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            let user = try decoder.decode(User.self, from: response.data)
            return user
        }
    
    // MARK: - Products
    
    func fetchProducts(farmerId: UUID? = nil) async throws -> [Product] {
          var query = client
              .from("products")
              .select()

          // Apply the filter if farmerId is provided
          if let id = farmerId {
              query = query.eq("farmerId", value: id.uuidString)
          }
          
          // Add ordering if you want (e.g., by name or creation date)
        query = query.order("name", ascending: true) as! PostgrestFilterBuilder // Example: order by name

          let response = try await query.execute()
          return try JSONDecoder().decode([Product].self, from: response.data)
      }
    
    func uploadProduct(_ product: Product) async throws {
        _ = try await client
            .from("products")
            .insert(product)
            .execute()
    }
    
    func deleteProduct(id: UUID) async throws {
        _ = try await client
            .from("products")
            .delete()
            .eq("id", value: id.uuidString)
            .execute()
    }
    
    // MARK: - Storage
    
    func uploadImage(_ image: UIImage, name: String) async throws -> String {
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(
                domain: "SupabaseManager",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to JPEG"]
            )
        }
        
        let filePath = "\(name).jpg"
        _ = try await client
            .storage
            .from("crop")
            .upload(filePath, data: data, options: FileOptions(contentType: "image/jpeg"))
        
        let publicURL = try await client.storage
            .from("crop")
            .getPublicURL(path: filePath)
        return publicURL.absoluteString
    }
    
    // MARK: - Errors
    
    enum AuthError: LocalizedError {
        case signUpRequiresEmailVerification(message: String)
        
        var errorDescription: String? {
            switch self {
            case .signUpRequiresEmailVerification(let message):
                return message
            }
        }
    }
}

