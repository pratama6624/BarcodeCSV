# Vapor Flashsale Benchmark

Project kecil untuk membandingkan kecepatan **transaksi stok flash sale**:

- Versi 1: pakai database transaksional (PostgreSQL) dengan transaksi biasa.
- Versi 2: pakai Redis sebagai gate stok (atomic counter).

Tujuan utama: mengukur perbedaan performa / throughput pada skenario "siapa cepat dia dapat".

## Tech Stack

- Swift + Vapor 4
- Fluent + PostgreSQL
- Redis

## Setup

```bash
git clone https://github.com/USERNAME/vapor-flashsale-benchmark.git
cd vapor-flashsale-benchmark

# Jalankan Postgres & Redis
docker compose up -d

# Install dependency
swift package update

# Jalankan server
swift run
