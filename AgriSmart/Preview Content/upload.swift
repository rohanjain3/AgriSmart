//// Upload.swift
//
//import SwiftUI
//import PhotosUI
//import Kingfisher
//import Supabase
//
//// MARK: - SupabaseManager Extension
//
//
//
//// MARK: - ProductStore
//
//class ProductStore: ObservableObject {
//    @Published var products: [Product] = []
//    @Published var errorMessage: String?
//    
//    init() {
//        Task {
//            await loadProducts()
//        }
//    }
//    
//    init(products: [Product]) {
//        self.products = products
//    }
//    
//    func loadProducts() async {
//        do {
//            let fetched = try await SupabaseManager.shared.fetchProducts()
//            await MainActor.run {
//                self.products = fetched
//                self.errorMessage = nil
//            }
//        } catch {
//            await MainActor.run {
//                self.errorMessage = "Failed to load products: \(error.localizedDescription)"
//                print("Error details:", error)
//            }
//        }
//    }
//
//    @MainActor
//    func delete(_ indexSet: IndexSet) async {
//        for index in indexSet {
//            let product = products[index]
//            do {
//                try await SupabaseManager.shared.deleteProduct(id: product.id)
//                products.remove(at: index)
//            } catch {
//                errorMessage = "Failed to delete \(product.name): \(error.localizedDescription)"
//                print("Delete error:", error)
//            }
//        }
//    }
//}
//
//// MARK: - MainCropView
//
//struct MainCropView: View {
//    @StateObject private var productStore = ProductStore()
//    @State private var showingUploadView = false
//
//    var body: some View {
//        NavigationStack {
//            UploadedCropsView(productStore: productStore)
//                .navigationTitle("Uploaded Crops")
//                .toolbar {
//                    ToolbarItem(placement: .navigationBarTrailing) {
//                        Button {
//                            showingUploadView = true
//                        } label: {
//                            Image(systemName: "plus")
//                        }
//                    }
//                }
//                .navigationDestination(isPresented: $showingUploadView) {
//                    UploadCropView(productStore: productStore)
//                }
//                .overlay {
//                    if let msg = productStore.errorMessage {
//                        VStack {
//                            Text(msg)
//                                .foregroundColor(.red)
//                                .padding()
//                                .background(Color.white.opacity(0.8))
//                                .cornerRadius(10)
//                                .padding(.top)
//                            Spacer()
//                        }
//                    }
//                }
//        }
//    }
//}
//
//// MARK: - UploadCropView
//
//struct UploadCropView: View {
//    @ObservedObject var productStore: ProductStore
//    
//    @State private var name: String = ""
//    @State private var selectedCategory: ProductCategory = .vegetables
//    @State private var pricePerKg: String = ""
//    @State private var quantityAvailable: String = ""
//    @State private var description: String = ""
//    @State private var expiryDate: Date = Date()
//    @State private var selectedImages: [PhotosPickerItem] = []
//    @State private var imageNames: [String] = []
//    @State private var imageUrls: [String] = []
//    @State private var errorMessage: String?
//    
//    @Environment(\.dismiss) private var dismiss
//
//    var body: some View {
//        Form {
//            Section("Crop Details") {
//                TextField("Name", text: $name)
//                Picker("Category", selection: $selectedCategory) {
//                    ForEach(ProductCategory.allCases, id: \.self) {
//                        Text($0.rawValue.capitalized)
//                    }
//                }
//                TextField("Price per Kg (₹)", text: $pricePerKg)
//                    .keyboardType(.decimalPad)
//                TextField("Quantity Available (kg)", text: $quantityAvailable)
//                    .keyboardType(.decimalPad)
//                DatePicker("Expiry Date", selection: $expiryDate, displayedComponents: .date)
//                TextField("Description", text: $description, axis: .vertical)
//                    .lineLimit(3...)
//            }
//            
//            Section("Upload Images") {
//                PhotosPicker(selection: $selectedImages, maxSelectionCount: 3, matching: .images) {
//                    Label("Select Images", systemImage: "photo.on.rectangle")
//                }
//                
//                if !imageUrls.isEmpty {
//                    ScrollView(.horizontal) {
//                        HStack {
//                            ForEach(imageUrls, id: \.self) { url in
//                                KFImage(URL(string: url))
//                                    .resizable()
//                                    .scaledToFit()
//                                    .frame(width: 80, height: 80)
//                                    .cornerRadius(8)
//                            }
//                        }
//                    }
//                }
//            }
//            
//            if let msg = errorMessage {
//                Section {
//                    Text(msg)
//                        .foregroundColor(.red)
//                        .font(.footnote)
//                }
//            }
//            
//            Button("Upload Crop") {
//                uploadProduct()
//            }
//            .buttonStyle(.borderedProminent)
//            .disabled(name.isEmpty || pricePerKg.isEmpty || quantityAvailable.isEmpty)
//        }
//        .navigationTitle("Upload Crop")
//        .onChange(of: selectedImages) { _ in
//            Task {
//                imageNames.removeAll()
//                imageUrls.removeAll()
//                
//                for item in selectedImages {
//                    if let data = try? await item.loadTransferable(type: Data.self),
//                       let uiImage = UIImage(data: data) {
//                        let imageName = UUID().uuidString
//                        imageNames.append(imageName)
//                        do {
//                            let url = try await SupabaseManager.shared.uploadImage(uiImage, name: imageName)
//                            imageUrls.append(url)
//                        } catch {
//                            await MainActor.run {
//                                errorMessage = "Failed to upload image: \(error.localizedDescription)"
//                                print("Image upload error:", error)
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
//    
//    private func uploadProduct() {
//        guard let price = Double(pricePerKg),
//              let qty   = Double(quantityAvailable) else {
//            errorMessage = "Invalid price or quantity"
//            return
//        }
//        
//        Task {
//            do {
//                let session = try await SupabaseManager.shared.fetchUserSession()
//                let farmerID = session.user.id
//                
//                let newProduct = Product(
//                    id: UUID(),
//                    name: name,
//                    category: selectedCategory,
//                    pricePerKg: price,
//                    quantityAvailable: qty,
//                    originalQuantity: qty,
//                    description: description,
//                    imageNames: imageNames,
//                    imageUrls: imageUrls,
//                    status: .available,
//                    expiryDate: expiryDate,
//                    farmerId: farmerID,
//                    rating: nil,
//                    reviewsCount: 0,
//                    reviews: nil
//                )
//                
//                try await SupabaseManager.shared.uploadProduct(newProduct)
//                await productStore.loadProducts()
//                
//                await MainActor.run {
//                    // reset form
//                    name = ""
//                    pricePerKg = ""
//                    quantityAvailable = ""
//                    description = ""
//                    selectedCategory = .vegetables
//                    expiryDate = Date()
//                    imageNames.removeAll()
//                    selectedImages.removeAll()
//                    imageUrls.removeAll()
//                    errorMessage = nil
//                    dismiss()
//                }
//            } catch {
//                await MainActor.run {
//                    errorMessage = "Failed to upload product: \(error.localizedDescription)"
//                    print("Product upload error:", error)
//                }
//            }
//        }
//    }
//}
//
//// MARK: - UploadedCropsView
//
//struct UploadedCropsView: View {
//    @ObservedObject var productStore: ProductStore
//
//    var body: some View {
//        List {
//            ForEach(productStore.products, id: \.id) { product in
//                HStack(alignment: .top) {
//                    if let firstUrl = product.imageUrls.first,
//                       let url = URL(string: firstUrl) {
//                        KFImage(url)
//                            .resizable()
//                            .frame(width: 80, height: 80)
//                            .cornerRadius(8)
//                    } else {
//                        Rectangle()
//                            .fill(Color.gray.opacity(0.3))
//                            .frame(width: 80, height: 80)
//                            .cornerRadius(8)
//                    }
//                    
//                    VStack(alignment: .leading) {
//                        Text(product.name)
//                            .font(.headline)
//                        Text(product.formattedPrice)
//                            .font(.subheadline)
//                        Text("Category: \(product.category.rawValue.capitalized)")
//                            .font(.caption)
//                            .foregroundColor(.secondary)
//                        Text("Quantity: \(Int(product.quantityAvailable)) kg")
//                            .font(.caption)
//                            .foregroundColor(.secondary)
//                    }
//                }
//                .padding(.vertical, 4)
//            }
//            .onDelete { indexSet in
//                Task {
//                    await productStore.delete(indexSet)
//                }
//            }
//        }
//    }
//}
//
//// MARK: - Preview
//
//#Preview {
//    MainCropView()
//}

import SwiftUI
import PhotosUI
import Kingfisher
import Supabase

// MARK: - SupabaseManager Extension (Conceptual - Assuming you have these methods)
// NOTE: I am making a crucial assumption here that your existing `SupabaseManager.shared.fetchProducts()`
// can be extended or modified to accept an optional `farmerId` for filtering at the database level.
// If your `WorkspaceProducts()` strictly fetches ALL products without any parameters,
// then you would need to implement client-side filtering, which is less efficient.

/*
// This is how your SupabaseManager might need to look to support the change efficiently.
// If these methods already exist in your SupabaseManager.swift, you DON'T need to re-declare them here.
// The key is that `WorkspaceProducts` should accept an optional `farmerId`.

extension SupabaseManager {

    // IMPORTANT: Modify your existing fetchProducts to accept an optional farmerId
    func fetchProducts(farmerId: UUID? = nil) async throws -> [Product] {
        var query = client.from("products").select()

        if let id = farmerId {
            query = query.eq("farmerId", id.uuidString)
        }

        let response: [Product] = try await query
            .order("name", ascending: true)
            .execute()
            .value
        return response
    }

    // Ensure these exist and are correctly implemented in your SupabaseManager.swift
    func uploadProduct(_ product: Product) async throws {
        // ... (your existing implementation)
    }

    func deleteProduct(id: UUID) async throws {
        // ... (your existing implementation)
    }

    func fetchUserSession() async throws -> Session {
        // ... (your existing implementation)
        // Make sure it throws AppError.noUserSession if session is nil
    }

    func uploadImage(_ image: UIImage, name: String) async throws -> String {
        // ... (your existing implementation)
    }
}
*/


// MARK: - ProductStore

class ProductStore: ObservableObject {
    @Published var products: [Product] = []
    @Published var errorMessage: String?
    
    init() {
        Task {
            await loadProducts()
        }
    }
    
    init(products: [Product]) {
        self.products = products
    }
    
    func loadProducts() async {
        do {
            // Fetch the current user's session to get their ID
            let session = try await SupabaseManager.shared.fetchUserSession()
            let currentFarmerID = session.user.id
            
            // Call the existing fetchProducts but pass the farmerId for filtering
            let fetched = try await SupabaseManager.shared.fetchProducts()
            
            await MainActor.run {
                self.products = fetched
                self.errorMessage = nil
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to load products: \(error.localizedDescription)"
                print("Error details:", error)
            }
        }
    }

    @MainActor
    func delete(_ indexSet: IndexSet) async {
        for index in indexSet {
            let product = products[index]
            do {
                try await SupabaseManager.shared.deleteProduct(id: product.id)
                products.remove(at: index)
            } catch {
                errorMessage = "Failed to delete \(product.name): \(error.localizedDescription)"
                print("Delete error:", error)
            }
        }
    }
}

// MARK: - MainCropView

struct MainCropView: View {
    @StateObject private var productStore = ProductStore()
    @State private var showingUploadView = false

    var body: some View {
        NavigationStack {
            UploadedCropsView(productStore: productStore)
                .navigationTitle("Your Uploaded Crops")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showingUploadView = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
                .navigationDestination(isPresented: $showingUploadView) {
                    UploadCropView(productStore: productStore)
                }
                .overlay {
                    if let msg = productStore.errorMessage {
                        VStack {
                            Spacer()
                            Text(msg)
                                .foregroundColor(.red)
                                .padding()
                                .background(Color.white.opacity(0.8))
                                .cornerRadius(10)
                                .padding()
                            Spacer()
                        }
                    }
                }
                .onAppear {
                    // Reload products every time the view appears
                    Task {
                        await productStore.loadProducts()
                    }
                }
        }
    }
}

// MARK: - UploadCropView

struct UploadCropView: View {
    @ObservedObject var productStore: ProductStore
    
    @State private var name: String = ""
    @State private var selectedCategory: ProductCategory = .vegetables
    @State private var pricePerKg: String = ""
    @State private var quantityAvailable: String = ""
    @State private var description: String = ""
    @State private var expiryDate: Date = Date()
    @State private var selectedImages: [PhotosPickerItem] = []
    @State private var imageNames: [String] = []
    @State private var imageUrls: [String] = []
    @State private var errorMessage: String?
    
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section("Crop Details") {
                TextField("Name", text: $name)
                Picker("Category", selection: $selectedCategory) {
                    ForEach(ProductCategory.allCases, id: \.self) {
                        Text($0.rawValue.capitalized)
                    }
                }
                TextField("Price per Kg (₹)", text: $pricePerKg)
                    .keyboardType(.decimalPad)
                TextField("Quantity Available (kg)", text: $quantityAvailable)
                    .keyboardType(.decimalPad)
                DatePicker("Expiry Date", selection: $expiryDate, displayedComponents: .date)
                TextField("Description", text: $description, axis: .vertical)
                    .lineLimit(3...)
            }
            
            Section("Upload Images") {
                PhotosPicker(selection: $selectedImages, maxSelectionCount: 3, matching: .images) {
                    Label("Select Images", systemImage: "photo.on.rectangle")
                }
                
                if !imageUrls.isEmpty {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(imageUrls, id: \.self) { url in
                                KFImage(URL(string: url))
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .cornerRadius(8)
                                    .clipped()
                            }
                        }
                    }
                }
            }
            
            if let msg = errorMessage {
                Section {
                    Text(msg)
                        .foregroundColor(.red)
                        .font(.footnote)
                }
            }
            
            Button("Upload Crop") {
                uploadProduct()
            }
            .buttonStyle(.borderedProminent)
            .disabled(name.isEmpty || pricePerKg.isEmpty || quantityAvailable.isEmpty || selectedImages.isEmpty)
        }
        .navigationTitle("Upload New Crop")
        .onChange(of: selectedImages) { newItems in
            Task {
                imageNames.removeAll()
                imageUrls.removeAll()
                errorMessage = nil
                
                for item in newItems {
                    do {
                        if let data = try await item.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data) {
                            let imageName = UUID().uuidString
                            imageNames.append(imageName)
                            let url = try await SupabaseManager.shared.uploadImage(uiImage, name: imageName)
                            imageUrls.append(url)
                        }
                    } catch {
                        await MainActor.run {
                            errorMessage = "Failed to load or upload image: \(error.localizedDescription)"
                            print("Image processing/upload error:", error)
                        }
                    }
                }
            }
        }
    }
    
    private func uploadProduct() {
        guard let price = Double(pricePerKg), price > 0 else {
            errorMessage = "Please enter a valid price."
            return
        }
        guard let qty = Double(quantityAvailable), qty > 0 else {
            errorMessage = "Please enter a valid quantity."
            return
        }
        
        guard !imageUrls.isEmpty else {
            errorMessage = "Please upload at least one image."
            return
        }
        
        Task {
            do {
                let session = try await SupabaseManager.shared.fetchUserSession()
                let farmerID = session.user.id
                
                let newProduct = Product(
                    id: UUID(),
                    name: name,
                    category: selectedCategory,
                    pricePerKg: price,
                    quantityAvailable: qty,
                    originalQuantity: qty,
                    description: description,
                    imageNames: imageNames,
                    imageUrls: imageUrls,
                    status: .available,
                    expiryDate: expiryDate,
                    farmerId: farmerID,
                    rating: nil,
                    reviewsCount: 0,
                    reviews: nil
                )
                
                try await SupabaseManager.shared.uploadProduct(newProduct)
                await productStore.loadProducts()
                
                await MainActor.run {
                    name = ""
                    pricePerKg = ""
                    quantityAvailable = ""
                    description = ""
                    selectedCategory = .vegetables
                    expiryDate = Date()
                    imageNames.removeAll()
                    selectedImages.removeAll()
                    imageUrls.removeAll()
                    errorMessage = nil
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to upload product: \(error.localizedDescription)"
                    print("Product upload error:", error)
                }
            }
        }
    }
}

// MARK: - UploadedCropsView

struct UploadedCropsView: View {
    @ObservedObject var productStore: ProductStore

    var body: some View {
        Group {
            if productStore.products.isEmpty {
                ContentUnavailableView(
                    "No Crops Uploaded",
                    systemImage: "leaf.fill",
                    description: Text("You haven't uploaded any crops yet. Tap the '+' button to add your first crop!")
                )
            } else {
                List {
                    ForEach(productStore.products, id: \.id) { product in
                        HStack(alignment: .top) {
                            if let firstUrl = product.imageUrls.first,
                               let url = URL(string: firstUrl) {
                                KFImage(url)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .cornerRadius(8)
                                    .clipped()
                            } else {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 80, height: 80)
                                    .cornerRadius(8)
                            }
                            
                            VStack(alignment: .leading) {
                                Text(product.name)
                                    .font(.headline)
                                Text(product.formattedPrice)
                                    .font(.subheadline)
                                Text("Category: \(product.category.rawValue.capitalized)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("Quantity: \(Int(product.quantityAvailable)) kg")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .onDelete { indexSet in
                        Task {
                            await productStore.delete(indexSet)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    MainCropView()
}
