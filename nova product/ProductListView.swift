//
//  ProductListView.swift
//  nova product
//
//  Created by Mohammadsadra on 10/1/25.
//

import SwiftUI
import SwiftData

struct ProductListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var products: [Product]
    @State private var searchText = ""
    @State private var showNewProduct = false
    
    var filteredProducts: [Product] {
        if searchText.isEmpty {
            return products.sorted { $0.name < $1.name }
        } else {
            return products.filter { product in
                product.name.localizedCaseInsensitiveContains(searchText) ||
                product.barcode.contains(searchText)
            }.sorted { $0.name < $1.name }
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredProducts) { product in
                    NavigationLink(destination: ProductDetailView(product: product)) {
                        ProductRowView(product: product)
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .buttonStyle(PlainButtonStyle())
                }
                .onDelete(perform: deleteProducts)
            }
            .listStyle(PlainListStyle())
            .navigationTitle("Products")
            .searchable(text: $searchText, prompt: "Search products...")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showNewProduct = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
            .sheet(isPresented: $showNewProduct) {
                NewProductView(barcode: "")
            }
        }
    }
    
    private func deleteProducts(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(filteredProducts[index])
            }
        }
    }
}

struct ProductRowView: View {
    let product: Product
    
    var body: some View {
        HStack(spacing: 16) {
            // Product Image with modern styling
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .frame(width: 80, height: 80)
                
                if let imageData = product.image,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    VStack(spacing: 4) {
                        Image(systemName: "photo")
                            .font(.system(size: 24))
                            .foregroundColor(.gray.opacity(0.6))
                        Text("No Image")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            // Product Information
            VStack(alignment: .leading, spacing: 8) {
                // Product Name
                Text(product.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .foregroundColor(.primary)
                
                // Barcode
                HStack {
                    Image(systemName: "barcode")
                        .font(.caption)
                        .foregroundColor(.blue)
                    Text(product.barcode)
                        .font(.caption)
                        .foregroundColor(.blue)
                        .fontWeight(.medium)
                }
                
                // Stock Status
                HStack {
                    Image(systemName: "cube.box")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(product.amount) in stock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    // Stock Status Badge
                    if product.amount > 0 {
                        Text("In Stock")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.2))
                            .foregroundColor(.green)
                            .cornerRadius(8)
                    } else {
                        Text("Out of Stock")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.red.opacity(0.2))
                            .foregroundColor(.red)
                            .cornerRadius(8)
                    }
                }
                
                // Pricing Information
                VStack(alignment: .leading, spacing: 4) {
                    // Sell Price
                    HStack {
                        Text("Sell Price")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(product.sellPrice, specifier: "%.0f") Toman")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                    
                    // Offer Price (if available)
                    if product.offerPrice > 0 {
                        HStack {
                            Text("Offer Price")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(product.offerPrice, specifier: "%.0f") Toman")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.orange)
                        }
                    }
                }
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    ProductListView()
        .modelContainer(for: Product.self, inMemory: true)
}
