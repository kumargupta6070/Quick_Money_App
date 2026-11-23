const { sequelize, User, Wallet, Order, Transaction, DailyProfit, Notification } = require('../src/models');
const bcrypt = require('bcryptjs');
const { encrypt } = require('../src/config/encryption');
const { hashMobile } = require('../src/utils/crypto_helper');

async function seedDatabase() {
  console.log('====================================================');
  console.log('⚡ Quick Money FinTech - Database Initialization & Seed');
  console.log('====================================================\n');

  try {
    // 1. Authenticate & Synchronize all tables
    console.log('⏳ Connecting to database and synchronizing tables...');
    await sequelize.authenticate();
    await sequelize.query('PRAGMA foreign_keys = OFF;');
    await sequelize.sync();
    await sequelize.query('PRAGMA foreign_keys = ON;');
    console.log('✅ All 8 database tables synchronized successfully!\n');

    // Password hashes
    const adminPasswordHash = await bcrypt.hash('Admin@12345', 10);
    const demoPasswordHash = await bcrypt.hash('Demo@12345', 10);

    // 2. Ensure Sole Super Admin Account (kumargupta6070@gmail.com)
    console.log('👤 Ensuring Sole Super Admin Account (kumargupta6070@gmail.com)...');
    // Remove legacy admin accounts if any
    await User.destroy({ where: { email: 'admin@quickmoney.in' } });

    let admin = await User.findOne({ where: { email: 'kumargupta6070@gmail.com' } });
    if (!admin) {
      admin = await User.create({
        email: 'kumargupta6070@gmail.com',
        mobile_encrypted: encrypt('9877800389'),
        mobile_hash: hashMobile('9877800389'),
        password_hash: adminPasswordHash,
        invite_code: 'x0k4em9q',
        role: 'admin',
        balance: 500000.00,
        level: 'L7',
        status: 'active',
        is_email_verified: true,
      });
      console.log('  -> Super Admin created: kumargupta6070@gmail.com (Role: admin)');
    } else {
      await admin.update({
        role: 'admin',
        level: 'L7',
        password_hash: adminPasswordHash,
        mobile_encrypted: encrypt('9877800389'),
        mobile_hash: hashMobile('9877800389'),
        is_email_verified: true,
        status: 'active',
      });
      console.log('  -> Super Admin updated: kumargupta6070@gmail.com (Role: admin)');
    }

    // 3. Seed Demo Retail User
    console.log('\n👤 Seeding Demo Investor Account...');
    const demoMobile = '9835913180';
    const demoMobileHash = hashMobile(demoMobile);

    // Remove any legacy duplicate test user with same mobile if present
    await User.destroy({
      where: {
        mobile_hash: demoMobileHash,
        email: { [sequelize.Sequelize.Op.ne]: 'demo@quickmoney.in' },
      },
    });

    let demoUser = await User.findOne({ where: { email: 'demo@quickmoney.in' } });
    if (!demoUser) {
      demoUser = await User.create({
        email: 'demo@quickmoney.in',
        mobile_encrypted: encrypt(demoMobile),
        mobile_hash: demoMobileHash,
        password_hash: demoPasswordHash,
        invite_code: 'x03180',
        referred_by: 'x0k4em9q',
        role: 'user',
        balance: 51.07,
        level: 'L1',
        status: 'active',
        is_email_verified: true,
      });
      console.log('  -> Demo User created: demo@quickmoney.in / Demo@12345 (Balance: ₹51.07)');
    } else {
      await demoUser.update({
        mobile_encrypted: encrypt(demoMobile),
        password_hash: demoPasswordHash,
      });
      console.log('  -> Demo User updated with active encryption: demo@quickmoney.in');
    }

    // 4. Seed PhonePe Wallet for Demo User
    console.log('\n💳 Seeding PhonePe Bound Wallet...');
    let wallet = await Wallet.findOne({ where: { user_id: demoUser.id } });
    if (!wallet) {
      wallet = await Wallet.create({
        user_id: demoUser.id,
        payment_app: 'phonepe',
        upi_id_encrypted: encrypt('9835913180@ibl'),
        account_name_encrypted: encrypt('Primary PhonePe Wallet'),
        status: 'active',
        status_detail: 'Verified via NPCI Bank Gateway',
      });
      console.log('  -> PhonePe Wallet bound: 9835913180@ibl (Status: Active)');
    } else {
      console.log('  -> PhonePe Wallet already bound.');
    }

    // 5. Seed Comprehensive Authentic Buy RP Orders for all Tiers (L1 to L7)
    console.log('\n📦 Seeding Investment Packages & Orders across Tiers L1-L7...');
    await Order.destroy({ where: {} }); // Fresh seed

    const allOrders = [
      // Level 1 Orders (₹230 - ₹300)
      { seller_id: admin.id, order_amount: 285.00, order_quantity: 62, reward: 8.55, bonus: 2.00, final_rp: 295.55, level: 'L1', status: 'active' },
      { seller_id: admin.id, order_amount: 300.00, order_quantity: 60, reward: 9.00, bonus: 2.00, final_rp: 311.00, level: 'L1', status: 'active' },
      { seller_id: admin.id, order_amount: 250.00, order_quantity: 59, reward: 7.50, bonus: 2.00, final_rp: 259.50, level: 'L1', status: 'active' },
      { seller_id: admin.id, order_amount: 280.00, order_quantity: 48, reward: 8.40, bonus: 2.00, final_rp: 290.40, level: 'L1', status: 'active' },
      { seller_id: admin.id, order_amount: 230.00, order_quantity: 47, reward: 6.90, bonus: 2.00, final_rp: 238.90, level: 'L1', status: 'active' },
      { seller_id: admin.id, order_amount: 270.00, order_quantity: 46, reward: 8.10, bonus: 2.00, final_rp: 280.10, level: 'L1', status: 'active' },
      { seller_id: admin.id, order_amount: 240.00, order_quantity: 45, reward: 7.20, bonus: 2.00, final_rp: 249.20, level: 'L1', status: 'active' },

      // Level 2 Orders (₹500 - ₹1,000)
      { seller_id: admin.id, order_amount: 500.00, order_quantity: 35, reward: 25.00, bonus: 5.00, final_rp: 530.00, level: 'L2', status: 'active' },
      { seller_id: admin.id, order_amount: 750.00, order_quantity: 28, reward: 41.25, bonus: 7.50, final_rp: 798.75, level: 'L2', status: 'active' },
      { seller_id: admin.id, order_amount: 1000.00, order_quantity: 22, reward: 60.00, bonus: 10.00, final_rp: 1070.00, level: 'L2', status: 'active' },

      // Level 3 Orders (₹1,500 - ₹3,000)
      { seller_id: admin.id, order_amount: 1550.00, order_quantity: 18, reward: 108.50, bonus: 15.00, final_rp: 1673.50, level: 'L3', status: 'active' },
      { seller_id: admin.id, order_amount: 2500.00, order_quantity: 14, reward: 187.50, bonus: 25.00, final_rp: 2712.50, level: 'L3', status: 'active' },

      // Level 4 Orders (₹5,000)
      { seller_id: admin.id, order_amount: 5000.00, order_quantity: 10, reward: 425.00, bonus: 50.00, final_rp: 5475.00, level: 'L4', status: 'active' },

      // Level 5 Orders (₹10,000)
      { seller_id: admin.id, order_amount: 10000.00, order_quantity: 8, reward: 950.00, bonus: 120.00, final_rp: 11070.00, level: 'L5', status: 'active' },

      // Level 6 Orders (₹20,000)
      { seller_id: admin.id, order_amount: 20000.00, order_quantity: 5, reward: 2100.00, bonus: 300.00, final_rp: 22400.00, level: 'L6', status: 'active' },

      // Level 7 Orders (₹50,000)
      { seller_id: admin.id, order_amount: 50000.00, order_quantity: 3, reward: 5750.00, bonus: 1000.00, final_rp: 56750.00, level: 'L7', status: 'active' },
    ];

    await Order.bulkCreate(allOrders);
    console.log(`  -> ${allOrders.length} authentic RP packages created across Tiers L1 to L7.`);

    // 6. Seed Sample Transactions for Demo User
    console.log('\n💳 Seeding Sample Transactions for Demo User...');
    const txCount = await Transaction.count({ where: { user_id: demoUser.id } });
    if (txCount === 0) {
      await Transaction.bulkCreate([
        {
          user_id: demoUser.id,
          type: 'deposit',
          amount: 500.00,
          profit: 0.0,
          payment_method: 'phonepe',
          payment_source_encrypted: encrypt('9835913180@ibl'),
          payment_destination_encrypted: null,
          payment_reference_encrypted: encrypt('DEP-QM882910'),
          status: 'completed',
          created_at: new Date(Date.now() - 86400000 * 2),
        },
        {
          user_id: demoUser.id,
          type: 'buy',
          amount: 285.00,
          profit: 10.55,
          payment_method: 'phonepe',
          payment_source_encrypted: encrypt('9835913180@ibl'),
          payment_destination_encrypted: null,
          payment_reference_encrypted: encrypt('ORD-88391'),
          status: 'completed',
          created_at: new Date(Date.now() - 86400000),
        },
        {
          user_id: demoUser.id,
          type: 'rebate',
          amount: 18.00,
          profit: 18.00,
          payment_method: 'phonepe',
          payment_source_encrypted: null,
          payment_destination_encrypted: null,
          payment_reference_encrypted: encrypt('REB-L1-442'),
          status: 'completed',
          created_at: new Date(Date.now() - 3600000 * 5),
        },
        {
          user_id: demoUser.id,
          type: 'payout',
          amount: 100.00,
          profit: 0.0,
          payment_method: 'phonepe',
          payment_source_encrypted: null,
          payment_destination_encrypted: encrypt('9835913180@ibl'),
          payment_reference_encrypted: encrypt('PAYOUT-AUTO-100'),
          status: 'completed',
          created_at: new Date(Date.now() - 3600000 * 2),
        },
      ]);
      console.log('  -> 4 Sample transactions seeded (deposit, buy, rebate, payout).');
    } else {
      console.log('  -> Transactions already present.');
    }

    // 6. Seed Notifications
    console.log('\n🔔 Seeding Welcome Notifications...');
    const notifCount = await Notification.count({ where: { user_id: demoUser.id } });
    if (notifCount === 0) {
      await Notification.bulkCreate([
        {
          user_id: demoUser.id,
          title: 'Welcome to Quick Money!',
          message: 'Your account has been credited with ₹51.07 starter bonus.',
          type: 'success',
          is_read: false,
        },
        {
          user_id: demoUser.id,
          title: 'PhonePe Auto-Return Enabled',
          message: 'Profits above ₹100 will be auto-transferred to your bound UPI address.',
          type: 'info',
          is_read: false,
        },
      ]);
      console.log('  -> 2 System notifications added for demo user.');
    } else {
      console.log('  -> Notifications already present.');
    }

    console.log('\n====================================================');
    console.log('🎉 Database setup and seeding completed successfully!');
    console.log('====================================================');
    console.log('Admin Login:   admin@quickmoney.in / Admin@12345');
    console.log('Demo Login:    demo@quickmoney.in  / Demo@12345');
    console.log('Swagger Docs:  http://localhost:5000/api-docs');
    console.log('====================================================\n');
    process.exit(0);
  } catch (err) {
    console.error('❌ Error during database seeding:', err);
    process.exit(1);
  }
}

seedDatabase();
