import NIOSSL
import Fluent
import Vapor
import FluentPostgresDriver // PosgreeSql
import Redis // Redis
import JWT
import JWTKit
import Crypto

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    app.passwords.use(.bcrypt)
    
    app.redis.configuration = try RedisConfiguration(
        hostname: "127.0.0.1",
        port: 6379,
        password: nil,
        pool: .init(
            maximumConnectionCount: .maximumActiveConnections(100)
        )
    )

    app.databases.use(DatabaseConfigurationFactory.postgres(configuration: .init(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? SQLPostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "flashsale_service_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "flashsale_service_password",
        database: Environment.get("DATABASE_NAME")  ?? "flashsale_service_database",
        tls: .prefer(try .init(configuration: .clientDefault)))
    ), as: .psql)
    
    // Ambil secret dari .env (kalau belum ada pakai default dev)
    let secret = Environment.get("JWT_SECRET") ?? "dev-secret-change-me"
    
    // Daftarkan HS256 key ke JWT (convert String to HMACKey)
    let hmacKey = HMACKey(from: Data(secret.utf8))
    await app.jwt.keys.add(hmac: hmacKey, digestAlgorithm: .sha256)

    // Migration & Seeder Users Table
    app.migrations.add(CreateProduct())
    app.migrations.add(SeedProducts())

    try await app.autoMigrate().get()
    
    // register routes
    try routes(app)
}

