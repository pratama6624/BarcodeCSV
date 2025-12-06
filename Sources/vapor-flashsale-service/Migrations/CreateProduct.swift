//
//  CreateProduct.swift
//  vapor-flashsale-service
//
//  Created by Pratama One on 03/12/25.
//

import Fluent

struct CreateProduct: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("products")
            .id()
            .field("name", .string, .required)
            .field("price", .double, .required)
            .field("stock", .int, .required)
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema("products").delete()
    }
}
