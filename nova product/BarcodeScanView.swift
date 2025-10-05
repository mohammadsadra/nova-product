//
//  BarcodeScanView.swift
//  nova product
//
//  Created by Mohammadsadra on 10/1/25.
//

import SwiftUI
import SwiftData
import AVFoundation

struct BarcodeScanView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var products: [Product]
    @State private var isScanning = false
    @State private var scannedBarcode = ""
    @State private var showProductDetail = false
    @State private var showNewProduct = false
    @State private var foundProduct: Product?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if isScanning {
                    VStack {
                        SimpleBarcodeScannerView { barcode in
                            handleScannedBarcode(barcode)
                        }
                        .frame(maxWidth: .infinity, maxHeight: 400)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.blue, lineWidth: 2)
                        )
                        
                        Text("Point camera at barcode")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 8)
                    }
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "barcode.viewfinder")
                            .font(.system(size: 80))
                            .foregroundColor(.blue)
                        
                        Text("Tap to start scanning")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        
                        Button("Start Scanning") {
                            isScanning = true
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    }
                    .frame(maxWidth: .infinity, maxHeight: 400)
                }
                
                if !scannedBarcode.isEmpty && foundProduct == nil {
                    VStack(spacing: 10) {
                        Text("Scanned Barcode:")
                            .font(.headline)
                        Text(scannedBarcode)
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        
                        Text("Product not found")
                            .font(.subheadline)
                            .foregroundColor(.orange)
                        
                        Button("Create New Product") {
                            showNewProduct = true
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button("Scan Again") {
                            resetScanning()
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                }
            }
            .padding()
            .navigationTitle("Scan Barcode")
            .sheet(isPresented: $showProductDetail) {
                if let product = foundProduct {
                    ProductDetailView(product: product)
                }
            }
            .sheet(isPresented: $showNewProduct) {
                NewProductView(barcode: scannedBarcode)
            }
        }
    }
    
    private func handleScannedBarcode(_ barcode: String) {
        scannedBarcode = barcode
        isScanning = false
        
        // Check if product exists
        foundProduct = products.first { $0.barcode == barcode }
        
        // If product exists, automatically open detail page
        if foundProduct != nil {
            showProductDetail = true
        }
        // If no product found, show the result screen with "Create New Product" option
    }
    
    private func resetScanning() {
        scannedBarcode = ""
        foundProduct = nil
        isScanning = true
    }
}

#Preview {
    BarcodeScanView()
        .modelContainer(for: Product.self, inMemory: true)
}
