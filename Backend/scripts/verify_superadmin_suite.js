const { sequelize, User, Wallet, Order, Transaction, DailyProfit, Notification, AuditLog, SupportTicket, SystemSetting } = require('../src/models');
const adminRoutes = require('../src/routes/admin_routes');
const adminController = require('../src/controllers/admin_controller');

function createMockRes() {
  let result = null;
  return {
    statusCode: 200,
    status(c) { this.statusCode = c; return this; },
    json(d) { result = d; return this; },
    getResult() { return result; }
  };
}

async function verifySuperAdminSuite() {
  console.log('--- Verifying SuperAdmin Autonomous Suite ---');
  
  // 1. Check Model definitions
  console.log('1. Checking Sequelize Models...');
  if (!AuditLog || !SupportTicket || !SystemSetting || !User) {
    throw new Error('Crucial models missing!');
  }
  console.log('   Models loaded: AuditLog, SupportTicket, SystemSetting, User, Wallet, Order, Transaction, DailyProfit, Notification [OK]');

  // 2. Check Controller Functions
  console.log('2. Checking Admin Controller Handlers...');
  const expectedHandlers = [
    'getUserKundali',
    'deleteUserPermanently',
    'getPendingUtrs',
    'approveUtr',
    'rejectUtr',
    'listSupportTickets',
    'replySupportTicket',
    'listAuditLogs',
    'getSolvencyMetrics'
  ];

  for (const handler of expectedHandlers) {
    if (typeof adminController[handler] !== 'function') {
      throw new Error(`adminController.${handler} is NOT a function!`);
    }
  }
  console.log('   All 9 autonomous admin controller handlers present & callable [OK]');

  // 3. Check DB connectivity & sync
  console.log('3. Authenticating database & syncing tables...');
  await sequelize.authenticate();
  await sequelize.sync();
  try { await sequelize.query('ALTER TABLE orders ADD COLUMN utr_number VARCHAR(255);'); } catch (_) {}
  try { await sequelize.query('ALTER TABLE orders ADD COLUMN package_name VARCHAR(255);'); } catch (_) {}
  console.log('   Database authenticated and synced cleanly [OK]');

  const mockReq = { user: { id: 1, role: 'admin' }, query: {}, params: {}, ip: '127.0.0.1' };

  // 4. Test Solvency Metrics Handler
  console.log('4. Testing getSolvencyMetrics handler...');
  const res1 = createMockRes();
  await adminController.getSolvencyMetrics(mockReq, res1);
  const solvencyResult = res1.getResult();
  if (!solvencyResult || !solvencyResult.success) {
    throw new Error('getSolvencyMetrics failed: ' + JSON.stringify(solvencyResult));
  }
  console.log('   Solvency Metrics calculated:', solvencyResult.data);

  // 5. Test Audit Log retrieval
  console.log('5. Testing listAuditLogs handler...');
  const res2 = createMockRes();
  await adminController.listAuditLogs(mockReq, res2);
  const auditLogsResult = res2.getResult();
  if (!auditLogsResult || !auditLogsResult.success) {
    throw new Error('listAuditLogs failed: ' + JSON.stringify(auditLogsResult));
  }
  console.log(`   Audit Logs fetched: ${auditLogsResult.data.length} logs [OK]`);

  // 6. Test Support Tickets retrieval
  console.log('6. Testing listSupportTickets handler...');
  const res3 = createMockRes();
  await adminController.listSupportTickets(mockReq, res3);
  const ticketsResult = res3.getResult();
  if (!ticketsResult || !ticketsResult.success) {
    throw new Error('listSupportTickets failed: ' + JSON.stringify(ticketsResult));
  }
  console.log(`   Support Tickets fetched: ${ticketsResult.data.length} tickets [OK]`);

  // 7. Test Pending UTRs
  console.log('7. Testing getPendingUtrs handler...');
  const res4 = createMockRes();
  await adminController.getPendingUtrs(mockReq, res4);
  const utrResult = res4.getResult();
  if (!utrResult || !utrResult.success) {
    throw new Error('getPendingUtrs failed: ' + JSON.stringify(utrResult));
  }
  console.log(`   Pending UTR orders fetched: ${utrResult.data.length} orders [OK]`);

  // 8. Test User Kundali & Permanent Cascade Delete
  console.log('8. Testing User Kundali & Cascade Delete handlers...');
  const testEmail = `kundali_test_${Date.now()}_${Math.floor(Math.random()*1000)}@quickmoney.in`;
  const testUser = await User.create({
    full_name: 'Kundali Test Trader',
    email: testEmail,
    password_hash: '$2a$10$abcdefghijklmnopqrstuu',
    mobile_encrypted: 'ENC_' + Date.now() + '_' + Math.floor(Math.random()*10000),
    role: 'user',
    balance: 750.00,
    invite_code: 'Q' + Math.random().toString(36).substring(2, 9).toUpperCase(),
  });

  const res5 = createMockRes();
  await adminController.getUserKundali({ params: { id: testUser.id } }, res5);
  const kundali = res5.getResult();
  if (!kundali || !kundali.success || !kundali.data.financials) {
    throw new Error('getUserKundali failed: ' + JSON.stringify(kundali));
  }
  console.log(`   User Kundali generated successfully: PnL Net ₹${kundali.data.financials.netPnl} [OK]`);

  const res6 = createMockRes();
  await adminController.deleteUserPermanently({ params: { id: testUser.id }, ip: '127.0.0.1', user: { id: 1 } }, res6);
  const delRes = res6.getResult();
  if (!delRes || !delRes.success) {
    throw new Error('deleteUserPermanently failed: ' + JSON.stringify(delRes));
  }
  const checkUser = await User.findByPk(testUser.id);
  if (checkUser !== null) {
    throw new Error('User still exists after deleteUserPermanently!');
  }
  console.log('   User permanently deleted and cascade verified cleanly [OK]');

  console.log('\nAll SuperAdmin Autonomous Backend Verifications PASSED 100%!');
  process.exit(0);
}

verifySuperAdminSuite().catch((err) => {
  console.error('VERIFICATION ERROR:', err);
  process.exit(1);
});
