//
//  FlashSaleController.swift
//  vapor-flashsale-service
//
//  Created by Pratama One on 04/12/25.
//

import Fluent
import Vapor
import Redis

struct FlashSaleController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let group = routes.grouped("flashsale")
        
        group.post("reset", use: reset)
        group.post("buy-db", use: buyWithDatabasePosgree)
        group.post("buy-redis", use: buyWithRedis)
    }
    
    struct ResetPayload: Content {
        let stock: Int?
    }
    
    @Sendable
    func reset(_ req: Request) async throws -> HTTPStatus {
        let payload = try? req.content.decode(ResetPayload.self)
        let targetStock = payload?.stock ?? 1_000
        
        if let product = try await Product.query(on: req.db).first() {
            product.stock = targetStock
            try await product.save(on: req.db)
        } else {
            let product = Product(
                name: "Flash Sale Product", price: 100_000, stock: targetStock)
            
            try await product.save(on: req.db)
        }
        
        _ = try await req.redis.set("flashsale:stock", to: targetStock).get()
        
        return .ok
    }
    
    @Sendable
    func buyWithDatabasePosgree(_ req: Request) async throws -> Response {
        let success = try await req.db.transaction { db in
            guard let product = try await Product.query(on: db).first() else {
                throw Abort(.internalServerError, reason: "No product found")
            }
            
            guard product.stock > 0 else {
                return false
            }
            
            product.stock -= 1
            try await product.save(on: db)
            
            return true
        }
        
        if success {
            return Response(status: .ok, body: .init(string: "OK-DB"))
        } else {
            return Response(status: .conflict, body: .init(string: "OUT_OF_STOCK-DB"))
        }
    }
    
    @Sendable
    func buyWithRedis(_ req: Request) async throws -> Response {
        let key: RedisKey = "flashsale:stock"
        
        let newValue: Int = try await req.redis.decrement(key).get()
        
        if newValue >= 0 {
            return Response(status: .ok, body: .init(string: "OK_REDIS"))
        }

        return Response(status: .conflict, body: .init(string: "OUT_OF_STOCK_REDIS"))
    }
}
