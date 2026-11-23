# Quick Money Backend API

Node.js + Express REST API with MySQL, Sequelize ORM, and AES-256 data encryption.

## Features
- **PhonePe UPI Payment Integration**: Automates deposit tracking and return flow to source UPI once profit reaches ₹100.
- **AES-256 Encryption**: Encrypts sensitive fields (passwords, UPI VPAs, payment references).
- **JWT Authentication**: Access and refresh tokens with role validation.
- **3-Level Referral System**: Calculates 5% (L1), 3% (L2), and 1% (L3) rebates automatically.
- **Free Cloud Ready**: Optimized for 1-click deployment on Render.com with TiDB / Aiven MySQL.

## Getting Started
```bash
cp .env.example .env
npm install
npm run migrate
npm run seed
npm run dev
```

