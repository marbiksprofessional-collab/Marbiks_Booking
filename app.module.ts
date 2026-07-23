import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { ErpService } from './erp-service';
import { BookingEngine } from './booking-engine';
import { UserService } from './user.service'; // Import UserService

@Module({
  imports: [],
    controllers: [AppController],
      providers: [AppService, ErpService, BookingEngine, UserService], // Registered UserService globally
      })
      export class AppModule {}
      