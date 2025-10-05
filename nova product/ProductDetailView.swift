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
                VStack(spacing: 32) {
                    // Hero Section with Product Image
                    VStack(spacing: 32) {
                        // Product Image with enhanced styling
                        ZStack {
                            RoundedRectangle(cornerRadius: 24)
                                .fill(
                                    LinearGradient(
                                        colors: [Color(.systemGray6), Color(.systemGray5)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(height: 320)
                                .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
                            
                            if let imageData = editedProduct.image,
                               let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 320)
                                    .clipShape(RoundedRectangle(cornerRadius: 24))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 24)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 2)
                                    )
                            } else {
                                VStack(spacing: 20) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.white.opacity(0.3))
                                            .frame(width: 100, height: 100)
                                        Image(systemName: "photo")
                                            .font(.system(size: 50, weight: .light))
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                    Text("No Image")
                                        .font(.title2)
                                        .fontWeight(.medium)
                                        .foregroundColor(.white.opacity(0.9))
                                }
                            }
                        }
                        
                        // Image editing controls with enhanced styling
                        if isEditing {
                            VStack(spacing: 20) {
                                Text("Update Product Image")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                
                                HStack(spacing: 16) {
                                    Button(action: { showingCamera = true }) {
                                        HStack(spacing: 8) {
                                            Image(systemName: "camera.fill")
                                            Text("Camera")
                                        }
                                        .foregroundColor(.white)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .padding(.horizontal, 24)
                                        .padding(.vertical, 14)
                                        .background(
                                            LinearGradient(
                                                colors: [Color.blue, Color.blue.opacity(0.8)],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                        .cornerRadius(30)
                                        .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                                    }
                                    
                                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                                        HStack(spacing: 8) {
                                            Image(systemName: "photo.on.rectangle.fill")
                                            Text("Gallery")
                                        }
                                        .foregroundColor(.white)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .padding(.horizontal, 24)
                                        .padding(.vertical, 14)
                                        .background(
                                            LinearGradient(
                                                colors: [Color.green, Color.green.opacity(0.8)],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                        .cornerRadius(30)
                                        .shadow(color: .green.opacity(0.3), radius: 8, x: 0, y: 4)
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
                                                Image(systemName: "trash.fill")
                                                Text("Remove")
                                            }
                                            .foregroundColor(.white)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .padding(.horizontal, 24)
                                            .padding(.vertical, 14)
                                            .background(
                                                LinearGradient(
                                                    colors: [Color.red, Color.red.opacity(0.8)],
                                                    startPoint: .top,
                                                    endPoint: .bottom
                                                )
                                            )
                                            .cornerRadius(30)
                                            .shadow(color: .red.opacity(0.3), radius: 8, x: 0, y: 4)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 20)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
                            )
                        }
                    }
                    
                    // Product Information Cards
                    VStack(spacing: 24) {
                        // Basic Info Card with enhanced styling
                        VStack(alignment: .leading, spacing: 24) {
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(Color.blue.opacity(0.1))
                                        .frame(width: 48, height: 48)
                                    Image(systemName: "info.circle.fill")
                                        .foregroundColor(.blue)
                                        .font(.title2)
                                }
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Product Information")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                    Text("Basic product details")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                            }
                            
                            VStack(spacing: 20) {
                                // Name with enhanced styling
                                VStack(alignment: .leading, spacing: 16) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "tag.fill")
                                            .foregroundColor(.blue)
                                            .font(.caption)
                                        Text("Product Name")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.secondary)
                                    }
                                    if isEditing {
                                        TextField("Product Name", text: $editedProduct.name)
                                            .textFieldStyle(.roundedBorder)
                                            .font(.body)
                                    } else {
                                        Text(product.name)
                                            .font(.title3)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.primary)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                .background(Color.blue.opacity(0.05))
                                .cornerRadius(12)
                                
                                // Barcode with enhanced styling
                                VStack(alignment: .leading, spacing: 16) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "barcode")
                                            .foregroundColor(.blue)
                                            .font(.caption)
                                        Text("Barcode")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.secondary)
                                    }
                                    if isEditing {
                                        TextField("Barcode", text: $editedProduct.barcode)
                                            .textFieldStyle(.roundedBorder)
                                            .font(.body)
                                    } else {
                                        Text(product.barcode)
                                            .font(.title3)
                                            .fontWeight(.medium)
                                            .foregroundColor(.blue)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                .background(Color.blue.opacity(0.05))
                                .cornerRadius(12)
                                
                                // Amount with enhanced styling
                                VStack(alignment: .leading, spacing: 16) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "cube.box.fill")
                                            .foregroundColor(.blue)
                                            .font(.caption)
                                        Text("Stock Amount")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.secondary)
                                    }
                                    if isEditing {
                                        TextField("Amount", value: $editedProduct.amount, format: .number)
                                            .textFieldStyle(.roundedBorder)
                                            .keyboardType(.numberPad)
                                            .font(.body)
                                    } else {
                                        HStack {
                                            Text("\(product.amount) units")
                                                .font(.title3)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.primary)
                                            Spacer()
                                            if product.amount > 0 {
                                                HStack(spacing: 6) {
                                                    Circle()
                                                        .fill(Color.green)
                                                        .frame(width: 8, height: 8)
                                                    Text("In Stock")
                                                        .font(.caption)
                                                        .fontWeight(.medium)
                                                        .padding(.horizontal, 12)
                                                        .padding(.vertical, 6)
                                                        .background(Color.green.opacity(0.15))
                                                        .foregroundColor(.green)
                                                        .cornerRadius(12)
                                                }
                                            } else {
                                                HStack(spacing: 6) {
                                                    Circle()
                                                        .fill(Color.red)
                                                        .frame(width: 8, height: 8)
                                                    Text("Out of Stock")
                                                        .font(.caption)
                                                        .fontWeight(.medium)
                                                        .padding(.horizontal, 12)
                                                        .padding(.vertical, 6)
                                                        .background(Color.red.opacity(0.15))
                                                        .foregroundColor(.red)
                                                        .cornerRadius(12)
                                                }
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                .background(Color.blue.opacity(0.05))
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal, 28)
                        .padding(.vertical, 24)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.08), radius: 15, x: 0, y: 8)
                        )
                        
                        // Pricing Card with enhanced styling
                        VStack(alignment: .leading, spacing: 24) {
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(Color.green.opacity(0.1))
                                        .frame(width: 48, height: 48)
                                    Image(systemName: "dollarsign.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.title2)
                                }
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Pricing Information")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                    Text("Cost and selling prices")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                            }
                            
                            VStack(spacing: 20) {
                                // Buy Price with enhanced styling
                                VStack(alignment: .leading, spacing: 16) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "arrow.down.circle.fill")
                                            .foregroundColor(.blue)
                                            .font(.caption)
                                        Text("Buy Price")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.secondary)
                                    }
                                    if isEditing {
                                        TextField("Buy Price", value: $editedProduct.buyPrice, format: .number)
                                            .textFieldStyle(.roundedBorder)
                                            .keyboardType(.decimalPad)
                                            .font(.body)
                                    } else {
                                        HStack {
                                            Text("\(product.buyPrice, specifier: "%.0f")")
                                                .font(.title2)
                                                .fontWeight(.bold)
                                                .foregroundColor(.blue)
                                            Text("Toman")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                            Spacer()
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        colors: [Color.blue.opacity(0.08), Color.blue.opacity(0.03)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                                )
                                
                                // Sell Price with enhanced styling
                                VStack(alignment: .leading, spacing: 16) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "arrow.up.circle.fill")
                                            .foregroundColor(.green)
                                            .font(.caption)
                                        Text("Sell Price")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.secondary)
                                    }
                                    if isEditing {
                                        TextField("Sell Price", value: $editedProduct.sellPrice, format: .number)
                                            .textFieldStyle(.roundedBorder)
                                            .keyboardType(.decimalPad)
                                            .font(.body)
                                    } else {
                                        HStack {
                                            Text("\(product.sellPrice, specifier: "%.0f")")
                                                .font(.title2)
                                                .fontWeight(.bold)
                                                .foregroundColor(.green)
                                            Text("Toman")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                            Spacer()
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        colors: [Color.green.opacity(0.08), Color.green.opacity(0.03)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.green.opacity(0.2), lineWidth: 1)
                                )
                                
                                // Offer Price with enhanced styling
                                if product.offerPrice > 0 || isEditing {
                                    VStack(alignment: .leading, spacing: 16) {
                                        HStack(spacing: 8) {
                                            Image(systemName: "tag.circle.fill")
                                                .foregroundColor(.orange)
                                                .font(.caption)
                                            Text("Offer Price")
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.secondary)
                                        }
                                        if isEditing {
                                            TextField("Offer Price", value: $editedProduct.offerPrice, format: .number)
                                                .textFieldStyle(.roundedBorder)
                                                .keyboardType(.decimalPad)
                                                .font(.body)
                                        } else {
                                            HStack {
                                                Text("\(product.offerPrice, specifier: "%.0f")")
                                                    .font(.title2)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(.orange)
                                                Text("Toman")
                                                    .font(.subheadline)
                                                    .foregroundColor(.secondary)
                                                Spacer()
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 16)
                                    .background(
                                        LinearGradient(
                                            colors: [Color.orange.opacity(0.08), Color.orange.opacity(0.03)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.orange.opacity(0.2), lineWidth: 1)
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 28)
                        .padding(.vertical, 24)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.08), radius: 15, x: 0, y: 8)
                        )
                        
                        // Specification Card with enhanced styling
                        VStack(alignment: .leading, spacing: 24) {
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(Color.purple.opacity(0.1))
                                        .frame(width: 48, height: 48)
                                    Image(systemName: "doc.text.fill")
                                        .foregroundColor(.purple)
                                        .font(.title2)
                                }
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Specification")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                    Text("Product details and notes")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                            }
                            
                            VStack(alignment: .leading, spacing: 16) {
                                HStack(spacing: 8) {
                                    Image(systemName: "note.text")
                                        .foregroundColor(.purple)
                                        .font(.caption)
                                    Text("Description")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.secondary)
                                }
                                
                                if isEditing {
                                    TextField("Specification", text: $editedProduct.specification, axis: .vertical)
                                        .textFieldStyle(.roundedBorder)
                                        .lineLimit(3...6)
                                        .font(.body)
                                } else {
                                    Text(product.specification.isEmpty ? "No specification provided" : product.specification)
                                        .font(.body)
                                        .foregroundColor(product.specification.isEmpty ? .secondary : .primary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(16)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(product.specification.isEmpty ? Color(.systemGray6) : Color.purple.opacity(0.05))
                                        )
                                }
                            }
                        }
                        .padding(.horizontal, 28)
                        .padding(.vertical, 24)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.08), radius: 15, x: 0, y: 8)
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
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
