import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { ErpService } from './erp-service';
import { BookingEngine } from './booking-engine';
import { UserService } from './user.service';
import { HrFinanceService } from './hr-finance.service'; // Import HrFinanceService

@Module({
  imports: [],
  controllers: [AppController],
  providers: [AppService, ErpService, BookingEngine, UserService, HrFinanceService],
})
export class AppModule {}
