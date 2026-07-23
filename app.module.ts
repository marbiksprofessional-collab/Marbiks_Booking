import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { ErpService } from './erp-service';
import { BookingEngine } from './booking-engine';

@Module({
  imports: [],
  controllers: [AppController],
  providers: [AppService, ErpService, BookingEngine],
})
export class AppModule {}
