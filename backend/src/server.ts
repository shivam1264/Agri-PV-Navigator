import { createApp } from './app';
import { connectDB, disconnectDB } from './config/db';
import { env } from './config/env';

const startServer = async () => {
  await connectDB();

  const app = createApp();

  const server = app.listen(env.PORT, () => {
    console.log(`[Server] Agri-PV Navigator API listening on http://localhost:${env.PORT}`);
    console.log(`[Docs] Swagger Documentation available at http://localhost:${env.PORT}/api/docs`);
    console.log(`[Environment] Mode: ${env.NODE_ENV}`);
  });

  const shutdown = async (signal: string) => {
    console.log(`[Server] Received ${signal}. Gracefully shutting down...`);
    server.close(async () => {
      await disconnectDB();
      console.log('[Server] Process terminated cleanly.');
      process.exit(0);
    });
  };

  process.on('SIGINT', () => shutdown('SIGINT'));
  process.on('SIGTERM', () => shutdown('SIGTERM'));
};

startServer();
