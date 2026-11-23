const express = require('express');
const AdminController = require('../controllers/admin_controller');
const authMiddleware = require('../middleware/auth_middleware');
const roleMiddleware = require('../middleware/role_middleware');

const router = express.Router();

// Protect all admin routes with JWT Auth + Admin Role Check
router.use(authMiddleware);
router.use(roleMiddleware(['admin']));

// 1. Dashboard Financial & Operational Stats
router.get('/stats', AdminController.getPlatformStats);

// 2. Pending Payouts Settlement Desk
router.get('/pending-payouts', AdminController.getPendingPayouts);
router.post('/payouts/:id/settle', AdminController.settlePayout);
router.post('/payouts/:id/reject', AdminController.rejectPayout);

// 3. Package & Market Order Management (Full CRUD)
router.get('/packages', AdminController.listAllPackages);
router.post('/packages', AdminController.createPackage);
router.put('/packages/:id', AdminController.updatePackage);
router.delete('/packages/:id', AdminController.deletePackage);

// 4. User Directory & Risk Control
router.get('/users', AdminController.listUsers);
router.get('/users/:id/kundali', AdminController.getUserKundali);
router.post('/users/:id/status', AdminController.updateUserStatus);
router.post('/users/:id/adjust-balance', AdminController.adjustUserBalance);
router.delete('/users/:id', AdminController.deleteUserPermanently);

// 5. Manual UTR Deposits Approval Desk
router.get('/pending-utrs', AdminController.getPendingUtrs);
router.post('/orders/:id/approve-utr', AdminController.approveUtr);
router.post('/orders/:id/reject-utr', AdminController.rejectUtr);

// 6. Live Platform Settings & Dynamic Rates
router.get('/settings', AdminController.getPlatformSettings);
router.put('/settings', AdminController.updatePlatformSettings);

// 7. Customer Support Tickets Desk
router.get('/support-tickets', AdminController.listSupportTickets);
router.post('/support-tickets/:id/reply', AdminController.replySupportTicket);

// 8. System Audit Logs & Live Solvency Health
router.get('/audit-logs', AdminController.listAuditLogs);
router.get('/solvency-metrics', AdminController.getSolvencyMetrics);

// 9. Broadcast Flash Announcements
router.post('/broadcast', AdminController.broadcastNotification);

// 10. Trigger Daily Trading Yield & Auto-Return Cycle
router.post('/yields/trigger-cycle', AdminController.triggerYieldCycle);

// 11. Dynamic APK Release Management for Website Landing Page
router.get('/app-release', AdminController.getAppRelease);
router.post('/app-release', AdminController.updateAppRelease);
router.delete('/app-release', AdminController.deleteAppRelease);

module.exports = router;
