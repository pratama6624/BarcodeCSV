import sys
import gspread
from oauth2client.service_account import ServiceAccountCredentials

# 🔐 Setup kredensial dan client
scope = [
    "https://spreadsheets.google.com/feeds",
    "https://www.googleapis.com/auth/spreadsheets",
    "https://www.googleapis.com/auth/drive.file"
]
creds = ServiceAccountCredentials.from_json_keyfile_name('credentials.json', scope)
client = gspread.authorize(creds)

spreadsheet_id = "1cNva-TR-SYpZ4VhBSqQyDuOeXcRAyiIkNbKaSW0KeQo"
sheet = client.open_by_key(spreadsheet_id).sheet1

# 🛠 Fungsi utama
def update_or_append(upc, product_data):
    print(f"📥 UPC yang diterima: {upc}", flush=True)
    print(f"📦 Data produk yang dikirim:", flush=True)
    for i, value in enumerate(product_data, start=1):
        print(f"Kolom {i}: {value}", flush=True)

    all_data = sheet.get_all_records()
    print(f"🔍 Mencari UPC di Google Sheets...", flush=True)

    for i, row in enumerate(all_data, start=2):  # Mulai dari baris ke-2
        if row['UPC/EAN'] == upc:
            current_qty = int(row['Qty'])
            new_qty = current_qty + 1
            sheet.update_cell(i, 10, new_qty)  # Kolom 10 = Qty
            print(f"✅ UPC ditemukan di baris {i}, Qty diperbarui: {current_qty} ➜ {new_qty}", flush=True)
            return

    # 🔽 Jika UPC belum ditemukan, tambahkan data baru
    if len(product_data) == 9:
        product_data.append(1)  # Qty = 1
        print("ℹ️ UPC belum ada, menambahkan Qty = 1", flush=True)

    sheet.append_row(product_data)
    print("🆕 Baris baru ditambahkan ke Google Sheets.", flush=True)

# 🚀 Bagian ini dijalankan saat dipanggil dari Swift / CLI
if __name__ == "__main__":
    if len(sys.argv) != 10:
        print(f"❌ Jumlah argumen tidak sesuai! ({len(sys.argv) - 1} argumen ditemukan)", flush=True)
        sys.exit(1)

    # Ambil semua argumen dari CLI
    product_data = sys.argv[1:]         # 9 argumen
    upc = product_data[8]               # UPC = argumen terakhir
    update_or_append(upc, product_data)
