const express = require('express');
require('dns').setDefaultResultOrder('ipv4first');
const path = require('path');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const dotenv = require('dotenv');
const swaggerUi = require('swagger-ui-express');

dotenv.config();

const { sequelize } = require('./models');
const { apiLimiter } = require('./middleware/rate_limiter');
const encryptionMiddleware = require('./middleware/encryption_middleware');
const logger = require('./utils/logger');
const ResponseHandler = require('./utils/response_handler');
const swaggerSpec = require('./config/swagger');

// Route imports
const authRoutes = require('./routes/auth_routes');
const userRoutes = require('./routes/user_routes');
const walletRoutes = require('./routes/wallet_routes');
const orderRoutes = require('./routes/order_routes');
const transactionRoutes = require('./routes/transaction_routes');
const profitRoutes = require('./routes/profit_routes');
const referralRoutes = require('./routes/referral_routes');
const notificationRoutes = require('./routes/notification_routes');
const rewardRoutes = require('./routes/reward_routes');
const adminRoutes = require('./routes/admin_routes');
const paymentRoutes = require('./routes/payment_routes');
const systemRoutes = require('./routes/system_routes');

const app = express();
const PORT = process.env.PORT || 5000;

// Trust Render's reverse proxy for rate limiter & client IP resolution
app.set('trust proxy', 1);

// Security & Utility Middlewares
app.use(helmet({
  contentSecurityPolicy: false, // Allows Swagger UI assets
}));
app.use(cors({ origin: '*' }));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));
app.use(morgan('dev'));
app.use('/api/', apiLimiter);
app.use(encryptionMiddleware);

// Static file serving for downloads and public assets
app.get('/downloads/quick-money.apk', (req, res) => {
  return res.redirect('https://quick-moneey.netlify.app/quick-money.apk');
});
app.use('/downloads', express.static(path.join(__dirname, '../public/downloads')));
app.use(express.static(path.join(__dirname, '../public')));

// Root / Health Entrypoint for Render and Browser Visitors
app.get('/', (req, res) => {
  return res.status(200).json({
    success: true,
    message: 'Quick Money FinTech API Engine is Running',
    version: '1.0.0',
    documentation: '/api-docs',
    health: '/api/health',
    website: 'https://quick-moneey.netlify.app',
    status: 'ONLINE',
  });
});
app.head('/', (req, res) => res.status(200).end());

// Swagger Interactive API Documentation
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec, {
  customSiteTitle: 'Quick Money API Documentation & Test Console',
  customCss: '.swagger-ui .topbar { background-color: #0F172A; }',
}));

// API Health Check
app.get('/api/health', (req, res) => {
  return ResponseHandler.success(res, {
    status: 'ONLINE',
    encryption: 'AES-256-CBC ACTIVE',
    database: process.env.DB_DIALECT === 'mysql' ? 'MySQL' : 'SQLite (Active Dev Fallback)',
    swaggerDocs: `${process.env.SWAGGER_SERVER_URL || 'http://localhost:' + PORT}/api-docs`,
    timestamp: new Date().toISOString(),
  }, 'Quick Money API is healthy and operational');
});

// API Routes
app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/users', userRoutes);
app.use('/api/v1/wallets', walletRoutes);
app.use('/api/v1/orders', orderRoutes);
app.use('/api/v1/transactions', transactionRoutes);
app.use('/api/v1/profits', profitRoutes);
app.use('/api/v1/referrals', referralRoutes);
app.use('/api/v1/notifications', notificationRoutes);
app.use('/api/v1/rewards', rewardRoutes);
app.use('/api/v1/admin', adminRoutes);
app.use('/api/v1/payments', paymentRoutes);
app.use('/api/v1/system', systemRoutes);

// 404 Handler
app.use((req, res) => {
  return ResponseHandler.error(res, 'Endpoint not found', 404);
});

// Global Error Handler
app.use((err, req, res, next) => {
  logger.error(err.stack);
  return ResponseHandler.error(res, err.message || 'Internal Server Error', 500);
});

// Database sync & server start
async function startServer() {
  try {
    if (process.env.NODE_ENV !== 'test') {
      await sequelize.authenticate();
      logger.info(`Database connected successfully using ${process.env.DB_DIALECT || 'sqlite'} dialect.`);
      await sequelize.sync();
      logger.info('Database models synchronized successfully.');

      // Ensure optional new columns exist in sqlite/mysql
      try { await sequelize.query('ALTER TABLE orders ADD COLUMN utr_number VARCHAR(255);'); } catch (_) {}
      try { await sequelize.query('ALTER TABLE orders ADD COLUMN package_name VARCHAR(255);'); } catch (_) {}

      // Initialize standard RP market orders if empty
      const { Order } = require('./models');
      const orderCount = await Order.count();
      if (orderCount === 0) {
        const seedOrders = [
          { order_amount: 285.0, order_quantity: 62, reward: 8.55, bonus: 2.0, final_rp: 295.55, level: 'L1', status: 'active' },
          { order_amount: 300.0, order_quantity: 60, reward: 9.00, bonus: 2.0, final_rp: 311.00, level: 'L1', status: 'active' },
          { order_amount: 250.0, order_quantity: 59, reward: 7.50, bonus: 2.0, final_rp: 259.50, level: 'L1', status: 'active' },
          { order_amount: 280.0, order_quantity: 48, reward: 8.40, bonus: 2.0, final_rp: 290.40, level: 'L1', status: 'active' },
          { order_amount: 230.0, order_quantity: 47, reward: 6.90, bonus: 2.0, final_rp: 238.90, level: 'L1', status: 'active' },
          { order_amount: 270.0, order_quantity: 46, reward: 8.10, bonus: 2.0, final_rp: 280.10, level: 'L1', status: 'active' },
          { order_amount: 240.0, order_quantity: 45, reward: 7.20, bonus: 2.0, final_rp: 249.20, level: 'L1', status: 'active' },
          { order_amount: 570.0, order_quantity: 60, reward: 17.10, bonus: 4.0, final_rp: 591.10, level: 'L2', status: 'active' },
          { order_amount: 600.0, order_quantity: 55, reward: 18.00, bonus: 4.0, final_rp: 622.00, level: 'L2', status: 'active' },
          { order_amount: 855.0, order_quantity: 50, reward: 25.65, bonus: 6.0, final_rp: 886.65, level: 'L3', status: 'active' },
          { order_amount: 1140.0, order_quantity: 40, reward: 34.20, bonus: 8.0, final_rp: 1182.20, level: 'L4', status: 'active' },
          { order_amount: 1425.0, order_quantity: 35, reward: 42.75, bonus: 10.0, final_rp: 1477.75, level: 'L5', status: 'active' },
          { order_amount: 1710.0, order_quantity: 30, reward: 51.30, bonus: 12.0, final_rp: 1773.30, level: 'L6', status: 'active' },
          { order_amount: 1995.0, order_quantity: 25, reward: 59.85, bonus: 14.0, final_rp: 2068.85, level: 'L7', status: 'active' },
        ];
        await Order.bulkCreate(seedOrders);
        logger.info('Standard RP order market initialized with live orders.');
      }

      // Ensure SuperAdmin kumargupta6070@gmail.com exists
      const { User } = require('./models');
      const adminExists = await User.findOne({ where: { email: 'kumargupta6070@gmail.com' } });
      if (!adminExists) {
        const bcrypt = require('bcryptjs');
        const { encrypt } = require('./config/encryption');
        const { hashMobile } = require('./utils/crypto_helper');
        const adminPassHash = await bcrypt.hash('Admin@12345', 10);
        await User.create({
          email: 'kumargupta6070@gmail.com',
          mobile_encrypted: encrypt('9877800389'),
          mobile_hash: hashMobile('9877800389'),
          password_hash: adminPassHash,
          invite_code: 'x0k4em9q',
          role: 'admin',
          balance: 500000.00,
          level: 'L7',
          status: 'active',
          is_email_verified: true,
        });
        logger.info('Super Admin auto-created on start: kumargupta6070@gmail.com');
      }

      // Start automated daily yield distribution & auto-payout scheduler
      const YieldScheduler = require('./services/yield_scheduler');
      YieldScheduler.startScheduler();
    }
  } catch (error) {
    logger.warn('Database initialization warning: ' + error.message);
  }

  app.listen(PORT, () => {
    logger.info(`Quick Money Backend Server running on port ${PORT}`);
    logger.info(`Swagger Documentation live at http://localhost:${PORT}/api-docs`);
  });
}

startServer();

module.exports = app;
