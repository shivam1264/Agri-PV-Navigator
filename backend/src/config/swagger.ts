export const swaggerDocument = {
  openapi: '3.0.0',
  info: {
    title: 'Agri-PV Navigator API',
    version: '1.0.0',
    description: 'Production REST API for Agrivoltaics System Design, GIS Suitability, 3D Twin & Bankable Reports',
  },
  servers: [
    {
      url: 'http://localhost:5000',
      description: 'Local Development Server',
    },
  ],
  components: {
    securitySchemes: {
      bearerAuth: {
        type: 'http',
        scheme: 'bearer',
        bearerFormat: 'JWT',
      },
    },
  },
  security: [
    {
      bearerAuth: [],
    },
  ],
  paths: {
    '/api/auth/register': {
      post: {
        tags: ['Auth'],
        summary: 'Register a new user account',
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: {
                type: 'object',
                required: ['firstName', 'lastName', 'email', 'password'],
                properties: {
                  firstName: { type: 'string', example: 'Shivam' },
                  lastName: { type: 'string', example: 'Kumar' },
                  email: { type: 'string', example: 'shivam@example.com' },
                  password: { type: 'string', example: 'StrongPassword123!' },
                  phone: { type: 'string', example: '+91 98765 43210' },
                },
              },
            },
          },
        },
        responses: {
          201: { description: 'User registered successfully' },
          409: { description: 'Email already exists' },
        },
      },
    },
    '/api/auth/login': {
      post: {
        tags: ['Auth'],
        summary: 'Log in with email and password',
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: {
                type: 'object',
                required: ['email', 'password'],
                properties: {
                  email: { type: 'string', example: 'shivam@example.com' },
                  password: { type: 'string', example: 'StrongPassword123!' },
                },
              },
            },
          },
        },
        responses: {
          200: { description: 'Authenticated successfully with tokens' },
          401: { description: 'Invalid credentials' },
        },
      },
    },
    '/api/auth/refresh': {
      post: {
        tags: ['Auth'],
        summary: 'Refresh expired access token',
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: {
                type: 'object',
                required: ['refreshToken'],
                properties: {
                  refreshToken: { type: 'string' },
                },
              },
            },
          },
        },
        responses: {
          200: { description: 'New access token generated' },
          401: { description: 'Invalid or expired refresh token' },
        },
      },
    },
    '/api/auth/me': {
      get: {
        tags: ['Auth'],
        summary: 'Get current authenticated user profile',
        responses: {
          200: { description: 'User profile returned' },
          401: { description: 'Unauthorized' },
        },
      },
    },
    '/api/farms': {
      get: {
        tags: ['Farms'],
        summary: 'List user farms with optional query search',
        responses: {
          200: { description: 'Farms list returned' },
        },
      },
      post: {
        tags: ['Farms'],
        summary: 'Create and analyze a new farm',
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: {
                type: 'object',
                required: ['name', 'locationName', 'areaAcres', 'cropType'],
                properties: {
                  name: { type: 'string', example: 'Farm Alpha' },
                  locationName: { type: 'string', example: 'Phulpur, Prayagraj' },
                  areaAcres: { type: 'number', example: 2.35 },
                  cropType: { type: 'string', example: 'Wheat' },
                  soilType: { type: 'string', example: 'Loamy' },
                  slope: { type: 'string', example: '< 2% (Almost flat)' },
                  irrigation: { type: 'string', example: 'Available' },
                  gridProximityKm: { type: 'number', example: 2.4 },
                },
              },
            },
          },
        },
        responses: {
          201: { description: 'Farm created and analyzed' },
        },
      },
    },
    '/api/farms/{farmId}/suitability': {
      get: {
        tags: ['Suitability'],
        summary: 'Get multi-factor site suitability analysis for farm',
        responses: {
          200: { description: 'Suitability analysis returned' },
        },
      },
    },
    '/api/farms/{farmId}/designs': {
      get: {
        tags: ['Designs'],
        summary: 'Get saved Agri-PV designs for comparison',
        responses: {
          200: { description: 'Designs returned' },
        },
      },
      post: {
        tags: ['Designs'],
        summary: 'Create a new Agri-PV system design',
        responses: {
          201: { description: 'Design saved with dynamic metrics' },
        },
      },
    },
    '/api/designs/{id}/visualization-config': {
      get: {
        tags: ['Visualization'],
        summary: 'Get 3D scene parameters for digital twin and AR viewport',
        responses: {
          200: { description: '3D scene configuration returned' },
        },
      },
    },
    '/api/designs/{id}/economics': {
      get: {
        tags: ['Economics'],
        summary: 'Get 25-year techno-economic financial assessment',
        responses: {
          200: { description: 'Economic assessment returned' },
        },
      },
    },
    '/api/reports/generate': {
      post: {
        tags: ['Reports'],
        summary: 'Generate a downloadable PDF proposal report',
        responses: {
          201: { description: 'PDF report generated and stored' },
        },
      },
    },
    '/api/dashboard/summary': {
      get: {
        tags: ['Dashboard'],
        summary: 'Get live home screen statistics and recent farms',
        responses: {
          200: { description: 'Dashboard metrics returned' },
        },
      },
    },
  },
};
