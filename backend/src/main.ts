import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import cookieParser from 'cookie-parser';
import helmet from 'helmet';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // Security
  app.use(helmet());
  app.use(cookieParser());

  // CORS (for HTTP and WebSocket)
  app.enableCors({
    origin: ['http://localhost:3000', 'http://localhost:8080'],
    credentials: true,
  });

  // Global prefix
  app.setGlobalPrefix('api');

  // Validation
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
      transformOptions: {
        enableImplicitConversion: true,
      },
    }),
  );

  // Swagger
  const config = new DocumentBuilder()
    .setTitle('NoBroker Owner Listings API')
    .setDescription('Direct owner-to-tenant property marketplace API')
    .setVersion('1.0')
    .addBearerAuth()
    .addTag('auth', 'Authentication')
    .addTag('users', 'User Management')
    .addTag('properties', 'Property Management')
    .addTag('favorites', 'Favorite Properties')
    .addTag('inquiries', 'Property Inquiries')
    .addTag('calls', 'LiveKit Calling')
    .addTag('verification', 'Owner Verification')
    .addTag('agreements', 'Rental Agreements')
    .addTag('movers', 'Movers & Packers')
    .addTag('reminders', 'Reminders')
    .addTag('premium', 'Premium Listings')
    .addTag('admin', 'Admin Operations')
    .build();

  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api/docs', app, document);

  const port = process.env.PORT || 5001;
  await app.listen(port);
  
  console.log(`🚀 Application is running on: http://localhost:${port}/api`);
  console.log(`📚 Swagger documentation: http://localhost:${port}/api/docs`);
}

bootstrap();
