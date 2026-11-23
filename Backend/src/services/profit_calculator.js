const { DailyProfit, Transaction } = require('../models');
const { Op } = require('sequelize');

class ProfitCalculator {
  static async getDailySummary(userId, dateString, filterType) {
    const today = new Date();
    const todayStr = today.toISOString().split('T')[0];

    let startDate;
    let endDate;
    let labelDate = todayStr;

      const normFilter = (filterType || '').toString().toLowerCase();

      if (normFilter === 'yesterday') {
        const y = new Date();
        y.setDate(y.getDate() - 1);
        labelDate = y.toISOString().split('T')[0];
        startDate = new Date(`${labelDate}T00:00:00.000Z`);
        endDate = new Date(`${labelDate}T23:59:59.999Z`);
      } else if (normFilter === '7 days' || normFilter === '7days' || normFilter === '7_days') {
        const d7 = new Date();
        d7.setDate(d7.getDate() - 7);
        startDate = new Date(d7.setHours(0, 0, 0, 0));
        endDate = new Date();
        labelDate = 'Last 7 Days';
      } else if (normFilter === 'this month' || normFilter === 'this_month') {
        startDate = new Date(today.getFullYear(), today.getMonth(), 1);
        endDate = new Date();
        labelDate = `${today.toLocaleString('en-US', { month: 'short' })} ${today.getFullYear()}`;
      } else if (dateString && /^\d{4}-\d{2}-\d{2}$/.test(dateString)) {
        labelDate = dateString;
        startDate = new Date(`${dateString}T00:00:00.000Z`);
        endDate = new Date(`${dateString}T23:59:59.999Z`);
      } else {
        // Default: Today
        labelDate = todayStr;
        startDate = new Date(`${todayStr}T00:00:00.000Z`);
        endDate = new Date(`${todayStr}T23:59:59.999Z`);
      }

      // 1. Check if a pre-recorded DailyProfit exists for a single date
      if (labelDate === todayStr || /^\d{4}-\d{2}-\d{2}$/.test(labelDate)) {
        const summary = await DailyProfit.findOne({
          where: { user_id: userId, profit_date: labelDate },
        });
        if (summary) {
          return summary;
        }
      }

      // 2. Dynamic calculation from real user transactions within the date window
      const txWhere = {
        user_id: userId,
      };
      if (startDate && endDate) {
        txWhere.created_at = {
          [Op.gte]: startDate,
          [Op.lte]: endDate,
        };
      }

      const txs = await Transaction.findAll({
        where: txWhere,
      });

        let totalIncome = 0.0;
        let purchaseNumber = 0;
        let purchaseAmount = 0.0;
        let brokerage = 0.0;
        let teamRebates = 0.0;
        let sellNumber = 0;
        let sellAmount = 0.0;

          for (const tx of txs) {
            const p = parseFloat(tx.profit || 0);
            const a = parseFloat(tx.amount || 0);
            if (tx.type === 'buy') {
              purchaseNumber++;
              purchaseAmount += a;
              brokerage += p;
              totalIncome += p;
            } else if (tx.type === 'payout' || tx.type === 'sell') {
              sellNumber++;
              sellAmount += a;
            } else if (tx.type === 'rebate') {
              teamRebates += p;
              totalIncome += p;
            }
          }

          return {
            profit_date: labelDate,
            total_income: parseFloat(totalIncome.toFixed(2)),
            purchase_number: purchaseNumber,
            purchase_amount: parseFloat(purchaseAmount.toFixed(2)),
            brokerage: parseFloat(brokerage.toFixed(2)),
            team_rebates: parseFloat(teamRebates.toFixed(2)),
            subordinate_rebates: 0.0,
            usdt_recharge: 0.0,
            trx_recharge: 0.0,
            sell_number: sellNumber,
            sell_amount: parseFloat(sellAmount.toFixed(2)),
            activity_reward: 0.0,
            other_reward: 0.0,
          };
        }
      }

      module.exports = ProfitCalculator;

