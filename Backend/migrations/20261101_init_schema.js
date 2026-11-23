'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    // 1. Users
    await queryInterface.createTable('users', {
      id: { type: Sequelize.INTEGER, primaryKey: true, autoIncrement: true },
      mobile_encrypted: { type: Sequelize.STRING, allowNull: false, unique: true },
      password_hash: { type: Sequelize.STRING, allowNull: false },
      invite_code: { type: Sequelize.STRING, allowNull: false, unique: true },
      referred_by: { type: Sequelize.STRING, allowNull: true },
      balance: { type: Sequelize.DECIMAL(12, 2), defaultValue: 0.0 },
      level: { type: Sequelize.ENUM('L1', 'L2', 'L3', 'L4', 'L5', 'L6', 'L7'), defaultValue: 'L1' },
      status: { type: Sequelize.ENUM('active', 'suspended', 'banned'), defaultValue: 'active' },
      created_at: { type: Sequelize.DATE, allowNull: false, defaultValue: Sequelize.literal('CURRENT_TIMESTAMP') },
      updated_at: { type: Sequelize.DATE, allowNull: false, defaultValue: Sequelize.literal('CURRENT_TIMESTAMP') },
    });

    // 2. Wallets
    await queryInterface.createTable('wallets', {
      id: { type: Sequelize.INTEGER, primaryKey: true, autoIncrement: true },
      user_id: { type: Sequelize.INTEGER, allowNull: false },
      payment_app: { type: Sequelize.ENUM('phonepe', 'googlepay', 'paytm'), defaultValue: 'phonepe' },
      upi_id_encrypted: { type: Sequelize.STRING, allowNull: false },
      account_name_encrypted: { type: Sequelize.STRING, allowNull: true },
      status: { type: Sequelize.ENUM('active', 'warning', 'abnormal'), defaultValue: 'active' },
      status_detail: { type: Sequelize.STRING, defaultValue: 'Verified' },
      created_at: { type: Sequelize.DATE, allowNull: false, defaultValue: Sequelize.literal('CURRENT_TIMESTAMP') },
    });

    // 3. Orders
    await queryInterface.createTable('orders', {
      id: { type: Sequelize.INTEGER, primaryKey: true, autoIncrement: true },
      seller_id: { type: Sequelize.INTEGER, allowNull: true },
      buyer_id: { type: Sequelize.INTEGER, allowNull: true },
      order_amount: { type: Sequelize.DECIMAL(10, 2), allowNull: false },
      order_quantity: { type: Sequelize.INTEGER, defaultValue: 1 },
      reward: { type: Sequelize.DECIMAL(10, 2), allowNull: false },
      bonus: { type: Sequelize.DECIMAL(10, 2), defaultValue: 2.0 },
      final_rp: { type: Sequelize.DECIMAL(10, 2), allowNull: false },
      level: { type: Sequelize.ENUM('L1', 'L2', 'L3', 'L4', 'L5', 'L6', 'L7'), defaultValue: 'L1' },
      status: { type: Sequelize.ENUM('active', 'received', 'completed', 'cancelled'), defaultValue: 'active' },
      created_at: { type: Sequelize.DATE, allowNull: false, defaultValue: Sequelize.literal('CURRENT_TIMESTAMP') },
      completed_at: { type: Sequelize.DATE, allowNull: true },
    });

    // 4. Transactions
    await queryInterface.createTable('transactions', {
      id: { type: Sequelize.INTEGER, primaryKey: true, autoIncrement: true },
      user_id: { type: Sequelize.INTEGER, allowNull: false },
      order_id: { type: Sequelize.INTEGER, allowNull: true },
      type: { type: Sequelize.ENUM('buy', 'sell', 'deposit', 'withdrawal', 'payout', 'rebate', 'reward'), allowNull: false },
      amount: { type: Sequelize.DECIMAL(12, 2), allowNull: false },
      profit: { type: Sequelize.DECIMAL(10, 2), defaultValue: 0.0 },
      payment_method: { type: Sequelize.ENUM('phonepe', 'googlepay', 'paytm'), defaultValue: 'phonepe' },
      payment_source_encrypted: { type: Sequelize.STRING, allowNull: true },
      payment_destination_encrypted: { type: Sequelize.STRING, allowNull: true },
      payment_reference_encrypted: { type: Sequelize.STRING, allowNull: true },
      status: { type: Sequelize.ENUM('pending', 'processing', 'completed', 'failed'), defaultValue: 'completed' },
      created_at: { type: Sequelize.DATE, allowNull: false, defaultValue: Sequelize.literal('CURRENT_TIMESTAMP') },
    });

    // 5. Daily Profits
    await queryInterface.createTable('daily_profits', {
      id: { type: Sequelize.INTEGER, primaryKey: true, autoIncrement: true },
      user_id: { type: Sequelize.INTEGER, allowNull: false },
      profit_date: { type: Sequelize.DATEONLY, allowNull: false },
      total_income: { type: Sequelize.DECIMAL(10, 2), defaultValue: 0.0 },
      purchase_number: { type: Sequelize.INTEGER, defaultValue: 0 },
      purchase_amount: { type: Sequelize.DECIMAL(10, 2), defaultValue: 0.0 },
      brokerage: { type: Sequelize.DECIMAL(10, 2), defaultValue: 0.0 },
      team_rebates: { type: Sequelize.DECIMAL(10, 2), defaultValue: 0.0 },
      subordinate_rebates: { type: Sequelize.DECIMAL(10, 2), defaultValue: 0.0 },
      usdt_recharge: { type: Sequelize.DECIMAL(12, 4), defaultValue: 0.0 },
      trx_recharge: { type: Sequelize.DECIMAL(12, 4), defaultValue: 0.0 },
      sell_number: { type: Sequelize.INTEGER, defaultValue: 0 },
      sell_amount: { type: Sequelize.DECIMAL(10, 2), defaultValue: 0.0 },
      activity_reward: { type: Sequelize.DECIMAL(10, 2), defaultValue: 0.0 },
      other_reward: { type: Sequelize.DECIMAL(10, 2), defaultValue: 0.0 },
      created_at: { type: Sequelize.DATE, allowNull: false, defaultValue: Sequelize.literal('CURRENT_TIMESTAMP') },
    });
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.dropTable('daily_profits');
    await queryInterface.dropTable('transactions');
    await queryInterface.dropTable('orders');
    await queryInterface.dropTable('wallets');
    await queryInterface.dropTable('users');
  },
};

