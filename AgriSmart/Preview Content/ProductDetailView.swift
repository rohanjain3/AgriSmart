//// ProductDetailView.swift
//// Agrismart
//// Created on May 23, 2025.
//
//import SwiftUI
//import Kingfisher
//import Supabase
//
//struct ProductDetailView: View {
//    let product: Product
//    let farmer: User? // Farmer passed from ExploreView
//    @StateObject private var cartManager = CartManager.shared
//    @State private var quantity: Int = 20
//    @State private var pincodeText: String = ""
//    @State private var isDeliveryAvailable: Bool? = nil
//    @State private var showAlert: Bool = false
//    @State private var alertMessage: String = ""
//    @State private var errorMessage: String?
//    @State private var isAddedToCart: Bool = false
//
//    // Sample pincodes for delivery check (replace with backend logic if available)
//    private let availablePincodes = ["560001", "110002", "400002", "700001", "500001"]
//
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 16) {
//                // Product Image Carousel
//                if !product.imageUrls.isEmpty {
//                    ScrollView(.horizontal, showsIndicators: false) {
//                        HStack(spacing: 8) {
//                            ForEach(product.imageUrls, id: \.self) { url in
//                                KFImage(URL(string: url))
//                                    .resizable()
//                                    .scaledToFit()
//                                    .frame(maxWidth: .infinity, maxHeight: 250)
//                                    .cornerRadius(8)
//                                    .padding(.horizontal, 4)
//                            }
//                        }
//                        .padding(.horizontal)
//                    }
//                } else {
//                    Rectangle()
//                        .fill(Color.gray.opacity(0.3))
//                        .frame(maxWidth: .infinity, maxHeight: 250)
//                        .cornerRadius(8)
//                        .padding()
//                }
//
//                // Product Info Section
//                VStack(alignment: .leading, spacing: 8) {
//                    Text(product.name)
//                        .font(.title)
//                        .fontWeight(.bold)
//                        .padding(.horizontal)
//
//                    HStack {
//                        if let rating = product.rating {
//                            Text(String(format: "%.1f", rating))
//                                .fontWeight(.medium)
//                            Image(systemName: "star.fill")
//                                .foregroundColor(.yellow)
//                        }
//                        Text("(\(product.reviewsCount) Reviews)")
//                            .foregroundColor(.gray)
//                    }
//                    .padding(.horizontal)
//
//                    Text(product.formattedPrice)
//                        .font(.title2)
//                        .fontWeight(.bold)
//                        .padding(.horizontal)
//
//                    Text("Category: \(product.category.rawValue.capitalized)")
//                        .font(.subheadline)
//                        .foregroundColor(.secondary)
//                        .padding(.horizontal)
//                }
//
//                // Quantity Selection Section
//                VStack(alignment: .leading, spacing: 8) {
//                    Text("Quantity")
//                        .font(.headline)
//                        .padding(.horizontal)
//
//                    HStack {
//                        Button {
//                            if quantity > 20 {
//                                quantity -= 1
//                            }
//                        } label: {
//                            Image(systemName: "minus")
//                                .frame(width: 44, height: 44)
//                                .background(Color.gray.opacity(0.1))
//                                .cornerRadius(8)
//                        }
//
//                        Text("\(quantity) kg")
//                            .font(.headline)
//                            .frame(minWidth: 60, alignment: .center)
//
//                        Button {
//                            if Double(quantity) < product.quantityAvailable {
//                                quantity += 1
//                            }
//                        } label: {
//                            Image(systemName: "plus")
//                                .frame(width: 44, height: 44)
//                                .background(Color.gray.opacity(0.1))
//                                .cornerRadius(8)
//                        }
//                    }
//                    .padding(.horizontal)
//                }
//
//                // Add to Cart Button
//                Button {
//                    Task {
//                        if quantity >= 20 {
//                            await cartManager.addProduct(product, quantity: quantity)
//                            await MainActor.run {
//                                isAddedToCart = true
//                                alertMessage = "\(product.name) added to cart."
//                                showAlert = true
//                            }
//                        } else {
//                            await MainActor.run {
//                                alertMessage = "Minimum order quantity is 20 kg."
//                                showAlert = true
//                            }
//                        }
//                    }
//                } label: {
//                    HStack {
//                        Image(systemName: isAddedToCart ? "cart.fill" : "cart")
//                        Text(isAddedToCart ? "Added to Cart" : "Add to Cart")
//                            .fontWeight(.bold)
//                    }
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                    .background(isAddedToCart ? Color.gray : Color.blue)
//                    .foregroundColor(.white)
//                    .cornerRadius(12)
//                }
//                .padding(.horizontal)
//
//                // Delivery Availability Section
//                VStack(alignment: .leading, spacing: 8) {
//                    Text("Delivery Availability")
//                        .font(.headline)
//                        .padding(.horizontal)
//
//                    HStack {
//                        TextField("Enter Pincode", text: $pincodeText)
//                            .keyboardType(.numberPad)
//                            .padding()
//                            .background(Color.gray.opacity(0.1))
//                            .cornerRadius(8)
//
//                        Button {
//                            checkDeliveryAvailability()
//                        } label: {
//                            Text("Check")
//                                .padding()
//                                .background(Color.blue.opacity(0.1))
//                                .cornerRadius(8)
//                        }
//                    }
//                    .padding(.horizontal)
//
//                    if let isAvailable = isDeliveryAvailable {
//                        Text(isAvailable ? "Delivery available!" : "Sorry, delivery not available.")
//                            .foregroundColor(isAvailable ? .green : .red)
//                            .font(.subheadline)
//                            .padding(.horizontal)
//                    }
//                }
//
//                // Description Section
//                VStack(alignment: .leading, spacing: 8) {
//                    Text("Description")
//                        .font(.headline)
//                        .padding(.horizontal)
//                    Text(product.description)
//                        .font(.body)
//                        .foregroundColor(.secondary)
//                        .padding(.horizontal)
//                }
//
//                // Expiry Date
//                VStack(alignment: .leading, spacing: 8) {
//                    Text("Expiry Date")
//                        .font(.headline)
//                        .padding(.horizontal)
//                    Text(product.expiryDate, format: .dateTime.day().month().year())
//                        .font(.body)
//                        .foregroundColor(.secondary)
//                        .padding(.horizontal)
//                }
//
//                // Reviews Section
//                VStack(alignment: .leading, spacing: 12) {
//                    Text("Reviews")
//                        .font(.headline)
//                        .padding(.horizontal)
//                    if let reviews = product.reviews, !reviews.isEmpty {
//                        ForEach(reviews, id: \.self) { review in
//                            VStack(alignment: .leading) {
//                                Text(review)
//                                    .font(.subheadline)
//                                    .foregroundColor(.secondary)
//                                Divider()
//                            }
//                            .padding(.horizontal)
//                        }
//                    } else {
//                        Text("No reviews yet.")
//                            .font(.subheadline)
//                            .foregroundColor(.secondary)
//                            .padding(.horizontal)
//                    }
//                }
//
//                // Farmer Information Section
//                VStack(alignment: .leading, spacing: 8) {
//                    Text("Farmer Info")
//                        .font(.headline)
//                        .padding(.horizontal)
//
//                    if let farmer = farmer {
//                        HStack {
//                            if let profileImageUrl = farmer.profile.profileImageUrl,
//                               let url = URL(string: profileImageUrl) {
//                                KFImage(url)
//                                    .resizable()
//                                    .frame(width: 50, height: 50)
//                                    .clipShape(Circle())
//                            } else {
//                                Image(systemName: "person.circle.fill")
//                                    .resizable()
//                                    .frame(width: 50, height: 50)
//                                    .foregroundColor(.gray)
//                            }
//
//                            VStack(alignment: .leading) {
//                                Text(farmer.profile.name)
//                                    .font(.headline)
//                                Text(farmer.profile.email)
//                                    .font(.subheadline)
//                                    .foregroundColor(.secondary)
//                            }
//                            Spacer()
//                        }
//                        .padding()
//                        .background(Color.gray.opacity(0.1))
//                        .cornerRadius(10)
//                        .padding(.horizontal)
//                    } else {
//                        Text("Farmer info unavailable.")
//                            .font(.subheadline)
//                            .foregroundColor(.secondary)
//                            .padding(.horizontal)
//                    }
//                }
//
//                // Error Message
//                if let error = errorMessage {
//                    Text(error)
//                        .foregroundColor(.red)
//                        .padding()
//                        .background(Color.white.opacity(0.8))
//                        .cornerRadius(10)
//                        .padding(.horizontal)
//                }
//            }
//            .padding(.vertical)
//        }
//        .navigationTitle(product.name)
//        .navigationBarTitleDisplayMode(.inline)
//        .alert(isPresented: $showAlert) {
//            Alert(
//                title: Text(isAddedToCart ? "Success" : "Error"),
//                message: Text(alertMessage),
//                dismissButton: .default(Text("OK"))
//            )
//        }
//        .toolbar {
//            ToolbarItem(placement: .navigationBarTrailing) {
//                NavigationLink(destination: AddToCartView()) {
//                    Image(systemName: "cart")
//                        .foregroundColor(.blue)
//                        .overlay(
//                            Text("\(cartManager.cartItems.count)")
//                                .font(.footnote)
//                                .foregroundColor(.white)
//                                .padding(4)
//                                .background(cartManager.cartItems.isEmpty ? Color.clear : Color.red)
//                                .clipShape(Circle())
//                                .offset(x: 10, y: -10)
//                        )
//                }
//            }
//        }
//        .task {
//            if farmer == nil {
//                await fetchFarmer()
//            }
////            await checkCartStatus()
//        }
//    }
//
//    // MARK: - Helper Functions
//
//    private func fetchFarmer() async {
//        do {
//            let fetchedFarmer = try await SupabaseManager.shared.fetchUser(by: product.farmerId)
//            await MainActor.run {
//                self.errorMessage = nil
//            }
//        } catch {
//            await MainActor.run {
//                self.errorMessage = "Failed to load farmer info: \(error.localizedDescription)"
//            }
//        }
//    }
//
//    private func checkDeliveryAvailability() {
//        guard pincodeText.count == 6, pincodeText.allSatisfy({ $0.isNumber }) else {
//            alertMessage = "Please enter a valid 6-digit pincode."
//            showAlert = true
//            return
//        }
//        isDeliveryAvailable = availablePincodes.contains(pincodeText)
//    }
//
////    private func checkCartStatus() async {
////        await MainActor.run {
////            isAddedToCart = cartManager.isProductInCart(product.id)
////        }
////    }
//}
//
//// MARK: - Preview
//struct ProductDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationStack {
//            ProductDetailView(
//                product: Product(
//                    id: UUID(),
//                    name: "Organic Apples",
//                    category: .fruits,
//                    pricePerKg: 150.0,
//                    quantityAvailable: 100.0,
//                    originalQuantity: 100.0,
//                    description: "Fresh organic apples from local farms.",
//                    imageNames: ["apple1"],
//                    imageUrls: ["https://example.com/apple1.jpg"],
//                    status: .available,
//                    expiryDate: Date().addingTimeInterval(604800),
//                    farmerId: UUID(),
//                    rating: 4.5,
//                    reviewsCount: 10,
//                    reviews: ["Great quality!", "Very fresh"]
//                ),
//                farmer: User(
//                    id: UUID(),
//                    role: .farmer,
//                    profile: Profile(
//                        name: "John Farmer",
//                        username: "johnf",
//                        email: "john@farm.com",
//                        contactNumber: "9876543210",
//                        dateOfBirth: Date(),
//                        countryRegion: "India",
//                        joinedDate: Date(),
//                        profileImageUrl: "https://example.com/farmer.jpg",
//                        defaultAddress: nil,
//                        savedAddresses: []
//                    ), email: "f@ex.com",
//                    settings: UserSettings(
//                        pushNotificationsEnabled: true,
//                        darkModeEnabled: false,
//                        emailNotificationsEnabled: true
//                    ),
//                    status: .online,
//                    metrics: UserMetrics(
//                        postCount: 10,
//                        commentCount: 20,
//                        isTopContributor: true,
//                        rating: 4.8,
//                        reviewCount: 15
//                    )
//                )
//            )
//        }
//    }
//}


import SwiftUI
import Kingfisher
import Supabase

struct ProductDetailView: View {
    let product: Product
    @State private var farmer: User? = nil
    @StateObject private var cartManager = CartManager.shared
    @State private var quantity: Int = 20
    @State private var pincodeText: String = ""
    @State private var isDeliveryAvailable: Bool? = nil
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var errorMessage: String?
    @State private var isAddedToCart: Bool = false

    private let availablePincodes = ["560001", "110002", "400002", "700001", "500001"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Product Image Carousel
                if !product.imageUrls.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(product.imageUrls, id: \.self) { url in
                                KFImage(URL(string: url))
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity, maxHeight: 250)
                                    .cornerRadius(8)
                                    .padding(.horizontal, 4)
                            }
                        }
                        .padding(.horizontal)
                    }
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(maxWidth: .infinity, maxHeight: 250)
                        .cornerRadius(8)
                        .padding()
                }

                // Product Info
                VStack(alignment: .leading, spacing: 8) {
                    Text(product.name)
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.horizontal)

                    HStack {
                        if let rating = product.rating {
                            Text(String(format: "%.1f", rating))
                                .fontWeight(.medium)
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                        }
                        Text("(\(product.reviewsCount) Reviews)")
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)

                    Text(product.formattedPrice)
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)

                    Text("Category: \(product.category.rawValue.capitalized)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                }

                // Quantity Selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("Quantity")
                        .font(.headline)
                        .padding(.horizontal)

                    HStack {
                        Button {
                            if quantity > 20 {
                                quantity -= 1
                            }
                        } label: {
                            Image(systemName: "minus")
                                .frame(width: 44, height: 44)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                        }

                        Text("\(quantity) kg")
                            .font(.headline)
                            .frame(minWidth: 60, alignment: .center)

                        Button {
                            if Double(quantity) < product.quantityAvailable {
                                quantity += 1
                            }
                        } label: {
                            Image(systemName: "plus")
                                .frame(width: 44, height: 44)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                }

                // Add to Cart Button
                Button {
                    Task {
                        if quantity >= 20 {
                            await cartManager.addProduct(product, quantity: quantity)
                            await MainActor.run {
                                isAddedToCart = true
                                alertMessage = "\(product.name) added to cart."
                                showAlert = true
                            }
                        } else {
                            await MainActor.run {
                                alertMessage = "Minimum order quantity is 20 kg."
                                showAlert = true
                            }
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: isAddedToCart ? "cart.fill" : "cart")
                        Text(isAddedToCart ? "Added to Cart" : "Add to Cart")
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isAddedToCart ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal)

                // Delivery Check
                VStack(alignment: .leading, spacing: 8) {
                    Text("Delivery Availability")
                        .font(.headline)
                        .padding(.horizontal)

                    HStack {
                        TextField("Enter Pincode", text: $pincodeText)
                            .keyboardType(.numberPad)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)

                        Button {
                            checkDeliveryAvailability()
                        } label: {
                            Text("Check")
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)

                    if let isAvailable = isDeliveryAvailable {
                        Text(isAvailable ? "Delivery available!" : "Sorry, delivery not available.")
                            .foregroundColor(isAvailable ? .green : .red)
                            .font(.subheadline)
                            .padding(.horizontal)
                    }
                }

                // Description
                VStack(alignment: .leading, spacing: 8) {
                    Text("Description")
                        .font(.headline)
                        .padding(.horizontal)
                    Text(product.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                }

                // Expiry Date
                VStack(alignment: .leading, spacing: 8) {
                    Text("Expiry Date")
                        .font(.headline)
                        .padding(.horizontal)
                    Text(product.expiryDate, format: .dateTime.day().month().year())
                        .font(.body)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                }

                // Reviews
                VStack(alignment: .leading, spacing: 12) {
                    Text("Reviews")
                        .font(.headline)
                        .padding(.horizontal)
                    if let reviews = product.reviews, !reviews.isEmpty {
                        ForEach(reviews, id: \.self) { review in
                            VStack(alignment: .leading) {
                                Text(review)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Divider()
                            }
                            .padding(.horizontal)
                        }
                    } else {
                        Text("No reviews yet.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                    }
                }

                // Farmer Info
                VStack(alignment: .leading, spacing: 8) {
                    Text("Farmer Info")
                        .font(.headline)
                        .padding(.horizontal)

                    if let farmer = farmer {
                        HStack {
                            if let profileImageUrl = farmer.profile.profileImageUrl,
                               let url = URL(string: profileImageUrl) {
                                KFImage(url)
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.gray)
                            }

                            VStack(alignment: .leading) {
                                Text(farmer.profile.name)
                                    .font(.headline)
                                Text(farmer.email)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    } else {
                        Text("Farmer info unavailable.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                    }
                }

                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle(product.name)
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(isAddedToCart ? "Success" : "Error"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: AddToCartView()) {
                    Image(systemName: "cart")
                        .foregroundColor(.blue)
                        .overlay(
                            Text("\(cartManager.cartItems.count)")
                                .font(.footnote)
                                .foregroundColor(.white)
                                .padding(4)
                                .background(cartManager.cartItems.isEmpty ? Color.clear : Color.red)
                                .clipShape(Circle())
                                .offset(x: 10, y: -10)
                        )
                }
            }
        }
        .task {
            await fetchFarmer()
        }
    }

    // MARK: - Helpers

    private func fetchFarmer() async {
        do {
            let fetched = try await SupabaseManager.shared.fetchUser(by: product.farmerId)
            await MainActor.run {
                self.farmer = fetched
                self.errorMessage = nil
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to load farmer info: \(error.localizedDescription)"
            }
        }
    }

    private func checkDeliveryAvailability() {
        guard pincodeText.count == 6, pincodeText.allSatisfy({ $0.isNumber }) else {
            alertMessage = "Please enter a valid 6-digit pincode."
            showAlert = true
            return
        }
        isDeliveryAvailable = availablePincodes.contains(pincodeText)
    }
}

// MARK: - Preview

struct ProductDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ProductDetailView(
                product: Product(
                    id: UUID(),
                    name: "Organic Apples",
                    category: .fruits,
                    pricePerKg: 150.0,
                    quantityAvailable: 100.0,
                    originalQuantity: 100.0,
                    description: "Fresh organic apples from local farms.",
                    imageNames: ["apple1"],
                    imageUrls: ["https://example.com/apple1.jpg"],
                    status: .available,
                    expiryDate: Date().addingTimeInterval(604800),
                    farmerId: UUID(),
                    rating: 4.5,
                    reviewsCount: 10,
                    reviews: ["Great quality!", "Very fresh"]
                )
            )
        }
    }
}
