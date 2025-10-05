//
//  ProductDetailView.swift
//  nova product
//
//  Created by Mohammadsadra on 10/1/25.
//

import SwiftUI
import SwiftData
import PhotosUI
import AVFoundation

struct ProductDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let product: Product
    @State private var isEditing = false
    @State private var editedProduct: ProductData
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    
    init(product: Product) {
        self.product = product
        self._editedProduct = State(initialValue: ProductData(
            name: product.name,
            barcode: product.barcode,
            amount: product.amount,
            buyPrice: product.buyPrice,
            sellPrice: product.sellPrice,
            offerPrice: product.offerPrice,
            specification: product.specification,
            image: product.image
        ))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Hero Section with Product Image
                    VStack(spacing: 20) {
                        // Product Image with modern styling
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(.systemGray6))
                                .frame(height: 280)
                                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                            
                            if let imageData = editedProduct.image,
                               let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 280)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                            } else {
                                VStack(spacing: 16) {
                                    Image(systemName: "photo")
                                        .font(.system(size: 60))
                                        .foregroundColor(.gray.opacity(0.6))
                                    Text("No Image")
                                        .font(.headline)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        
                        // Image editing controls
                        if isEditing {
                            HStack(spacing: 16) {
                                Button(action: { showingCamera = true }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "camera")
                                        Text("Camera")
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 12)
                                    .background(Color.blue)
                                    .cornerRadius(25)
                                }
                                
                                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "photo.on.rectangle")
                                        Text("Gallery")
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 12)
                                    .background(Color.green)
                                    .cornerRadius(25)
                                }
                                .onChange(of: selectedPhoto) { _, newValue in
                                    Task {
                                        if let data = try? await newValue?.loadTransferable(type: Data.self) {
                                            editedProduct.image = data
                                        }
                                    }
                                }
                                
                                if editedProduct.image != nil {
                                    Button(action: { editedProduct.image = nil }) {
                                        HStack(spacing: 8) {
                                            Image(systemName: "trash")
                                            Text("Remove")
                                        }
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 12)
                                        .background(Color.red)
                                        .cornerRadius(25)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Product Information Cards
                    VStack(spacing: 20) {
                        // Basic Info Card
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "info.circle.fill")
                                    .foregroundColor(.blue)
                                Text("Product Information")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                Spacer()
                            }
                            
                            VStack(spacing: 16) {
                                // Name
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Product Name")
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                    if isEditing {
                                        TextField("Product Name", text: $editedProduct.name)
                                            .textFieldStyle(.roundedBorder)
                                    } else {
                                        Text(product.name)
                                            .font(.title3)
                                            .fontWeight(.semibold)
                                    }
                                }
                                
                                // Barcode
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Barcode")
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                    if isEditing {
                                        TextField("Barcode", text: $editedProduct.barcode)
                                            .textFieldStyle(.roundedBorder)
                                    } else {
                                        Text(product.barcode)
                                            .font(.title3)
                                            .fontWeight(.medium)
                                            .foregroundColor(.blue)
                                    }
                                }
                                
                                // Amount
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Stock Amount")
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                    if isEditing {
                                        TextField("Amount", value: $editedProduct.amount, format: .number)
                                            .textFieldStyle(.roundedBorder)
                                            .keyboardType(.numberPad)
                                    } else {
                                        HStack {
                                            Text("\(product.amount)")
                                                .font(.title3)
                                                .fontWeight(.semibold)
                                            Spacer()
                                            if product.amount > 0 {
                                                Text("In Stock")
                                                    .font(.caption)
                                                    .padding(.horizontal, 8)
                                                    .padding(.vertical, 4)
                                                    .background(Color.green.opacity(0.2))
                                                    .foregroundColor(.green)
                                                    .cornerRadius(8)
                                            } else {
                                                Text("Out of Stock")
                                                    .font(.caption)
                                                    .padding(.horizontal, 8)
                                                    .padding(.vertical, 4)
                                                    .background(Color.red.opacity(0.2))
                                                    .foregroundColor(.red)
                                                    .cornerRadius(8)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(20)
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                        
                        // Pricing Card
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "dollarsign.circle.fill")
                                    .foregroundColor(.green)
                                Text("Pricing Information")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                Spacer()
                            }
                            
                            VStack(spacing: 16) {
                                // Buy Price
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Buy Price")
                                            .font(.headline)
                                            .foregroundColor(.secondary)
                                        if isEditing {
                                            TextField("Buy Price", value: $editedProduct.buyPrice, format: .number)
                                                .textFieldStyle(.roundedBorder)
                                                .keyboardType(.decimalPad)
                                        } else {
                                            Text("\(product.buyPrice, specifier: "%.0f") Toman")
                                                .font(.title3)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.blue)
                                        }
                                    }
                                    Spacer()
                                    Image(systemName: "arrow.down.circle.fill")
                                        .foregroundColor(.blue)
                                        .font(.title2)
                                }
                                .padding(16)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(12)
                                
                                // Sell Price
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Sell Price")
                                            .font(.headline)
                                            .foregroundColor(.secondary)
                                        if isEditing {
                                            TextField("Sell Price", value: $editedProduct.sellPrice, format: .number)
                                                .textFieldStyle(.roundedBorder)
                                                .keyboardType(.decimalPad)
                                        } else {
                                            Text("\(product.sellPrice, specifier: "%.0f") Toman")
                                                .font(.title3)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.green)
                                        }
                                    }
                                    Spacer()
                                    Image(systemName: "arrow.up.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.title2)
                                }
                                .padding(16)
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(12)
                                
                                // Offer Price (if set)
                                if product.offerPrice > 0 || isEditing {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Offer Price")
                                                .font(.headline)
                                                .foregroundColor(.secondary)
                                            if isEditing {
                                                TextField("Offer Price", value: $editedProduct.offerPrice, format: .number)
                                                    .textFieldStyle(.roundedBorder)
                                                    .keyboardType(.decimalPad)
                                            } else {
                                                Text("\(product.offerPrice, specifier: "%.0f") Toman")
                                                    .font(.title3)
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(.orange)
                                            }
                                        }
                                        Spacer()
                                        Image(systemName: "tag.circle.fill")
                                            .foregroundColor(.orange)
                                            .font(.title2)
                                    }
                                    .padding(16)
                                    .background(Color.orange.opacity(0.1))
                                    .cornerRadius(12)
                                }
                            }
                        }
                        .padding(20)
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                        
                        // Specification Card
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "doc.text.fill")
                                    .foregroundColor(.purple)
                                Text("Specification")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                Spacer()
                            }
                            
                            if isEditing {
                                TextField("Specification", text: $editedProduct.specification, axis: .vertical)
                                    .textFieldStyle(.roundedBorder)
                                    .lineLimit(3...6)
                            } else {
                                Text(product.specification.isEmpty ? "No specification provided" : product.specification)
                                    .font(.body)
                                    .foregroundColor(product.specification.isEmpty ? .secondary : .primary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .padding(20)
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                    }
                }
                .padding()
            }
            .navigationTitle(isEditing ? "Edit Product" : "Product Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isEditing {
                        HStack {
                            Button("Cancel") {
                                isEditing = false
                                resetEditedProduct()
                            }
                            
                            Button("Save") {
                                saveProduct()
                            }
                            .fontWeight(.semibold)
                        }
                    } else {
                        Button("Edit") {
                            isEditing = true
                        }
                    }
                }
            }
            .sheet(isPresented: $showingCamera) {
                PhotoCaptureView { image in
                    if let image = image {
                        editedProduct.image = image.jpegData(compressionQuality: 0.8)
                    }
                    showingCamera = false
                }
            }
        }
    }
    
    private func resetEditedProduct() {
        editedProduct = ProductData(
            name: product.name,
            barcode: product.barcode,
            amount: product.amount,
            buyPrice: product.buyPrice,
            sellPrice: product.sellPrice,
            offerPrice: product.offerPrice,
            specification: product.specification,
            image: product.image
        )
    }
    
    private func saveProduct() {
        product.name = editedProduct.name
        product.barcode = editedProduct.barcode
        product.amount = editedProduct.amount
        product.buyPrice = editedProduct.buyPrice
        product.sellPrice = editedProduct.sellPrice
        product.offerPrice = editedProduct.offerPrice
        product.specification = editedProduct.specification
        product.image = editedProduct.image
        
        isEditing = false
    }
}

struct ProductData {
    var name: String
    var barcode: String
    var amount: Int
    var buyPrice: Double
    var sellPrice: Double
    var offerPrice: Double
    var specification: String
    var image: Data?
}

#Preview {
    let product = Product(name: "Sample Product", barcode: "123456789", amount: 10, buyPrice: 5.0, sellPrice: 10.0, offerPrice: 8.0, specification: "Sample specification")
    ProductDetailView(product: product)
        .modelContainer(for: Product.self, inMemory: true)
}
