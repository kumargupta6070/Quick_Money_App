const { Sequelize } = require('sequelize');
const path = require('path');
const dotenv = require('dotenv');
dotenv.config();

const dialect = process.env.DB_DIALECT || 'sqlite';

let sequelize;

if (dialect === 'sqlite') {
  const dbStorage = process.env.DB_STORAGE || './quick_money.sqlite';
  const resolvedStorage = path.isAbsolute(dbStorage)
    ? dbStorage
    : path.resolve(__dirname, '../../', dbStorage);

  sequelize = new Sequelize({
    dialect: 'sqlite',
    storage: resolvedStorage,
    logging: process.env.NODE_ENV === 'development' ? console.log : false,
  });
} else {
  const isCloudDb = process.env.DB_SSL === 'true' || process.env.DB_HOST?.includes('aivencloud.com') || process.env.NODE_ENV === 'production';

  sequelize = new Sequelize(
    process.env.DB_NAME || 'quick_money_db',
    process.env.DB_USER || 'root',
    process.env.DB_PASSWORD || 'apna_password_yahan',
    {
      host: process.env.DB_HOST || 'localhost',
      port: parseInt(process.env.DB_PORT || '3306', 10),
      dialect: 'mysql',
      logging: process.env.NODE_ENV === 'development' ? console.log : false,
      dialectOptions: isCloudDb
        ? {
          ssl: {
            require: true,
            rejectUnauthorized: false,
          },
        }
        : {},
      pool: {
        max: 10,
        min: 0,
        acquire: 30000,
        idle: 10000,
      },
    }
  );
}

module.exports = sequelize;
