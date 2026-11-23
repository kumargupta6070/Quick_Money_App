const swaggerJSDoc = require('swagger-jsdoc');

const swaggerDefinition = {
  openapi: '3.0.0',
  info: {
    title: '⚡ Quick Money Enterprise API Documentation',
    version: '1.0.0',
    description: `
**Quick Money FinTech API Specification**
- **Authentication:** JWT Bearer Token (24h validity)
- **Encryption:** AES-256-CBC with SHA-256 mobile hashing
- **Email OTP Service:** Brevo (Sendinblue) SMTP Relay (300 free emails/day)
- **Security:** Military-grade FIPS 140-2 Level 3 compliant storage
    `,
    contact: {
      name: 'Quick Money Technical Architecture Team',
      email: 'security@quickmoney.in',
    },
  },
  servers: [
    {
      url: process.env.SWAGGER_SERVER_URL || 'http://localhost:5000',
      description: 'Local Development Server',
    },
    {
      url: 'https://api.quickmoney.in',
      description: 'Production Cloud Cluster',
    },
  ],
  components: {
    securitySchemes: {
      BearerAuth: {
        type: 'http',
        scheme: 'bearer',
        bearerFormat: 'JWT',
        description: 'Enter your JWT token obtained from /api/v1/auth/login or /api/v1/auth/register',
      },
    },
    schemas: {
      ApiResponse: {
        type: 'object',
        properties: {
          success: { type: 'boolean', example: true },
          message: { type: 'string', example: 'Operation completed successfully' },
          data: { type: 'object' },
        },
      },
      SendOtpRequest: {
        type: 'object',
        required: ['email'],
        properties: {
          email: { type: 'string', format: 'email', example: 'investor@gmail.com' },
          type: { type: 'string', enum: ['register', 'forgot_password', 'login'], example: 'register' },
          mobile: { type: 'string', example: '9835913180' },
        },
      },
      VerifyOtpRequest: {
        type: 'object',
        required: ['email', 'otp'],
        properties: {
          email: { type: 'string', format: 'email', example: 'investor@gmail.com' },
          otp: { type: 'string', example: '481920' },
          type: { type: 'string', enum: ['register', 'forgot_password'], example: 'register' },
        },
      },
      RegisterRequest: {
        type: 'object',
        required: ['mobile', 'email', 'password', 'otp'],
        properties: {
          mobile: { type: 'string', example: '9835913180' },
          email: { type: 'string', format: 'email', example: 'investor@gmail.com' },
          password: { type: 'string', format: 'password', example: 'SecurePass@123' },
          inviteCode: { type: 'string', example: 'x0rZx2y0' },
          otp: { type: 'string', example: '481920' },
        },
      },
      LoginRequest: {
        type: 'object',
        required: ['password'],
        properties: {
          mobile: { type: 'string', example: '9835913180', description: '10-Digit Registered Mobile Number' },
          email: { type: 'string', format: 'email', example: 'demo@quickmoney.in', description: 'Registered Email Address' },
          password: { type: 'string', format: 'password', example: 'Demo@12345' },
        },
      },
      ResetPasswordRequest: {
        type: 'object',
        required: ['email', 'otp', 'newPassword'],
        properties: {
          email: { type: 'string', format: 'email', example: 'investor@gmail.com' },
          otp: { type: 'string', example: '481920' },
          newPassword: { type: 'string', format: 'password', example: 'NewSecretPass@123' },
        },
      },
      UserProfile: {
        type: 'object',
        properties: {
          id: { type: 'integer', example: 1 },
          mobile: { type: 'string', example: '9835913180' },
          email: { type: 'string', example: 'investor@gmail.com' },
          invite_code: { type: 'string', example: 'x0a8c2d1' },
          balance: { type: 'number', example: 51.07 },
          level: { type: 'string', example: 'L1' },
          role: { type: 'string', example: 'user' },
        },
      },
    },
  },
  paths: {
    '/api/health': {
      get: {
        summary: 'System Health & Security Check',
        tags: ['System'],
        responses: {
          200: {
            description: 'API is online and operational',
          },
        },
      },
    },
    '/api/v1/auth/send-otp': {
      post: {
        summary: 'Send 6-Digit Email Verification Code via Brevo SMTP',
        tags: ['Authentication'],
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: { $ref: '#/components/schemas/SendOtpRequest' },
            },
          },
        },
        responses: {
          200: {
            description: 'OTP sent successfully to email',
            content: {
              'application/json': {
                schema: { $ref: '#/components/schemas/ApiResponse' },
              },
            },
          },
          400: { description: 'Validation error or already registered' },
        },
      },
    },
    '/api/v1/auth/verify-otp': {
      post: {
        summary: 'Validate 6-Digit Verification Code',
        tags: ['Authentication'],
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: { $ref: '#/components/schemas/VerifyOtpRequest' },
            },
          },
        },
        responses: {
          200: { description: 'OTP verified successfully' },
          400: { description: 'Invalid or expired OTP' },
        },
      },
    },
    '/api/v1/auth/register': {
      post: {
        summary: 'Register New Account with Email OTP & Welcome Bonus',
        tags: ['Authentication'],
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: { $ref: '#/components/schemas/RegisterRequest' },
            },
          },
        },
        responses: {
          201: {
            description: 'Account registered successfully with welcome bonus ₹51.07 credited and JWT issued',
            content: {
              'application/json': {
                schema: { $ref: '#/components/schemas/ApiResponse' },
              },
            },
          },
          400: { description: 'Registration failed or invalid OTP' },
        },
      },
    },
    '/api/v1/auth/login': {
      post: {
        summary: 'User Login (Mobile + Password)',
        tags: ['Authentication'],
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: { $ref: '#/components/schemas/LoginRequest' },
            },
          },
        },
        responses: {
          200: {
            description: 'Authentication successful. Returns JWT and user role (user/admin)',
            content: {
              'application/json': {
                schema: { $ref: '#/components/schemas/ApiResponse' },
              },
            },
          },
          400: { description: 'Invalid credentials or account suspended' },
        },
      },
    },
    '/api/v1/auth/reset-password': {
      post: {
        summary: 'Reset Forgotten Password via Email OTP',
        tags: ['Authentication'],
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: { $ref: '#/components/schemas/ResetPasswordRequest' },
            },
          },
        },
        responses: {
          200: { description: 'Password reset successfully' },
          400: { description: 'Invalid code or password requirements not met' },
        },
      },
    },
    '/api/v1/auth/me': {
      get: {
        summary: 'Get Active User Profile & Vault Balance',
        tags: ['Authentication'],
        security: [{ BearerAuth: [] }],
        responses: {
          200: {
            description: 'Current user profile fetched successfully',
            content: {
              'application/json': {
                schema: { $ref: '#/components/schemas/ApiResponse' },
              },
            },
          },
          401: { description: 'Unauthorized or token expired' },
        },
      },
    },
  },
};

const swaggerOptions = {
  swaggerDefinition,
  apis: ['./src/routes/*.js'],
};

const swaggerSpec = swaggerJSDoc(swaggerOptions);

module.exports = swaggerSpec;

