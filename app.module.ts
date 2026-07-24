import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { ErpService } from './erp-service';
import { BookingEngine } from './booking-engine';
import { UserService } from './user.service';
import { HrFinanceService } from './hr-finance.service';
import { SecurityAuditService } from './security-audit.service';
import { NotificationHubService } from './notification-hub.service';
import { BiometricAttendanceService } from './biometric-attendance.service';
import { FranchiseRoyaltyService } from './franchise-royalty.service';
import { AcademyService } from './academy.service';
import { ServiceWorkflowEngine } from './service-workflow.service';
import { AdvancedAutomationEngine } from './advanced-automation.service';
import { FraudControlService } from './fraud-control.service';
import { SopComplianceEngine } from './sop-compliance.service'; // Import SOP Compliance service

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
    BiometricAttendanceService,
    FranchiseRoyaltyService,
    AcademyService,
    ServiceWorkflowEngine,
    AdvancedAutomationEngine,
    FraudControlService,
    SopComplianceEngine // Registered globally
  ],
})
export class AppModule {}
