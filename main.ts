import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  // Creating the NestJS Application Instance
  const app = await NestFactory.create(AppModule);

  // Enabling CORS so your Flutter Mobile/Web App can connect safely
  app.enableCors();

  // Setting up a Global API Prefix (e.g., ://myapi.com...)
  app.setGlobalPrefix('api/v1');

  // The server will listen on Port 3000 (standard for backend services)
  const port = process.env.PORT || 3000;
  await app.listen(port);
  
  console.log(`🚀 Marbiks Backend Layer is running on: http://localhost:${port}/api/v1`);
}

bootstrap();
