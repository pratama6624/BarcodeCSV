//
//  Product.swift
//  vapor-flashsale-service
//
//  Created by Pratama One on 03/12/25.
//

import Fluent
import Vapor

final class Product: Model, @unchecked Sendable {
    static let schema: String = "products"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String

    @Field(key: "price")
    var price: Double

    @Field(key: "stock")
    var stock: Int
    
    init() {}
    
    init(id: UUID? = nil, name: String, price: Double, stock: Int) {
        self.id = id
        self.name = name
        self.price = price
        self.stock = stock
    }
}
