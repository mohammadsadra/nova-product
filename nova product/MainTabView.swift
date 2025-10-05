//
//  MainTabView.swift
//  nova product
//
//  Created by Mohammadsadra on 10/1/25.
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    var body: some View {
        TabView {
            BarcodeScanView()
                .tabItem {
                    Image(systemName: "barcode.viewfinder")
                    Text("Scan")
                }
            
            ProductListView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Products")
                }
        }
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: Product.self, inMemory: true)
}
