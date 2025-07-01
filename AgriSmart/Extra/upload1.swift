////
////  upload1.swift
////  Agrismart
////
////  Created by Rohan Jain on 21/05/25.
////
//
//import SwiftUI
//import PhotosUI
//
//
//
//class ProductStore: ObservableObject {
//    @Published var products: [Product] = []
//    
//    // Load products from local storage (e.g., UserDefaults) for persistence
//    init() {
//        loadProductsFromStorage()
//    }
//    
//    func saveProductsToStorage() {
//        if let encoded = try? JSONEncoder().encode(products) {
//            UserDefaults.standard.set(encoded, forKey: "products")
//        }
//    }
//    
//    func loadProductsFromStorage() {
//        if let data = UserDefaults.standard.data(forKey: "products"),
//           let decoded = try? JSONDecoder().decode([Product].self, from: data) {
//            self.products = decoded
//        }
//    }
//}
//
//struct ContentView1: View {
//    @StateObject private var productStore = ProductStore()
//    
//    var body: some View {
//        UploadedCropsView(productStore: productStore)
//    }
//}
//
//struct UploadCropView: View {
//    @State private var name: String = ""
//    @State private var selectedCategory: ProductCategory = .vegetables
//    @State private var pricePerKg: String = ""
//    @State private var quantityAvailable: String = ""
//    @State private var description: String = ""
//    @State private var expiryDate: Date = Date()
//    
//    @State private var selectedImages: [PhotosPickerItem] = []
//    @State private var imageNames: [String] = []
//    @State private var imageUrls: [String] = []
//    
//    @ObservedObject var productStore: ProductStore
//    @Environment(\.dismiss) private var dismiss
//    
//    var body: some View {
//        NavigationStack {
//            Form {
//                Section(header: Text("Crop Details")) {
//                    TextField("Name", text: $name)
//                    
//                    Picker("Category", selection: $selectedCategory) {
//                        ForEach(ProductCategory.allCases, id: \.self) { category in
//                            Text(category.rawValue)
//                        }
//                    }
//                    
//                    TextField("Price per Kg (₹)", text: $pricePerKg)
//                        .keyboardType(.decimalPad)
//                    
//                    TextField("Quantity Available (kg)", text: $quantityAvailable)
//                        .keyboardType(.decimalPad)
//                    
//                    DatePicker("Expiry Date", selection: $expiryDate, displayedComponents: .date)
//                    
//                    TextField("Description", text: $description, axis: .vertical)
//                        .lineLimit(3...)
//                }
//                
//                Section(header: Text("Upload Images")) {
//                    PhotosPicker(selection: $selectedImages, maxSelectionCount: 3, matching: .images) {
//                        Label("Select Images", systemImage: "photo.on.rectangle")
//                    }
//                    
//                    if !imageNames.isEmpty {
//                        ScrollView(.horizontal) {
//                            HStack {
//                                ForEach(imageNames, id: \.self) { name in
//                                    if let uiImage = loadImageFromLocal(name: name) {
//                                        Image(uiImage: uiImage)
//                                            .resizable()
//                                            .scaledToFit()
//                                            .frame(width: 80, height: 80)
//                                            .cornerRadius(8)
//                                    } else {
//                                        Rectangle()
//                                            .fill(Color.gray.opacity(0.3))
//                                            .frame(width: 80, height: 80)
//                                            .cornerRadius(8)
//                                    }
//                                }
//                            }
//                        }
//                    }
//                }
//                
//                Button(action: uploadProduct) {
//                    Text("Upload Crop")
//                        .frame(maxWidth: .infinity)
//                }
//                .buttonStyle(.borderedProminent)
//                .disabled(name.isEmpty || pricePerKg.isEmpty || quantityAvailable.isEmpty)
//            }
//            .navigationTitle("Upload Crop")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .cancellationAction) {
//                    Button("Cancel") {
//                        dismiss()
//                    }
//                }
//            }
//            .onChange(of: selectedImages) { newItems in
//                Task {
//                    imageNames.removeAll()
//                    for item in newItems {
//                        if let data = try? await item.loadTransferable(type: Data.self),
//                           let uiImage = UIImage(data: data) {
//                            let imageName = UUID().uuidString
//                            saveImageToLocal(uiImage, name: imageName)
//                            imageNames.append(imageName)
//                        }
//                    }
//                }
//            }
//        }
//    }
//    
//    func uploadProduct() {
//        guard let price = Double(pricePerKg),
//              let quantity = Double(quantityAvailable) else {
//            print("Invalid price or quantity")
//            return
//        }
//        
//        let product = Product(
//            id: UUID(),
//            name: name,
//            category: selectedCategory,
//            pricePerKg: price,
//            quantityAvailable: quantity,
//            originalQuantity: quantity,
//            description: description,
//            imageNames: imageNames,
//            imageUrls: [],
//            status: .available,
//            expiryDate: expiryDate,
//            farmerId: UUID(),
//            rating: nil,
//            reviewsCount: 0,
//            reviews: []
//        )
//        
//        productStore.products.append(product)
//        productStore.saveProductsToStorage() // Save to local storage
//        print("Uploaded Product: \(product)")
//        
//        // Clear form
//        name = ""
//        pricePerKg = ""
//        quantityAvailable = ""
//        description = ""
//        selectedCategory = .vegetables
//        expiryDate = Date()
//        imageNames.removeAll()
//        selectedImages.removeAll()
//        
//        // Dismiss to return to crops list
//        dismiss()
//    }
//    
//    func saveImageToLocal(_ image: UIImage, name: String) {
//        if let data = image.jpegData(compressionQuality: 0.8) {
//            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//                .appendingPathComponent("\(name).jpg")
//            do {
//                try data.write(to: url)
//                print("Image saved locally at \(url)")
//            } catch {
//                print("Failed to save image: \(error)")
//            }
//        }
//    }
//    
//    func loadImageFromLocal(name: String) -> UIImage? {
//        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//            .appendingPathComponent("\(name).jpg")
//        if let data = try? Data(contentsOf: url) {
//            return UIImage(data: data)
//        } else {
//            print("Failed to load image from \(url)")
//            return nil
//        }
//    }
//}
//
//struct UploadedCropsView: View {
//    @ObservedObject var productStore: ProductStore
//    @State private var showUploadView = false
//    
//    var body: some View {
//        NavigationStack {
//            List(productStore.products) { product in
//                HStack(alignment: .top) {
//                    if let firstImageName = product.imageNames.first,
//                       let uiImage = loadImageFromLocal(name: firstImageName) {
//                        Image(uiImage: uiImage)
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
//                        Text("Category: \(product.category.rawValue)")
//                            .font(.caption)
//                            .foregroundColor(.secondary)
//                        Text("Quantity: \(Int(product.quantityAvailable)) kg")
//                            .font(.caption)
//                            .foregroundColor(.secondary)
//                    }
//                }
//                .padding(.vertical, 4)
//            }
//            .navigationTitle("Uploaded Crops")
//            .toolbar {
//                ToolbarItem(placement: .primaryAction) {
//                    Button(action: {
//                        showUploadView = true
//                    }) {
//                        Image(systemName: "plus")
//                    }
//                }
//            }
//            .navigationDestination(isPresented: $showUploadView) {
//                UploadCropView(productStore: productStore)
//            }
//            .task {
//                await fetchProductsFromBackend()
//            }
//        }
//    }
//    
//    func loadImageFromLocal(name: String) -> UIImage? {
//        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//            .appendingPathComponent("\(name).jpg")
//        if let data = try? Data(contentsOf: url) {
//            return UIImage(data: data)
//        } else {
//            print("Failed to load image from \(url)")
//            return nil
//        }
//    }
//    
//    func fetchProductsFromBackend() async {
//        // Replace with your actual backend API endpoint
//        guard let url = URL(string: "https://your-backend-api.com/products") else {
//            print("Invalid URL")
//            return
//        }
//        
//        do {
//            let (data, _) = try await URLSession.shared.data(from: url)
//            let decoder = JSONDecoder()
//            decoder.dateDecodingStrategy = .iso8601 // Adjust based on backend date format
//            let fetchedProducts = try decoder.decode([Product].self, from: data)
//            await MainActor.run {
//                productStore.products = fetchedProducts
//                productStore.saveProductsToStorage()
//            }
//            print("Successfully fetched products: \(fetchedProducts)")
//        } catch {
//            print("Failed to fetch products: \(error)")
//        }
//    }
//}
//
//#Preview {
//    ContentView1()
//}
