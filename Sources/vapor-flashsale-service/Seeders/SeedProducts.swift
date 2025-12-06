//
//  SeedProdducts.swift
//  vapor-flashsale-service
//
//  Created by Pratama One on 03/12/25.
//

import Fluent

struct SeedProducts: AsyncMigration {
    func prepare(on database: any Database) async throws {
        let products: [Product] = [
            .init(name: "iPhone 15 Pro",        price: 21_999_000, stock: 10),
            .init(name: "iPhone 14",            price: 15_499_000, stock: 15),
            .init(name: "iPad Air",             price: 11_999_000, stock: 8),
            .init(name: "MacBook Air M2",       price: 18_999_000, stock: 5),
            .init(name: "MacBook Pro 14\"",     price: 29_999_000, stock: 3),
            .init(name: "Apple Watch Series 9", price: 7_999_000,  stock: 12),
            .init(name: "AirPods Pro 2",        price: 4_299_000,  stock: 20),
            .init(name: "HomePod mini",         price: 1_999_000,  stock: 25),
            .init(name: "Apple TV 4K",          price: 3_499_000,  stock: 7),
            .init(name: "Magic Keyboard",       price: 2_499_000,  stock: 30)
        ]
        
        for product in products {
            try await product.save(on: database)
        }
    }
    
    func revert(on database: any Database) async throws {
        try await Product.query(on: database).delete()
    }
}
