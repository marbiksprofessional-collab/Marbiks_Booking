   import { Controller, Get, Post, Body } from '@nestjs/common';
import { AppService } from './app.service';
import { UserService } from './user.service';
import { BookingEngine } from './booking-engine';
import { HrFinanceService } from './hr-finance.service';
import { SecurityAuditService } from './security-audit.service';
import { NotificationHubService } from './notification-hub.service';
import { BiometricAttendanceService } from './biometric-attendance.service';

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
    return { success: false, message: 'Authentication verification token generation failed.' };
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
}
                                                                      