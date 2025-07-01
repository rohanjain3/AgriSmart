//import Foundation
//import UIKit
//
//// MARK: - User Base Models
//enum UserRole {
//    case buyer
//    case farmer
//}
//
//struct User: Identifiable,Decodable {
//    let id: UUID
//    var role: UserRole
//    var profile: Profile
//    var email: String
//
//    var settings: UserSettings
//    var status: UserStatus
//    var metrics: UserMetrics
//}
//
//struct Profile {
//    var name: String
//    var username: String
//    var email: String
//    var contactNumber: String
//    var dateOfBirth: Date
//    var countryRegion: String
//    var joinedDate: Date
//    var profileImageUrl: String?
//    var defaultAddress: Address?
//    var savedAddresses: [Address]
//}
//
//// MARK: - Address Model
//struct Address {
//    var fullName: String
//    var addressLine1: String
//    var addressLine2: String?
//    var city: String
//    var state: String
//    var zipCode: String
//    var contactNumber: String
//    
//    var formattedAddress: String {
//        return [addressLine1, addressLine2, "\(city), \(state)", zipCode]
//            .compactMap { $0 }
//            .joined(separator: ", ")
//    }
//}
//
//struct UserMetrics {
//    var postCount: Int
//    var commentCount: Int
//    var isTopContributor: Bool
//    var rating: Double
//    var reviewCount: Int
//}
//
//struct UserSettings {
//    var pushNotificationsEnabled: Bool
//    var darkModeEnabled: Bool
//    var emailNotificationsEnabled: Bool
//}
//
//enum UserStatus {
//    case online
//    case offline
//    case lastSeen(Date)
//    
//    var displayText: String {
//        switch self {
//        case .online:
//            return "Online Now"
//        case .offline:
//            return "Offline"
//        case .lastSeen(let date):
//            let formatter = RelativeDateTimeFormatter()
//            return "Last seen " + formatter.localizedString(for: date, relativeTo: Date())
//        }
//    }
//}
//// DataModel.swift
//import Foundation
//
//enum ProductCategory: String, Codable, CaseIterable {
//    case vegetables = "vegetables"
//    case fruits = "fruits"
//    case grains = "grains"
//    case pulses = "pulses"
//    case dairy = "dairy"
//    case spices = "spices"
//    case organic = "organic"
//}
//
//enum ProductStatus: String, Codable {
//    case available = "Available"
//    case soldOut = "Sold Out"
//}
//
//struct Product: Identifiable, Codable {
//    var id: UUID
//    var name: String
//    var category: ProductCategory
//    var pricePerKg: Double
//    var quantityAvailable: Double
//    var originalQuantity: Double
//    var description: String
//    var imageNames: [String]
//    var imageUrls: [String]
//    var status: ProductStatus
//    var expiryDate: Date
//    var farmerId: UUID
//    var rating: Double?
//    var reviewsCount: Int
//    var reviews: [String]?
//    
//    enum CodingKeys: String, CodingKey {
//        case id, name, category
//        case pricePerKg = "price_per_kg"
//        case quantityAvailable = "quantity_available"
//        case originalQuantity = "original_quantity"
//        case description
//        case imageNames = "image_names"
//        case imageUrls = "image_urls"
//        case status
//        case expiryDate = "expiry_date"
//        case farmerId = "farmer_id"
//        case rating
//        case reviewsCount = "reviews_count"
//        case reviews
//    }
//    
//    // Custom initializer for direct creation
//    init(
//        id: UUID = UUID(),
//        name: String,
//        category: ProductCategory,
//        pricePerKg: Double,
//        quantityAvailable: Double,
//        originalQuantity: Double,
//        description: String,
//        imageNames: [String],
//        imageUrls: [String],
//        status: ProductStatus,
//        expiryDate: Date,
//        farmerId: UUID,
//        rating: Double?,
//        reviewsCount: Int,
//        reviews: [String]?
//    ) {
//        self.id = id
//        self.name = name
//        self.category = category
//        self.pricePerKg = pricePerKg
//        self.quantityAvailable = quantityAvailable
//        self.originalQuantity = originalQuantity
//        self.description = description
//        self.imageNames = imageNames
//        self.imageUrls = imageUrls
//        self.status = status
//        self.expiryDate = expiryDate
//        self.farmerId = farmerId
//        self.rating = rating
//        self.reviewsCount = reviewsCount
//        self.reviews = reviews
//    }
//    
//    // Codable: Decode from Supabase
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        id = try container.decode(UUID.self, forKey: .id)
//        name = try container.decode(String.self, forKey: .name)
//        category = try container.decode(ProductCategory.self, forKey: .category)
//        pricePerKg = try container.decode(Double.self, forKey: .pricePerKg)
//        quantityAvailable = try container.decode(Double.self, forKey: .quantityAvailable)
//        originalQuantity = try container.decode(Double.self, forKey: .originalQuantity)
//        description = try container.decode(String.self, forKey: .description)
//        imageNames = try container.decode([String].self, forKey: .imageNames)
//        imageUrls = try container.decode([String].self, forKey: .imageUrls)
//        status = try container.decode(ProductStatus.self, forKey: .status)
//        farmerId = try container.decode(UUID.self, forKey: .farmerId)
//        rating = try container.decodeIfPresent(Double.self, forKey: .rating)
//        reviewsCount = try container.decode(Int.self, forKey: .reviewsCount)
//        reviews = try container.decodeIfPresent([String].self, forKey: .reviews)
//        
//        // Decode expiry_date as ISO 8601 string
//        let dateString = try container.decode(String.self, forKey: .expiryDate)
//        let formatter = ISO8601DateFormatter()
//        guard let date = formatter.date(from: dateString) else {
//            throw DecodingError.dataCorruptedError(forKey: .expiryDate, in: container, debugDescription: "Invalid ISO 8601 date format")
//        }
//        expiryDate = date
//    }
//    
//    // Codable: Encode to Supabase
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(id, forKey: .id)
//        try container.encode(name, forKey: .name)
//        try container.encode(category, forKey: .category)
//        try container.encode(pricePerKg, forKey: .pricePerKg)
//        try container.encode(quantityAvailable, forKey: .quantityAvailable)
//        try container.encode(originalQuantity, forKey: .originalQuantity)
//        try container.encode(description, forKey: .description)
//        try container.encode(imageNames, forKey: .imageNames)
//        try container.encode(imageUrls, forKey: .imageUrls)
//        try container.encode(status, forKey: .status)
//        try container.encode(farmerId, forKey: .farmerId)
//        try container.encodeIfPresent(rating, forKey: .rating)
//        try container.encode(reviewsCount, forKey: .reviewsCount)
//        try container.encodeIfPresent(reviews, forKey: .reviews)
//        
//        // Encode expiry_date as ISO 8601 string
//        let formatter = ISO8601DateFormatter()
//        try container.encode(formatter.string(from: expiryDate), forKey: .expiryDate)
//    }
//    
//    var formattedPrice: String {
//        String(format: "₹%.2f/kg", pricePerKg)
//    }
//}
//
//// MARK: - Order Models
//struct OrderHistory: Codable {
//    let orderId: String
//    let items: [CartItem]
//    let totalPrice: Double
//    let shippingCost: Double
//    let orderDate: Date
//}
//
//struct Order: Identifiable {
//    let id: UUID
//    let fullName: String
//    let address: String
//    let city: String
//    let state: String
//    let zipCode: String
//    let total: Double
//}
//
//struct OrderItem {
//    var product: Product
//    var quantity: Int
//    var price: Double
//}
//
//enum OrderStatus {
//    case pending
//    case approved
//    case processing
//    case shipped
//    case delivered
//    case cancelled
//}
//
//// MARK: - Cart Model
////struct CartItem1: Codable {
////    let id: UUID
////    let name: String
////    let details: String
////    let pricePerUnit: Int
////    var quantity: Int
////    let imageName: String?
////    
////    init(product: Product) {
////        self.id = product.id
////        self.name = product.name
////        self.details = product.description
////        self.pricePerUnit = Int(product.pricePerKg)
////        self.quantity = 1
////        self.imageName = product.imageNames.first
////    }
////}
////
//struct Cart {
//    var items: [OrderItem]
//    
//    var subtotal: Double {
//        return items.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
//    }
//    
//    var shippingCost: Double {
//        return subtotal > 0 ? 200 : 0
//    }
//    
//    var total: Double {
//        return subtotal + shippingCost
//    }
//}
////struct CartItem: Identifiable, Codable {
////    let id: UUID
////    let cart_id: UUID
////    let product_id: UUID
////    let quantity: Int
////    let price: Double
////    
////    // For UI convenience
////    var name: String?
////    var imageUrl: String?
////    
////    var pricePerUnit: Double { price }
////}
////
/////// Optional wrapper struct for INSERT/UPDATE payload
////private struct CartItemUpsert: Encodable {
////    let cart_id: UUID
////    let product_id: UUID
////    let quantity: Int
////    let price: Double
////}
//
//
//// MARK: - Validation Helpers
//struct ProductValidation {
//    static func validateName(_ name: String) -> Bool {
//        return !name.trimmingCharacters(in: .whitespaces).isEmpty
//    }
//    
//    static func validatePrice(_ price: Double) -> Bool {
//        return price > 0
//    }
//    
//    static func validateQuantity(_ quantity: Double) -> Bool {
//        return quantity > 0
//    }
//    
//    static func validateExpiryDate(_ date: Date) -> Bool {
//        return date > Date()
//    }
//    
//    static func validateDescription(_ description: String) -> Bool {
//        return description.trimmingCharacters(in: .whitespaces).count >= 10
//    }
//    
//    static func validateUser(_ user: User) -> Bool {
//        return !user.profile.name.isEmpty && user.profile.hasValidContactNumber()
//    }
//}
//
//// MARK: - Extensions
//extension User {
//    mutating func updateProfile(with newProfile: Profile) {
//        self.profile = newProfile
//    }
//    
//    mutating func updateSettings(with newSettings: UserSettings) {
//        self.settings = newSettings
//    }
//    
//    func isUserTopContributor() -> Bool {
//        return self.metrics.isTopContributor
//    }
//}
//
//extension Profile {
//    mutating func addAddress(_ address: Address) {
//        savedAddresses.append(address)
//    }
//    
//    mutating func updateDefaultAddress(to address: Address) {
//        self.defaultAddress = address
//    }
//    
//    func hasValidContactNumber() -> Bool {
//        return contactNumber.count >= 10 && contactNumber.allSatisfy { $0.isNumber }
//    }
//}
//
//extension Product {
//    mutating func updateQuantity(_ newQuantity: Double) {
//        guard newQuantity >= 0 else { return }
//        self.quantityAvailable = newQuantity
//    }
//    
//    func isAvailable() -> Bool {
//        return status == .available && quantityAvailable > 0
//    }
//    
//    func validateProduct() -> Bool {
//        return ProductValidation.validateName(name) &&
//               ProductValidation.validatePrice(pricePerKg) &&
//               ProductValidation.validateQuantity(quantityAvailable) &&
//               ProductValidation.validateExpiryDate(expiryDate) &&
//               ProductValidation.validateDescription(description)
//    }
//}
//
//extension Cart {
//    mutating func addItem(_ item: OrderItem) {
//        items.append(item)
//    }
//    
//    mutating func removeItem(byProductId productId: UUID) {
//        items.removeAll { $0.product.id == productId }
//    }
//    
//    func isEmpty() -> Bool {
//        return items.isEmpty
//    }
//}
//
//extension Address {
//    func isComplete() -> Bool {
//        return !fullName.isEmpty &&
//               !addressLine1.isEmpty &&
//               !city.isEmpty &&
//               !state.isEmpty &&
//               !zipCode.isEmpty &&
//               !contactNumber.isEmpty
//    }
//}



import Foundation
import UIKit

// MARK: - User Base Models
enum UserRole: String, Codable {
    case buyer
    case farmer
}

struct User: Identifiable, Codable {
    let id: UUID
    var role: UserRole
    var profile: Profile
    var email: String
    var settings: UserSettings
    var status: UserStatus
    var metrics: UserMetrics
}

struct Profile: Codable {
    var name: String
    var username: String
    var email: String
    var contactNumber: String
    var dateOfBirth: Date
    var countryRegion: String
    var joinedDate: Date
    var profileImageUrl: String?
    var defaultAddress: Address?
    var savedAddresses: [Address]
}

// MARK: - Address Model
struct Address: Codable {
    var fullName: String
    var addressLine1: String
    var addressLine2: String?
    var city: String
    var state: String
    var zipCode: String
    var contactNumber: String
    
    var formattedAddress: String {
        return [addressLine1, addressLine2, "\(city), \(state)", zipCode]
            .compactMap { $0 }
            .joined(separator: ", ")
    }
}

struct UserMetrics: Codable {
    var postCount: Int
    var commentCount: Int
    var isTopContributor: Bool
    var rating: Double
    var reviewCount: Int
}

struct UserSettings: Codable {
    var pushNotificationsEnabled: Bool
    var darkModeEnabled: Bool
    var emailNotificationsEnabled: Bool
}

enum UserStatus: Codable {
    case online
    case offline
    case lastSeen(Date)
    
    enum CodingKeys: String, CodingKey {
        case online, offline, lastSeen
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if try container.decodeIfPresent(Bool.self, forKey: .online) == true {
            self = .online
        } else if try container.decodeIfPresent(Bool.self, forKey: .offline) == true {
            self = .offline
        } else {
            let date = try container.decode(Date.self, forKey: .lastSeen)
            self = .lastSeen(date)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .online:
            try container.encode(true, forKey: .online)
        case .offline:
            try container.encode(true, forKey: .offline)
        case .lastSeen(let date):
            try container.encode(date, forKey: .lastSeen)
        }
    }
    
    var displayText: String {
        switch self {
        case .online:
            return "Online Now"
        case .offline:
            return "Offline"
        case .lastSeen(let date):
            let formatter = RelativeDateTimeFormatter()
            return "Last seen " + formatter.localizedString(for: date, relativeTo: Date())
        }
    }
}

// MARK: - Product Models
enum ProductCategory: String, Codable, CaseIterable {
    case vegetables = "vegetables"
    case fruits = "fruits"
    case grains = "grains"
    case pulses = "pulses"
    case dairy = "dairy"
    case spices = "spices"
    case organic = "organic"
}

enum ProductStatus: String, Codable {
    case available = "Available"
    case soldOut = "Sold Out"
}

struct Product: Identifiable, Codable {
    var id: UUID
    var name: String
    var category: ProductCategory
    var pricePerKg: Double
    var quantityAvailable: Double
    var originalQuantity: Double
    var description: String
    var imageNames: [String]
    var imageUrls: [String]
    var status: ProductStatus
    var expiryDate: Date
    var farmerId: UUID
    var rating: Double?
    var reviewsCount: Int
    var reviews: [String]?
    
    enum CodingKeys: String, CodingKey {
        case id, name, category
        case pricePerKg = "price_per_kg"
        case quantityAvailable = "quantity_available"
        case originalQuantity = "original_quantity"
        case description
        case imageNames = "image_names"
        case imageUrls = "image_urls"
        case status
        case expiryDate = "expiry_date"
        case farmerId = "farmer_id"
        case rating
        case reviewsCount = "reviews_count"
        case reviews
    }
    
    init(
        id: UUID = UUID(),
        name: String,
        category: ProductCategory,
        pricePerKg: Double,
        quantityAvailable: Double,
        originalQuantity: Double,
        description: String,
        imageNames: [String],
        imageUrls: [String],
        status: ProductStatus,
        expiryDate: Date,
        farmerId: UUID,
        rating: Double?,
        reviewsCount: Int,
        reviews: [String]?
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.pricePerKg = pricePerKg
        self.quantityAvailable = quantityAvailable
        self.originalQuantity = originalQuantity
        self.description = description
        self.imageNames = imageNames
        self.imageUrls = imageUrls
        self.status = status
        self.expiryDate = expiryDate
        self.farmerId = farmerId
        self.rating = rating
        self.reviewsCount = reviewsCount
        self.reviews = reviews
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        category = try container.decode(ProductCategory.self, forKey: .category)
        pricePerKg = try container.decode(Double.self, forKey: .pricePerKg)
        quantityAvailable = try container.decode(Double.self, forKey: .quantityAvailable)
        originalQuantity = try container.decode(Double.self, forKey: .originalQuantity)
        description = try container.decode(String.self, forKey: .description)
        imageNames = try container.decode([String].self, forKey: .imageNames)
        imageUrls = try container.decode([String].self, forKey: .imageUrls)
        status = try container.decode(ProductStatus.self, forKey: .status)
        farmerId = try container.decode(UUID.self, forKey: .farmerId)
        rating = try container.decodeIfPresent(Double.self, forKey: .rating)
        reviewsCount = try container.decode(Int.self, forKey: .reviewsCount)
        reviews = try container.decodeIfPresent([String].self, forKey: .reviews)
        
        let dateString = try container.decode(String.self, forKey: .expiryDate)
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: dateString) else {
            throw DecodingError.dataCorruptedError(forKey: .expiryDate, in: container, debugDescription: "Invalid ISO 8601 date format")
        }
        expiryDate = date
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(category, forKey: .category)
        try container.encode(pricePerKg, forKey: .pricePerKg)
        try container.encode(quantityAvailable, forKey: .quantityAvailable)
        try container.encode(originalQuantity, forKey: .originalQuantity)
        try container.encode(description, forKey: .description)
        try container.encode(imageNames, forKey: .imageNames)
        try container.encode(imageUrls, forKey: .imageUrls)
        try container.encode(status, forKey: .status)
        try container.encode(farmerId, forKey: .farmerId)
        try container.encodeIfPresent(rating, forKey: .rating)
        try container.encode(reviewsCount, forKey: .reviewsCount)
        try container.encodeIfPresent(reviews, forKey: .reviews)
        
        let formatter = ISO8601DateFormatter()
        try container.encode(formatter.string(from: expiryDate), forKey: .expiryDate)
    }
    
    var formattedPrice: String {
        String(format: "₹%.2f/kg", pricePerKg)
    }
}

// MARK: - Order Models
struct OrderHistory: Codable {
    let orderId: String
    let items: [CartItem]
    let totalPrice: Double
    let shippingCost: Double
    let orderDate: Date
}

struct Order: Identifiable, Codable {
    let id: UUID
    let fullName: String
    let address: String
    let city: String
    let state: String
    let zipCode: String
    let total: Double
}

struct OrderItem: Codable {
    var product: Product
    var quantity: Int
    var price: Double
}

enum OrderStatus: String, Codable {
    case pending
    case approved
    case processing
    case shipped
    case delivered
    case cancelled
}

// MARK: - Cart Model
struct Cart: Codable {
    var items: [OrderItem]
    
    var subtotal: Double {
        return items.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
    }
    
    var shippingCost: Double {
        return subtotal > 0 ? 200 : 0
    }
    
    var total: Double {
        return subtotal + shippingCost
    }
}

// MARK: - Validation Helpers
struct ProductValidation {
    static func validateName(_ name: String) -> Bool {
        return !name.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    static func validatePrice(_ price: Double) -> Bool {
        return price > 0
    }
    
    static func validateQuantity(_ quantity: Double) -> Bool {
        return quantity > 0
    }
    
    static func validateExpiryDate(_ date: Date) -> Bool {
        return date > Date()
    }
    
    static func validateDescription(_ description: String) -> Bool {
        return description.trimmingCharacters(in: .whitespaces).count >= 10
    }
    
    static func validateUser(_ user: User) -> Bool {
        return !user.profile.name.isEmpty && user.profile.hasValidContactNumber()
    }
}

// MARK: - Extensions
extension User {
    mutating func updateProfile(with newProfile: Profile) {
        self.profile = newProfile
    }
    
    mutating func updateSettings(with newSettings: UserSettings) {
        self.settings = newSettings
    }
    
    func isUserTopContributor() -> Bool {
        return self.metrics.isTopContributor
    }
}

extension Profile {
    mutating func addAddress(_ address: Address) {
        savedAddresses.append(address)
    }
    
    mutating func updateDefaultAddress(to address: Address) {
        self.defaultAddress = address
    }
    
    func hasValidContactNumber() -> Bool {
        return contactNumber.count >= 10 && contactNumber.allSatisfy { $0.isNumber }
    }
}

extension Product {
    mutating func updateQuantity(_ newQuantity: Double) {
        guard newQuantity >= 0 else { return }
        self.quantityAvailable = newQuantity
    }
    
    func isAvailable() -> Bool {
        return status == .available && quantityAvailable > 0
    }
    
    func validateProduct() -> Bool {
        return ProductValidation.validateName(name) &&
               ProductValidation.validatePrice(pricePerKg) &&
               ProductValidation.validateQuantity(quantityAvailable) &&
               ProductValidation.validateExpiryDate(expiryDate) &&
               ProductValidation.validateDescription(description)
    }
}

extension Cart {
    mutating func addItem(_ item: OrderItem) {
        items.append(item)
    }
    
    mutating func removeItem(byProductId productId: UUID) {
        items.removeAll { $0.product.id == productId }
    }
    
    func isEmpty() -> Bool {
        return items.isEmpty
    }
}

extension Address {
    func isComplete() -> Bool {
        return !fullName.isEmpty &&
               !addressLine1.isEmpty &&
               !city.isEmpty &&
               !state.isEmpty &&
               !zipCode.isEmpty &&
               !contactNumber.isEmpty
    }
}
