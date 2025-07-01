//// ExploreView.swift
//// Agrismart
//// Created by Rohan Jain on 07/03/25.
//
//import SwiftUI
//import Kingfisher
//import Supabase
//
//// MARK: - ExploreView
//
//struct ExploreView: View {
//    @ObservedObject var cartManager = CartManager.shared
//    @State private var products: [Product] = []
//    @State private var cropCategories: [CropCategory] = []
//    @State private var filteredCrops: [CropCategory] = []
//    @State private var searchText: String = ""
//    @State private var showPopup: Bool = false
//    @State private var popupMessage: String = ""
//    @State private var errorMessage: String?
//
//    var body: some View {
//        NavigationStack {
//            ScrollView {
//                VStack(alignment: .leading, spacing: 16) {
//                    if let error = errorMessage {
//                        Text(error)
//                            .foregroundColor(.red)
//                            .padding()
//                            .background(Color.white.opacity(0.8))
//                            .cornerRadius(10)
//                            .padding(.horizontal)
//                    }
//
//                    searchBar
//
//                    cropCategoriesSection
//                }
//            }
//            .navigationTitle("AgriSmart")
//            .toolbar { toolbarContent }
//            .alert(isPresented: $showPopup) {
//                Alert(title: Text("Success"),
//                      message: Text(popupMessage),
//                      dismissButton: .default(Text("OK")))
//            }
//            .task { await fetchProducts() }
//        }
//    }
//
//    // MARK: Subviews
//
//    private var searchBar: some View {
//        HStack {
//            Image(systemName: "magnifyingglass").foregroundColor(.gray)
//            TextField("Search for crops...", text: $searchText,
//                      onEditingChanged: { _ in applySearch() },
//                      onCommit: applySearch)
//                .onChange(of: searchText) { _ in applySearch() }
//
//            if !searchText.isEmpty {
//                Button {
//                    searchText = ""
//                    applySearch()
//                } label: {
//                    Image(systemName: "xmark.circle.fill").foregroundColor(.gray)
//                }
//            }
//        }
//        .padding()
//        .background(Color.gray.opacity(0.2))
//        .cornerRadius(10)
//        .padding(.horizontal)
//    }
//
//    private var cropCategoriesSection: some View {
//        VStack(alignment: .leading) {
//            Text("Crop Categories")
//                .font(.headline)
//                .padding(.horizontal)
//
//            ForEach(filteredCrops) { category in
//                VStack(alignment: .leading) {
//                    Text(category.name)
//                        .font(.subheadline).bold()
//                        .padding(.horizontal)
//
//                    ScrollView(.horizontal, showsIndicators: false) {
//                        HStack(spacing: 12) {
//                            ForEach(category.crops) { crop in
//                                NavigationLink(
//                                    destination: ProductDetailView(
//                                        product: crop.originalProduct,
//                                        farmer: crop.farmer
//                                    )
//                                ) {
//                                    VStack {
//                                        CropCardView(crop: crop)
//
//                                        Button {
//                                            Task {
//                                                await cartManager.addProduct(crop.originalProduct, quantity: 20)
//                                                await MainActor.run {
//                                                    popupMessage = "\(crop.name) added to cart."
//                                                    showPopup = true
//                                                }
//                                            }
//                                        } label: {
//                                            Text("Add to Cart")
//                                                .font(.caption)
//                                                .foregroundColor(.white)
//                                                .padding(8)
//                                                .background(Color.blue)
//                                                .cornerRadius(5)
//                                        }
//                                    }
//                                }
//                            }
//                        }
//                        .padding(.horizontal)
//                    }
//                }
//            }
//        }
//    }
//
//    private var toolbarContent: some ToolbarContent {
//        ToolbarItem(placement: .navigationBarTrailing) {
//            NavigationLink(destination: AddToCartView()) {
//                Image(systemName: "cart")
//                    .overlay(
//                        Text("\(cartManager.cartItems.count)")
//                            .font(.footnote)
//                            .foregroundColor(.white)
//                            .padding(4)
//                            .background(cartManager.cartItems.isEmpty ? Color.clear : Color.red)
//                            .clipShape(Circle())
//                            .offset(x: 10, y: -10)
//                    )
//            }
//        }
//    }
//
//    // MARK: - Data Handling
//
//    private func applySearch() {
//        if searchText.isEmpty {
//            filteredCrops = cropCategories
//        } else {
//            filteredCrops = cropCategories
//                .map { category in
//                    CropCategory(
//                        name: category.name,
//                        crops: category.crops.filter {
//                            $0.name.lowercased().contains(searchText.lowercased())
//                        }
//                    )
//                }
//                .filter { !$0.crops.isEmpty }
//        }
//    }
//
//    private func fetchProducts() async {
//        do {
//            let fetchedProducts = try await SupabaseManager.shared.fetchProducts()
//            var cropsWithFarmers: [Crop] = []
//            
//            for product in fetchedProducts {
//                do {
//                    let farmer = try await SupabaseManager.shared.fetchUser(by: product.farmerId)
//                    let crop = Crop(
//                        id: product.id,
//                        name: product.name,
//                        imageUrl: product.imageUrls.first,
//                        originalProduct: product,
//                        farmer: farmer
//                    )
//                    cropsWithFarmers.append(crop)
//                } catch {
//                    print("Failed to fetch farmer for product \(product.name): \(error.localizedDescription)")
//                    // Optionally handle missing farmer data by adding crop without farmer
//                    let crop = Crop(
//                        id: product.id,
//                        name: product.name,
//                        imageUrl: product.imageUrls.first,
//                        originalProduct: product,
//                        farmer: nil
//                    )
//                    cropsWithFarmers.append(crop)
//                }
//            }
//
//            await MainActor.run {
//                products = fetchedProducts
//                cropCategories = convertProductsToCategories(cropsWithFarmers)
//                filteredCrops = cropCategories
//                errorMessage = nil
//                applySearch()
//            }
//        } catch {
//            await MainActor.run {
//                errorMessage = "Failed to load products: \(error.localizedDescription)"
//            }
//        }
//    }
//}
//
//// MARK: - Models & Helpers
//
//func convertProductsToCategories(_ crops: [Crop]) -> [CropCategory] {
//    let grouped = Dictionary(grouping: crops, by: { $0.originalProduct.category })
//    return grouped.map { (category, crops) in
//        CropCategory(
//            name: category.rawValue.capitalized,
//            crops: crops
//        )
//    }
//}
//
//struct CropCategory: Identifiable {
//    let id = UUID()
//    let name: String
//    let crops: [Crop]
//}
//
//struct Crop: Identifiable {
//    let id: UUID
//    let name: String
//    let imageUrl: String?
//    let originalProduct: Product
//    let farmer: User?
//}
//
//// MARK: - CropCardView
//
//struct CropCardView: View {
//    let crop: Crop
//
//    var body: some View {
//        VStack {
//            if let urlString = crop.imageUrl,
//               let url = URL(string: urlString) {
//                KFImage(url)
//                    .resizable()
//                    .scaledToFill()
//                    .frame(width: 100, height: 100)
//                    .clipped()
//                    .cornerRadius(10)
//            } else {
//                Rectangle()
//                    .fill(Color.gray.opacity(0.3))
//                    .frame(width: 100, height: 100)
//                    .cornerRadius(10)
//            }
//
//            Text(crop.name)
//                .font(.footnote)
//                .lineLimit(1)
//
//            if let price = crop.originalProduct.pricePerKg as Double? {
//                Text("₹\(Int(price))/kg")
//                    .font(.caption)
//                    .foregroundColor(.gray)
//            }
//        }
//        .frame(width: 120)
//        .background(Color.white)
//        .cornerRadius(10)
//        .shadow(radius: 2)
//    }
//}
//
//// MARK: - Preview
//
//struct ExploreView_Previews: PreviewProvider {
//    static var previews: some View {
//        ExploreView()
//    }
//}

//
// ExploreView.swift
// Agrismart
// Created on 07/03/25.

import SwiftUI
import Kingfisher
import Supabase

struct ExploreView: View {
    @ObservedObject var cartManager = CartManager.shared
    @State private var products: [Product] = []
    @State private var cropCategories: [CropCategory] = []
    @State private var filteredCrops: [CropCategory] = []
    @State private var searchText: String = ""
    @State private var showPopup = false
    @State private var popupMessage = ""
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }

                    searchBar

                    cropCategoriesSection
                }
            }
            .navigationTitle("AgriSmart")
            .toolbar { toolbarContent }
            .alert("Success", isPresented: $showPopup) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(popupMessage)
            }
            .task { await fetchProducts() }
        }
    }

    // MARK: - Subviews

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass").foregroundColor(.gray)
            TextField("Search for crops...", text: $searchText,
                      onEditingChanged: { _ in applySearch() },
                      onCommit: applySearch)
                .onChange(of: searchText) { _ in applySearch() }

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                    applySearch()
                } label: {
                    Image(systemName: "xmark.circle.fill").foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
        .padding(.horizontal)
    }

    private var cropCategoriesSection: some View {
        VStack(alignment: .leading) {
            Text("Crop Categories")
                .font(.headline)
                .padding(.horizontal)

            ForEach(filteredCrops) { category in
                VStack(alignment: .leading) {
                    Text(category.name)
                        .font(.subheadline).bold()
                        .padding(.horizontal)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(category.crops) { crop in
                                // Extracted NavigationLink content into a helper function
                                cropNavigationLink(for: crop)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
    }

    // Helper function to create NavigationLink for CropItemView
    @ViewBuilder
    private func cropNavigationLink(for crop: Crop) -> some View {
        NavigationLink(
            destination: ProductDetailView(
                product: crop.originalProduct,
//                farmer: crop.farmer
            )
        ) {
            CropItemView(crop: crop) {
                Task {
                    await cartManager.addProduct(crop.originalProduct, quantity: 20)
                    await MainActor.run {
                        popupMessage = "\(crop.name) added to cart."
                        showPopup = true
                    }
                }
            }
        }
    }


    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            NavigationLink(destination: AddToCartView()) {
                Image(systemName: "cart")
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

    // MARK: - Logic

    private func applySearch() {
        if searchText.isEmpty {
            filteredCrops = cropCategories
        } else {
            filteredCrops = cropCategories
                .map { category in
                    CropCategory(
                        name: category.name,
                        crops: category.crops.filter {
                            $0.name.localizedCaseInsensitiveContains(searchText)
                        }
                    )
                }
                .filter { !$0.crops.isEmpty }
        }
    }

    private func fetchProducts() async {
        do {
            let fetched = try await SupabaseManager.shared.fetchProducts()
            var cropsWithFarmers: [Crop] = []

            for product in fetched {
                do {
                    let farmer = try await SupabaseManager.shared.fetchUser(by: product.farmerId)
                    cropsWithFarmers.append(.init(
                        id: product.id,
                        name: product.name,
                        imageUrl: product.imageUrls.first,
                        originalProduct: product,
                        farmer: farmer
                    ))
                } catch {
                    print("Farmer fetch failed for \(product.name): \(error.localizedDescription)")
                    cropsWithFarmers.append(.init(
                        id: product.id,
                        name: product.name,
                        imageUrl: product.imageUrls.first,
                        originalProduct: product,
                        farmer: nil
                    ))
                }
            }

            await MainActor.run {
                products = fetched
                cropCategories = convertProductsToCategories(cropsWithFarmers)
                filteredCrops = cropCategories
                applySearch()
                errorMessage = nil
            }
        } catch {
            await MainActor.run {
                errorMessage = "Failed to load products: \(error.localizedDescription)"
            }
        }
    }
}

// MARK: - Subviews

struct CropItemView: View {
    let crop: Crop
    let onAddToCart: () -> Void

    var body: some View {
        VStack(spacing: 4) {
            CropCardView(crop: crop)

            Button(action: onAddToCart) {
                Text("Add to Cart")
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(6)
                    .background(Color.blue)
                    .cornerRadius(5)
            }
        }
        .frame(width: 120)
    }
}

struct CropCardView: View {
    let crop: Crop

    var body: some View {
        VStack {
            if let urlString = crop.imageUrl,
               let url = URL(string: urlString) {
                KFImage(url)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipped()
                    .cornerRadius(10)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 100, height: 100)
                    .cornerRadius(10)
            }

            Text(crop.name)
                .font(.footnote)
                .lineLimit(1)

            Text("₹\(Int(crop.originalProduct.pricePerKg))/kg")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

// MARK: - Models & Helpers

func convertProductsToCategories(_ crops: [Crop]) -> [CropCategory] {
    let grouped = Dictionary(grouping: crops, by: { $0.originalProduct.category })
    return grouped.map { category, crops in
        CropCategory(name: category.rawValue.capitalized, crops: crops)
    }
}

struct CropCategory: Identifiable {
    let id = UUID()
    let name: String
    let crops: [Crop]
}

struct Crop: Identifiable {
    let id: UUID
    let name: String
    let imageUrl: String?
    let originalProduct: Product
    let farmer: User?
}

// MARK: - Preview

struct ExploreView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreView()
    }
}
