import { Controller, Get, Post, Body } from '@nestjs/common';
import { AppService } from './app.service';
import { UserService } from './user.service';
import { BookingEngine } from './booking-engine';
import { HrFinanceService } from './hr-finance.service';
import { SecurityAuditService } from './security-audit.service';
import { NotificationHubService } from './notification-hub.service';
import { BiometricAttendanceService } from './biometric-attendance.service';
import { FranchiseRoyaltyService } from './franchise-royalty.service';
import { AcademyService } from './academy.service';
import { ServiceWorkflowEngine } from './service-workflow.service';
import { AdvancedAutomationEngine } from './advanced-automation.service';
import { FraudControlService } from './fraud-control.service';
import { SopEngineService } from './sop-engine.service';
import { AntiProxyService } from './anti-proxy.service';
import { FairTurnAutomationService } from './fair-turn-automation.service';

@Controller()
export class AppController {
  constructor(
    private readonly appService: AppService,
    private readonly userService: UserService,
    private readonly bookingEngine: BookingEngine,
    private readonly hrFinanceService: HrFinanceService,
    private readonly securityAuditService: SecurityAuditService,
    private readonly notificationHubService: NotificationHubService,
    private readonly biometricAttendanceService: BiometricAttendanceService,
    private readonly franchiseRoyaltyService: FranchiseRoyaltyService,
    private readonly academyService: AcademyService,
    private readonly serviceWorkflowEngine: ServiceWorkflowEngine,
    private readonly advancedAutomationEngine: AdvancedAutomationEngine,
    private readonly fraudControlService: FraudControlService,
    private readonly sopEngineService: SopEngineService,
    private readonly antiProxyService: AntiProxyService,
    private readonly fairTurnAutomationService: FairTurnAutomationService,
  ) {}

  // 🏥 1. System Health Check Endpoint
  @Get('health')
  getHealthCheck() {
    return this.appService.checkSystemHealth();
  }

  // 📱 2. Request OTP Token Endpoint
  @Post('auth/otp/request')
  async requestOtp(@Body() body: { phoneNumber: string }) {
    return await this.userService.generateOtp(body.phoneNumber);
  }

  // 🔑 3. Verify OTP Code Endpoint
  @Post('auth/otp/verify')
  async verifyOtp(@Body() body: { phoneNumber: string; otpCode: string }) {
    const isValid = await this.userService.verifyOtp(body.phoneNumber, body.otpCode);
    if (isValid) {
      return this.securityAuditService.generateSessionToken('user_id_placeholder', 'Customer', 'branch_id_placeholder');
    }
    return { success: false, message: 'Authentication token generation failed.' };
  }

  // 📅 4. AI-Routed Smart Appointment Booking Endpoint
  @Post('appointments/book')
  async bookAppointment(@Body() bookingPayload: {
    branchId: string;
    customerId: string;
    technicianId: string;
    resourceType: string;
    requestedStart: string;
    requestedEnd: string;
  }) {
    return await this.bookingEngine.validateAndRouteBooking(bookingPayload);
  }

  // 👥 5. HR Payroll Microservices Endpoint
  @Post('hr/payroll/calculate')
  calculatePayroll(@Body() payrollData: {
    baseSalary: number;
    incentives: number;
    leavesTaken: number;
    workingDays: number;
  }) {
    return this.hrFinanceService.calculateStaffSalary(payrollData);
  }

  // 📊 6. Automated GST Invoice Calculator Endpoint
  @Post('finance/invoice/gst-reconcile')
  reconcileGstInvoice(@Body() body: { baseAmount: number }) {
    return this.hrFinanceService.generateTaxInvoiceMetrics(body.baseAmount);
  }

  // 🛡️ 7. Manual Security Audit Log Generator Endpoint
  @Post('security/audit/log')
  createAuditLog(@Body() body: { actorId: string; role: string; action: string; branchId: string; changes: any }) {
    this.securityAuditService.logAdminAction(body.actorId, body.role, body.action, body.branchId, body.changes);
    return { status: 'success', message: 'Immutable security log captured successfully.' };
  }

  // 📲 8. Live Push Notification Hub Endpoint
  @Post('notifications/push/send')
  async triggerPush(@Body() body: { userId: string; title: string; body: string }) {
    return await this.notificationHubService.sendPushNotification(body.userId, body.title, body.body);
  }

  // 💬 9. Automated WhatsApp Broadcast API Endpoint
  @Post('notifications/whatsapp/alert')
  async triggerWhatsApp(@Body() body: { phoneNumber: string; template: string; variables: string[] }) {
    return await this.notificationHubService.sendWhatsAppAlert(body.phoneNumber, body.template, body.variables);
  }

  // 🎛️ 10. IoT Physical Biometric Device Sync Endpoint
  @Post('biometric/device/scan')
  logBiometricScan(@Body() body: { staffId: string; deviceId: string; type: 'clock_in' | 'clock_out' }) {
    return this.biometricAttendanceService.logDeviceScan(body.staffId, body.deviceId, body.type);
  }

  // 👤 11. AI Facial Recognition Verification Endpoint
  @Post('biometric/facial/verify')
  logFacialAttendance(@Body() body: { staffId: string; faceVector: number[] }) {
    return this.biometricAttendanceService.verifyFacialAttendance(body.staffId, body.faceVector);
  }

  // 👑 12. Franchise Royalty Payout Processing Endpoint
  @Post('franchise/royalty/calculate')
  processRoyalty(@Body() body: { branchId: string; grossRevenue: number }) {
    return this.franchiseRoyaltyService.calculateBranchRoyalty(body.branchId, body.grossRevenue);
  }

  // 📈 13. Multi-Branch Network Leaderboard Comparison Endpoint
  @Post('franchise/network/compare')
  compareNetworkPerformances(@Body() body: { branches: Array<{ branchId: string; salesAmount: number }> }) {
    return this.franchiseRoyaltyService.compareBranchPerformances(body.branches);
  }

  // 🎓 14. Academy Student Enrollment & Fee Ledger Endpoint
  @Post('academy/student/enroll')
  enrollStudent(@Body() body: { studentName: string; courseName: string; totalFee: number; amountPaid: number }) {
    return this.academyService.processStudentAdmission(body);
  }

  // 📜 15. Academy Smart Certificate Generation Endpoint
  @Post('academy/student/issue-certificate')
  generateCertificate(@Body() body: { studentId: string; examScore: number; courseName: string }) {
    return this.academyService.issueCourseCertificate(body.studentId, body.examScore, body.courseName);
  }

  // 🧠 16. AI Smart Scheduling Matrix Optimization Endpoint
  @Post('automation/scheduler/optimize')
  async optimizeScheduler(@Body() body: any) {
    return await this.advancedAutomationEngine.optimizeResourceAllocation(body);
  }

  // 🧪 17. Micro-Consumption Material Gram Logger Endpoint
  @Post('automation/inventory/log-grams')
  logGramsUsed(@Body() body: { serviceId: string; staffId: string; product: string; grams: number }) {
    this.advancedAutomationEngine.logMaterialConsumption(body.serviceId, body.staffId, body.product, body.grams);
    return { status: 'success', message: 'Material gram consumption updated.' };
  }

  // 📊 18. Custom Date Range Enterprise Analytics Report Endpoint
  @Post('automation/reports/performance')
  getPerformanceReport(@Body() body: { start: string; end: string }) {
    return this.advancedAutomationEngine.generateCustomPerformanceReport(body.start, body.end);
  }

  // 🚨 19. Hardware IoT Chair Sensor Traffic Sync Endpoint
  @Post('fraud/iot/chair-sensor')
  syncChairSensor(@Body() body: { branchId: string; chairId: string; occupied: boolean }) {
    this.fraudControlService.logChairSensorState(body.branchId, body.chairId, body.occupied);
    return { status: 'synced' };
  }

  // 🔍 20. Live Front Office Executive Cheat Auditor Audit Loop Endpoint
  @Post('fraud/audit/verify-transparency')
  auditFrontOffice(@Body() body: { branchId: string; activeBillingIds: string[] }) {
    return this.fraudControlService.verifyWalkInTransparency(body.branchId, body.activeBillingIds);
  }

  // 📋 21. Departmental SOP Template Configuration Endpoint
  @Post('sop/templates/configure')
  configureSop(@Body() body: { department: string; items: string[] }) {
    return this.sopEngineService.configureDepartmentalSop(body.department, body.items);
  }

  // 🔒 22. Staff Daily SOP Checklist Logging Endpoint
  @Post('sop/checklist/submit')
  submitSopChecklist(@Body() body: { branchId: string; staffId: string; department: string; checkList: any }) {
    return this.sopEngineService.logDailySopSubmission(body.branchId, body.staffId, body.department, body.checkList);
  }

  // 🚨 23. Manager/Admin Digital SOP Inspection Audit Endpoint
  @Post('sop/audit/inspect')
  triggerSopInspection(@Body() body: { auditId: string; managerId: string; branchId: string; score: number; notes: string }) {
    return this.sopEngineService.executeManagerSopAudit(body.auditId, body.managerId, body.branchId, body.score, body.notes);
  }

  // 🔒 24. Zero-Device Technician Service Clock-Lock Activation Endpoint
  @Post('proxy/clock-lock/activate')
  lockTech(@Body() body: { staffId: string; appointmentId: string }) {
    return this.antiProxyService.lockTechnicianToService(body.staffId, body.appointmentId);
  }

  // 🔓 25. Store Room Physical Material Audit & Technician Release Endpoint
  @Post('proxy/clock-lock/release')
  releaseTech(@Body() body: { staffId: string; grams: number }) {
    return this.antiProxyService.releaseTechnicianFromService(body.staffId, body.grams);
  }

  // ⏳ 26. Store Room Lingering Anomaly Auditor Tracker Endpoint
  @Post('proxy/audit/store-room-timeout')
  auditStoreRoom(@Body() body: { staffId: string; minutesSpent: number }) {
    return this.antiProxyService.auditUnproductiveStoreRoomTime(body.staffId, body.minutesSpent);
  }

  // ⚙️ 27. Admin Dynamic Penalty Fine Configuration Update Endpoint
  @Post('fair-turn/admin/configure-penalty')
  updatePenaltyConfig(@Body() body: { penaltyFine: number }) {
