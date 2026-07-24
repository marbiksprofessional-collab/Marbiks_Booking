import { Controller, Get, Post, Body } from '@nestjs/common';
import { AppService } from './app.service';
import { UserService } from './user.service';
import { BookingEngine } from './booking-engine';
import { HrFinanceService } from './hr-finance.service';

@Controller()
export class AppController {
  constructor(
    private readonly appService: AppService,
    private readonly userService: UserService,
    private readonly bookingEngine: BookingEngine,
    private readonly hrFinanceService: HrFinanceService,
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
    return { success: isValid, message: 'Authentication verification token generated.' };
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
}
