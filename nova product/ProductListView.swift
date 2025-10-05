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
                }
                .onDelete(perform: deleteProducts)
            }
            .navigationTitle("Products")
            .searchable(text: $searchText, prompt: "Search products...")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("New Product") {
                        showNewProduct = true
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
        HStack {
            if let imageData = product.image,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.headline)
                    .lineLimit(1)
                
                Text("Barcode: \(product.barcode)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack {
                    Text("Amount: \(product.amount)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(product.sellPrice, specifier: "%.0f") Toman")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ProductListView()
        .modelContainer(for: Product.self, inMemory: true)
}
