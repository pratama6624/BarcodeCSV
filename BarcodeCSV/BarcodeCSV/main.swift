//
//  main.swift
//  BarcodeCSV
//
//  Created by Pratama One on 24/05/25.
//

import Foundation
import CSV

struct Product {
    var brand, sku, model, warna, ukuran, kategori, harga, asal, upc: String
}

func getProjectRootPath() -> String {
    // Ambil direktori tempat program dijalankan lalu naik ke atas
    let currentPath = FileManager.default.currentDirectoryPath
    return (currentPath as NSString).deletingLastPathComponent
}

func readCSVDatabase(path: String) -> [Product] {
    var results: [Product] = []
    guard let stream = InputStream(fileAtPath: path) else {
        print("❌ File '\(path)' tidak ditemukan.")
        return []
    }

    do {
        let csv = try CSVReader(stream: stream, hasHeaderRow: true)

        while let row = csv.next() {
            guard row.count >= 9 else {
                print("❌ Baris CSV tidak valid: \(row)")
                continue
            }
            let item = Product(
                brand: row[0],
                sku: row[1],
                model: row[2],
                warna: row[3],
                ukuran: row[4],
                kategori: row[5],
                harga: row[6],
                asal: row[7],
                upc: row[8]
            )
            results.append(item)
        }
    } catch {
        print("❌ Gagal baca database: \(error)")
    }
    return results
}

func updateOutputCSV(product: Product, outputPath: String) {
    var updated = false
    var rows: [[String]] = []

    if FileManager.default.fileExists(atPath: outputPath),
       let stream = InputStream(fileAtPath: outputPath),
       let csv = try? CSVReader(stream: stream, hasHeaderRow: true) {
        rows.append(csv.headerRow!)
        while let row = csv.next() {
            if row.count >= 10 && row[8] == product.upc {
                var newRow = row
                let currentQty = Int(row[9]) ?? 0
                newRow[9] = String(currentQty + 1)
                rows.append(newRow)
                updated = true
            } else {
                rows.append(row)
            }
        }
    } else {
        rows.append(["Brand", "SKU", "Model", "Warna", "Ukuran", "Kategori", "Harga", "Asal", "UPC/EAN", "Qty"])
    }

    if !updated {
        rows.append([
            product.brand, product.sku, product.model,
            product.warna, product.ukuran, product.kategori,
            product.harga, product.asal, product.upc, "1"
        ])
    }

    do {
        let stream = OutputStream(toFileAtPath: outputPath, append: false)!
        let csv = try CSVWriter(stream: stream)
        for row in rows {
            try csv.write(row: row)
        }
        csv.stream.close()
        print("✅ Data berhasil ditulis ke '\(outputPath)'")
    } catch {
        print("❌ Gagal tulis file output: \(error)")
    }
}

func updateGoogleSheet(product: Product) {
    let process = Process()
    let pipe = Pipe()
    process.standardOutput = pipe
    process.standardError = pipe

    // Path ke python
    process.executableURL = URL(fileURLWithPath: "/usr/bin/python3")

    // Path ke script Python yang ada di folder project
    let scriptPath = Bundle.main.path(forResource: "update_sheet", ofType: "py") ?? "./update_sheet.py"

    // Pastikan urutan dan jumlah argumen konsisten
    let args = [
        scriptPath,
        product.brand,
        product.sku,
        product.model,
        product.warna,
        product.ukuran,
        product.kategori,
        product.harga,
        product.asal,
        product.upc
    ]
    process.arguments = args

    do {
        try process.run()
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        if let output = String(data: data, encoding: .utf8) {
            print("📤 Output dari Python:\n\(output)")
        }

        if process.terminationStatus == 0 {
            print("✅ Data berhasil dikirim ke Google Sheets")
        } else {
            print("❌ Gagal kirim ke Google Sheets")
        }
    } catch {
        print("❌ Error saat menjalankan script Python: \(error)")
    }
}

let root = getProjectRootPath()
let databasePath = "\(root)/BarcodeCSV/database/database.csv"
let outputPath = "\(root)/BarcodeCSV/output/output.csv"

print("Masukkan UPC/EAN:")
if let inputUPC = readLine() {
    let database = readCSVDatabase(path: databasePath)
    if let matched = database.first(where: { $0.upc == inputUPC }) {
        print("✅ Barang ditemukan: \(matched.brand) - \(matched.model)")
        updateGoogleSheet(product: matched)
    } else {
        print("❌ Barang dengan UPC tersebut tidak ditemukan.")
    }
} else {
    print("❌ Input tidak valid.")
}
