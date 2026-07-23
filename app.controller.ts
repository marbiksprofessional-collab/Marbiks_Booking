import { Controller, Get, Post, Body } from '@nestjs/common';
import { AppService } from './app.service';
import { UserService } from './user.service';
import { BookingEngine } from './booking-engine';

@Controller()
export class AppController {
  constructor(
    private readonly appService: AppService,
    private readonly userService: UserService,
    private readonly bookingEngine: BookingEngine,
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
}
