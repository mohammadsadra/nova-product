# Nova Product - Barcode Scanner & Product Management App

A SwiftUI app for managing products with barcode scanning capabilities.

## Features

### Tab 1: Barcode Scanner
- **Scan Barcodes**: Use the device camera to scan product barcodes
- **Product Detection**: Automatically checks if a product with the scanned barcode already exists
- **Product Details**: If product exists, navigate to product detail page
- **New Product**: If product doesn't exist, create a new product with the scanned barcode

### Tab 2: Product List
- **Product List**: View all products in a searchable list
- **Search**: Search products by name or barcode
- **Product Details**: Tap any product to view/edit details
- **Delete Products**: Swipe to delete products

## Product Model

Each product contains:
- **Name** (Required): Product name
- **Barcode** (Required): Unique barcode identifier
- **Image**: Optional product image
- **Amount**: Stock quantity
- **Buy Price** (Required): Purchase price
- **Sell Price** (Required): Selling price
- **Specification**: Additional product details

## Required Fields
- Name
- Barcode
- Buy Price
- Sell Price

## App Structure

- `MainTabView.swift`: Main tab container
- `BarcodeScanView.swift`: Barcode scanning interface
- `BarcodeScannerView.swift`: Camera-based barcode scanner
- `ProductListView.swift`: Product list with search
- `ProductDetailView.swift`: Product details with edit capabilities
- `NewProductView.swift`: Create new product form
- `Product.swift`: SwiftData model

## Permissions Required

- **Camera**: For barcode scanning
- **Photo Library**: For adding product images

## Usage

1. **Scanning Products**:
   - Go to the "Scan" tab
   - Tap "Start Scanning"
   - Point camera at barcode
   - If product exists, view details; if not, create new product

2. **Managing Products**:
   - Go to the "Products" tab
   - View all products in a list
   - Search for specific products
   - Tap any product to view/edit details
   - Swipe to delete products

3. **Adding New Products**:
   - Scan a barcode that doesn't exist in the database
   - Fill in required fields (name, buy price, sell price)
   - Optionally add image and other details
   - Save the product

## Technical Details

- Built with SwiftUI and SwiftData
- Uses AVFoundation for barcode scanning
- Supports multiple barcode formats (EAN8, EAN13, QR, Code128, Code39, PDF417)
- RTL (Right-to-Left) layout support
- Persistent data storage with SwiftData
