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
                VStack(spacing: 20) {
                    // Product Image
                    VStack {
                        if let imageData = editedProduct.image,
                           let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 200, height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        } else {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 200, height: 200)
                                .overlay(
                                    VStack {
                                        Image(systemName: "photo")
                                            .font(.system(size: 40))
                                            .foregroundColor(.gray)
                                        Text("No Image")
                                            .foregroundColor(.gray)
                                    }
                                )
                        }
                        
                        if isEditing {
                            HStack(spacing: 12) {
                                Button("Camera") {
                                    showingCamera = true
                                }
                                .buttonStyle(.bordered)
                                
                                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                                    Text("Gallery")
                                        .buttonStyle(.bordered)
                                }
                                .onChange(of: selectedPhoto) { _, newValue in
                                    Task {
                                        if let data = try? await newValue?.loadTransferable(type: Data.self) {
                                            editedProduct.image = data
                                        }
                                    }
                                }
                                
                                if editedProduct.image != nil {
                                    Button("Remove") {
                                        editedProduct.image = nil
                                    }
                                    .buttonStyle(.bordered)
                                    .foregroundColor(.red)
                                }
                            }
                        }
                    }
                    
                    // Product Information
                    VStack(alignment: .leading, spacing: 16) {
                        // Name
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Name")
                                .font(.headline)
                            if isEditing {
                                TextField("Product Name", text: $editedProduct.name)
                                    .textFieldStyle(.roundedBorder)
                            } else {
                                Text(product.name)
                                    .font(.title2)
                            }
                        }
                        
                        // Barcode
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Barcode")
                                .font(.headline)
                            if isEditing {
                                TextField("Barcode", text: $editedProduct.barcode)
                                    .textFieldStyle(.roundedBorder)
                            } else {
                                Text(product.barcode)
                                    .font(.title3)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // Amount
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Amount")
                                .font(.headline)
                            if isEditing {
                                TextField("Amount", value: $editedProduct.amount, format: .number)
                                    .textFieldStyle(.roundedBorder)
                                    .keyboardType(.numberPad)
                            } else {
                                Text("\(product.amount)")
                                    .font(.title3)
                            }
                        }
                        
                        // Prices
                        VStack(spacing: 16) {
                            HStack(spacing: 20) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Buy Price")
                                        .font(.headline)
                                    if isEditing {
                                        TextField("Buy Price", value: $editedProduct.buyPrice, format: .number)
                                            .textFieldStyle(.roundedBorder)
                                            .keyboardType(.decimalPad)
                                    } else {
                                        Text("\(product.buyPrice, specifier: "%.0f") Toman")
                                            .font(.title3)
                                            .foregroundColor(.blue)
                                    }
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Sell Price")
                                        .font(.headline)
                                    if isEditing {
                                        TextField("Sell Price", value: $editedProduct.sellPrice, format: .number)
                                            .textFieldStyle(.roundedBorder)
                                            .keyboardType(.decimalPad)
                                    } else {
                                        Text("\(product.sellPrice, specifier: "%.0f") Toman")
                                            .font(.title3)
                                            .foregroundColor(.green)
                                    }
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Offer Price")
                                    .font(.headline)
                                if isEditing {
                                    TextField("Offer Price", value: $editedProduct.offerPrice, format: .number)
                                        .textFieldStyle(.roundedBorder)
                                        .keyboardType(.decimalPad)
                                } else {
                                    Text("\(product.offerPrice, specifier: "%.0f") Toman")
                                        .font(.title3)
                                        .foregroundColor(.orange)
                                }
                            }
                        }
                        
                        // Specification
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Specification")
                                .font(.headline)
                            if isEditing {
                                TextField("Specification", text: $editedProduct.specification, axis: .vertical)
                                    .textFieldStyle(.roundedBorder)
                                    .lineLimit(3...6)
                            } else {
                                Text(product.specification.isEmpty ? "No specification" : product.specification)
                                    .font(.body)
                                    .foregroundColor(product.specification.isEmpty ? .secondary : .primary)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle(isEditing ? "Edit Product" : "Product Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        if isEditing {
                            isEditing = false
                            resetEditedProduct()
                        } else {
                            dismiss()
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isEditing {
                        Button("Save") {
                            saveProduct()
                        }
                        .fontWeight(.semibold)
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
