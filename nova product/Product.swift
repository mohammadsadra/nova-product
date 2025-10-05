//
//  Product.swift
//  nova product
//
//  Created by Mohammadsadra on 10/1/25.
//

import Foundation
import SwiftData

@Model
final class Product {
    var id: UUID
    var name: String
    var barcode: String
    var image: Data?
    var amount: Int
    var buyPrice: Double
    var sellPrice: Double
    var offerPrice: Double
    var specification: String
    var createdAt: Date
    
    init(name: String, barcode: String, image: Data? = nil, amount: Int = 0, buyPrice: Double = 0.0, sellPrice: Double = 0.0, offerPrice: Double = 0.0, specification: String = "") {
        self.id = UUID()
        self.name = name
        self.barcode = barcode
        self.image = image
        self.amount = amount
        self.buyPrice = buyPrice
        self.sellPrice = sellPrice
        self.offerPrice = offerPrice
        self.specification = specification
        self.createdAt = Date()
    }
}
