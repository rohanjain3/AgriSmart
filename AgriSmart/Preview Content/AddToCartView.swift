import SwiftUI
import Supabase
import Kingfisher

// MARK: — CartItem Model

/// Mirrors your cart_items table plus some UI convenience fields
struct CartItem: Identifiable, Codable {
    let id: UUID
    let cart_id: UUID
    let product_id: UUID
    let quantity: Int
    let price: Double
    
    // Populated client-side after decoding
    var name: String?
    var imageUrl: String?
    
    var pricePerUnit: Double { price }
}

/// Payload for upserting a cart item
private struct CartItemUpsert: Encodable {
    let cart_id: UUID
    let product_id: UUID
    let quantity: Int
    let price: Double
}

// MARK: — CartManager

@MainActor
class CartManager: ObservableObject {
    static let shared = CartManager()
    
    @Published private(set) var cartItems: [CartItem] = []
    @Published private(set) var cartId: UUID?
    
    private init() {
        Task { await loadCart() }
    }
    
    /// Load or create cart for current user and fetch its items
    func loadCart() async {
        do {
            // Ensure cart exists for this user
            if cartId == nil {
                guard let session = try? await SupabaseManager.shared.fetchUserSession() else {
                    print("🔴 No user session found")
                    return
                }
                let userId = session.user.id.uuidString
                
                // Try to find existing cart
                let selectResp = try await SupabaseManager.shared.client
                    .from("carts")
                    .select("id")
                    .eq("user_id", value: userId)
                    .single()
                    .execute()
                
                if let row = selectResp.value as? [String: Any],
                   let idString = row["id"] as? String,
                   let uuid = UUID(uuidString: idString) {
                    cartId = uuid
                } else {
                    // Create new cart
                    let insertResp = try await SupabaseManager.shared.client
                        .from("carts")
                        .insert(["user_id": userId], returning: .representation)
                        .single()
                        .execute()
                    if let data = insertResp.value as? [String: Any],
                       let idString = data["id"] as? String,
                       let uuid = UUID(uuidString: idString) {
                        cartId = uuid
                    }
                }
            }
            
            // Fetch cart items with joined product info
            guard let cId = cartId?.uuidString else { return }
            let itemsResp = try await SupabaseManager.shared.client
                .from("cart_items")
                .select("*, products(name, image_urls)")
                .eq("cart_id", value: cId)
                .execute()
            
            if let rows = itemsResp.value as? [[String: Any]] {
                var loadedItems: [CartItem] = []
                for row in rows {
                    if let prod = row["products"] as? [String: Any] {
                        do {
                            let jsonData = try JSONSerialization.data(withJSONObject: row)
                            var item = try JSONDecoder().decode(CartItem.self, from: jsonData)
                            item.name = prod["name"] as? String
                            if let urls = prod["image_urls"] as? [String], let first = urls.first {
                                item.imageUrl = first
                            }
                            loadedItems.append(item)
                        } catch {
                            print("🔴 Error decoding cart item: \(error)")
                        }
                    }
                }
                cartItems = loadedItems
            }
        } catch {
            print("🔴 Cart load error:", error)
        }
    }
    
    /// Add or update a product in cart
    func addProduct(_ product: Product, quantity: Int = 1) async {
        guard let cId = cartId else {
            print("🔴 No cart id available")
            return
        }
        
        let upsert = CartItemUpsert(
            cart_id: cId,
            product_id: product.id,
            quantity: quantity,
            price: product.pricePerKg
        )
        
        do {
            _ = try await SupabaseManager.shared.client
                .from("cart_items")
                .upsert(upsert, onConflict: "product_id")
                .execute()
            await loadCart()  // Refresh cart after adding
        } catch {
            print("🔴 Add to cart error:", error)
        }
    }
    
    /// Update quantity of a cart item
    func updateQuantity(itemId: UUID, quantity: Int) async {
        do {
            _ = try await SupabaseManager.shared.client
                .from("cart_items")
                .update(["quantity": quantity])
                .eq("id", value: itemId.uuidString)
                .execute()
            await loadCart()  // Refresh cart after updating
        } catch {
            print("🔴 Update quantity error:", error)
        }
    }
    
    /// Remove cart items by IDs
    func removeItems(itemIds: [UUID]) async {
        let idStrings = itemIds.map { $0.uuidString }
        do {
            _ = try await SupabaseManager.shared.client
                .from("cart_items")
                .delete()
                .in("id", value: idStrings)
                .execute()
            await loadCart()  // Refresh cart after deletion
        } catch {
            print("🔴 Delete cart items error:", error)
        }
    }
    
    // MARK: Computed totals
    
    var subtotal: Double {
        cartItems.reduce(0) { $0 + $1.price * Double($1.quantity) }
    }
    
    var shipping: Double {
        subtotal > 0 ? 200 : 0
    }
    
    var total: Double {
        subtotal + shipping
    }
}

// MARK: — AddToCartView (Full Cart Screen)

struct AddToCartView: View {
    @StateObject private var cartManager = CartManager.shared

    var body: some View {
        NavigationStack {
            VStack {
                Text("Total: ₹\(Int(cartManager.total))")
                    .font(.title).bold()
                    .padding()

                if cartManager.cartItems.isEmpty {
                    Text("Your cart is empty")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List {
                        ForEach(cartManager.cartItems) { item in
                            CartItemRow(item: item)
                        }
                        .onDelete { idx in
                            let ids = idx.map { cartManager.cartItems[$0].id }
                            Task { await cartManager.removeItems(itemIds: ids) }
                        }
                    }
                    .listStyle(PlainListStyle())
                }

                NavigationLink(destination: CheckoutView(totalAmount: cartManager.total)) {
                    Text("Proceed to Checkout")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(cartManager.total > 0 ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(cartManager.total <= 0)
                .padding()
            }
            .navigationTitle("Cart")
            .refreshable { await cartManager.loadCart() }
        }
    }
}

// MARK: — CartItemRow (for listing each cart item)

struct CartItemRow: View {
    let item: CartItem
    @State private var quantity: Int

    init(item: CartItem) {
        self.item = item
        self._quantity = State(initialValue: item.quantity)
    }

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            if let url = item.imageUrl, let imgURL = URL(string: url) {
                KFImage(imgURL)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .cornerRadius(8)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 80, height: 80)
                    .cornerRadius(8)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(item.name ?? "")
                    .font(.headline)
                Text("₹\(item.pricePerUnit, specifier: "%.2f") per kg")
                    .font(.subheadline).foregroundColor(.gray)
                Text("Total: ₹\((item.pricePerUnit * Double(quantity)), specifier: "%.2f")")
                    .font(.subheadline).foregroundColor(.gray)
            }

            Spacer()

            HStack(spacing: 8) {
                Button {
                    if quantity > 1 { quantity -= 1 }
                } label: {
                    Image(systemName: "minus.circle")
                        .font(.title2)
                }

                Text("\(quantity)")
                    .frame(width: 30)

                Button {
                    quantity += 1
                } label: {
                    Image(systemName: "plus.circle")
                        .font(.title2)
                }
            }
            .buttonStyle(.borderless)
            .onChange(of: quantity) { newQty in
                Task { await CartManager.shared.updateQuantity(itemId: item.id, quantity: newQty) }
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: — CheckoutView Placeholder (You can implement your checkout logic here)

struct CheckoutView: View {
    let totalAmount: Double
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Checkout")
                .font(.largeTitle).bold()
            Text("Total amount: ₹\(Int(totalAmount))")
                .font(.title2)
            Spacer()
            Text("Checkout flow to be implemented.")
                .foregroundColor(.gray)
            Spacer()
        }
        .padding()
        .navigationTitle("Checkout")
    }
}
