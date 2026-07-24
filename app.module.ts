import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { ErpService } from './erp-service';
import { BookingEngine } from './booking-engine';
import { UserService } from './user.service';
import { HrFinanceService } from './hr-finance.service';
import { SecurityAuditService } from './security-audit.service';
import { NotificationHubService } from './notification-hub.service';
import { BiometricAttendanceService } from './biometric-attendance.service'; // Import service

@Module({
  imports: [],
  controllers: [AppController],
  providers: [
    AppService, 
    ErpService, 
    BookingEngine, 
    UserService, 
    HrFinanceService, 
    SecurityAuditService,
    NotificationHubService,
    BiometricAttendanceService // Registered service globally
  ],
})
export class AppModule {}
