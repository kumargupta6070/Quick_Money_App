'use strict';
const { encrypt } = require('../src/config/encryption');
const bcrypt = require('bcryptjs');

module.exports = {
  up: async (queryInterface, Sequelize) => {
    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash('123456', salt);

    // 1. Seed demo user (Matching Screenshot 7)
    await queryInterface.bulkInsert('users', [
      {
        id: 1,
        mobile_encrypted: encrypt('919835913180'),
        password_hash: passwordHash,
        invite_code: 'xOrZx2yO',
        referred_by: 'w2XZyx',
        balance: 51.07,
        level: 'L1',
        status: 'active',
        created_at: new Date(),
        updated_at: new Date(),
      },
    ]);

    // 2. Seed wallet (Matching Screenshot 5)
    await queryInterface.bulkInsert('wallets', [
      {
        id: 1,
        user_id: 1,
        payment_app: 'phonepe',
        upi_id_encrypted: encrypt('919835913180@ybl'),
        account_name_encrypted: encrypt('Primary PhonePe Wallet'),
        status: 'warning',
        status_detail: 'UPI Abnormal',
        created_at: new Date(),
      },
    ]);

    // 3. Seed orders (Matching Screenshot 6)
    await queryInterface.bulkInsert('orders', [
      { id: 1001, order_amount: 285.0, order_quantity: 62, reward: 8.55, bonus: 2.0, final_rp: 295.55, level: 'L1', status: 'active', created_at: new Date() },
      { id: 1002, order_amount: 300.0, order_quantity: 60, reward: 9.00, bonus: 2.0, final_rp: 311.00, level: 'L1', status: 'active', created_at: new Date() },
      { id: 1003, order_amount: 250.0, order_quantity: 59, reward: 7.50, bonus: 2.0, final_rp: 259.50, level: 'L1', status: 'active', created_at: new Date() },
      { id: 1004, order_amount: 280.0, order_quantity: 48, reward: 8.40, bonus: 2.0, final_rp: 290.40, level: 'L1', status: 'active', created_at: new Date() },
      { id: 1005, order_amount: 230.0, order_quantity: 47, reward: 6.90, bonus: 2.0, final_rp: 238.90, level: 'L1', status: 'active', created_at: new Date() },
      { id: 1006, order_amount: 270.0, order_quantity: 46, reward: 8.10, bonus: 2.0, final_rp: 280.10, level: 'L1', status: 'active', created_at: new Date() },
      { id: 1007, order_amount: 240.0, order_quantity: 45, reward: 7.20, bonus: 2.0, final_rp: 249.20, level: 'L1', status: 'active', created_at: new Date() },
    ]);
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.bulkDelete('orders', null, {});
    await queryInterface.bulkDelete('wallets', null, {});
    await queryInterface.bulkDelete('users', null, {});
  },
};

