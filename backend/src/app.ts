import express, { Request, Response, NextFunction } from 'express';
import helmet from 'helmet';
import cors from 'cors';
import path from 'path';
import swaggerUi from 'swagger-ui-express';
import { env } from './config/env';
import { apiLimiter } from './middleware/rateLimiter';
import { errorHandler } from './middleware/error.middleware';
import { swaggerDocument } from './config/swagger';
import apiRouter from './routes';

export const createApp = (): express.Application => {
  const app = express();

  // Security Middleware
  app.use(
    helmet({
      contentSecurityPolicy: false, // Allows Swagger UI and local development
      crossOriginResourcePolicy: { policy: 'cross-origin' },
    })
  );

  app.use(
    cors({
      origin: env.CORS_ORIGIN === '*' ? true : env.CORS_ORIGIN.split(','),
      credentials: true,
      methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
      allowedHeaders: ['Content-Type', 'Authorization'],
    })
  );

  // Body Parsing
  app.use(express.json({ limit: '10mb' }));
  app.use(express.urlencoded({ extended: true, limit: '10mb' }));

  // Static files for generated PDF reports
  const publicDir = path.resolve(__dirname, '../public');
  app.use('/public', express.static(publicDir));

  // Swagger Documentation
  (app as any).use('/api/docs', swaggerUi.serve, swaggerUi.setup(swaggerDocument));

  // Health Check
  const healthHandler = (req: Request, res: Response) => {
    res.status(200).json({
      status: 'healthy',
      timestamp: new Date().toISOString(),
      service: 'Agri-PV Navigator API',
      version: '1.0.0',
      environment: env.NODE_ENV,
    });
  };
  app.get('/health', healthHandler);
  app.get('/api/health', healthHandler);

  // Rate Limiting on API
  app.use('/api', apiLimiter);

  // Main API Routes
  app.use('/api', apiRouter);

  // 404 Not Found Handler
  app.use((req: Request, res: Response) => {
    res.status(404).json({
      success: false,
      message: `Route not found: ${req.method} ${req.originalUrl}`,
      code: 'ROUTE_NOT_FOUND',
    });
  });

  // Centralized Error Handler
  app.use(errorHandler);

  return app;
};
