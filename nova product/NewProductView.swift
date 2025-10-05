//
//  NewProductView.swift
//  nova product
//
//  Created by Mohammadsadra on 10/1/25.
//

import SwiftUI
import SwiftData
import PhotosUI
import AVFoundation

struct NewProductView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let barcode: String
    
    @State private var name = ""
    @State private var amount = 0
    @State private var buyPrice = 0.0
    @State private var sellPrice = 0.0
    @State private var offerPrice = 0.0
    @State private var specification = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var productImage: Data?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var showingActionSheet = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 8) {
                        Text("New Product")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Barcode: \(barcode)")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top)
                    
                    // Product Image
                    VStack {
                        if let imageData = productImage,
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
                        
                        HStack(spacing: 8) {
                            Button("Camera") {
                                showingCamera = true
                            }
                            .buttonStyle(.bordered)
                            .font(.caption)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                            
                            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                                Text("Gallery")
                            }
                            .buttonStyle(.bordered)
                            .font(.caption)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                            .onChange(of: selectedPhoto) { _, newValue in
                                Task {
                                    if let data = try? await newValue?.loadTransferable(type: Data.self) {
                                        productImage = data
                                    }
                                }
                            }
                            
                            if productImage != nil {
                                Button("Remove") {
                                    productImage = nil
                                }
                                .buttonStyle(.bordered)
                                .foregroundColor(.red)
                                .font(.caption)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                            }
                        }
                    }
                    
                    // Form Fields
                    VStack(spacing: 16) {
                        // Name (Required)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Name *")
                                .font(.headline)
                            TextField("Product Name", text: $name)
                                .textFieldStyle(.roundedBorder)
                        }
                        
                        // Amount
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Amount")
                                .font(.headline)
                            TextField("Amount", value: $amount, format: .number)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.numberPad)
                        }
                        
                        // Prices (Required)
                        VStack(spacing: 16) {
                            HStack(spacing: 20) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Buy Price * (Toman)")
                                        .font(.headline)
                                    TextField("Buy Price", value: $buyPrice, format: .number)
                                        .textFieldStyle(.roundedBorder)
                                        .keyboardType(.decimalPad)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Sell Price * (Toman)")
                                        .font(.headline)
                                    TextField("Sell Price", value: $sellPrice, format: .number)
                                        .textFieldStyle(.roundedBorder)
                                        .keyboardType(.decimalPad)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Offer Price (Toman)")
                                    .font(.headline)
                                TextField("Offer Price", value: $offerPrice, format: .number)
                                    .textFieldStyle(.roundedBorder)
                                    .keyboardType(.decimalPad)
                            }
                        }
                        
                        // Specification
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Specification")
                                .font(.headline)
                            TextField("Specification", text: $specification, axis: .vertical)
                                .textFieldStyle(.roundedBorder)
                                .lineLimit(3...6)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Required Fields Note
                    Text("* Required fields")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
            }
            .navigationTitle("New Product")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveProduct()
                    }
                    .fontWeight(.semibold)
                    .disabled(name.isEmpty || buyPrice <= 0 || sellPrice <= 0)
                }
            }
            .alert("Error", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
            .sheet(isPresented: $showingCamera) {
                PhotoCaptureView { image in
                    if let image = image {
                        productImage = image.jpegData(compressionQuality: 0.8)
                    }
                    showingCamera = false
                }
            }
        }
    }
    
    private func saveProduct() {
        // Validate required fields
        guard !name.isEmpty else {
            alertMessage = "Product name is required"
            showingAlert = true
            return
        }
        
        guard buyPrice > 0 else {
            alertMessage = "Buy price must be greater than 0"
            showingAlert = true
            return
        }
        
        guard sellPrice > 0 else {
            alertMessage = "Sell price must be greater than 0"
            showingAlert = true
            return
        }
        
        // Create new product
        let newProduct = Product(
            name: name,
            barcode: barcode,
            image: productImage,
            amount: amount,
            buyPrice: buyPrice,
            sellPrice: sellPrice,
            offerPrice: offerPrice,
            specification: specification
        )
        
        modelContext.insert(newProduct)
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            alertMessage = "Failed to save product: \(error.localizedDescription)"
            showingAlert = true
        }
    }
}

#Preview {
    NewProductView(barcode: "123456789")
        .modelContainer(for: Product.self, inMemory: true)
}
