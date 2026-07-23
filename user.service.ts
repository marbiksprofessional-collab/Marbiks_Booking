import { Injectable, HttpException, HttpStatus } from '@nestjs/common';

@Injectable()
export class UserService {
  // Temporary local cache to hold OTP codes for 5 minutes (in production, this uses Redis)
  private otpMap = new Map<string, { code: string; expiresAt: number }>();

  /**
   * 📱 Generates a secure 6-digit OTP for Customer Login
   */
  async generateOtp(phoneNumber: string): Promise<{ sessionToken: string; message: string }> {
    if (!phoneNumber || phoneNumber.length < 10) {
      throw new HttpException('Invalid phone number format.', HttpStatus.BAD_REQUEST);
    }

    // Generate a random 6-digit number
    const generatedCode = Math.floor(100000 + Math.random() * 900000).toString();
    const expiryTime = Date.now() + 5 * 60 * 1000; // Expires in 5 minutes

    // Store in cache map
    this.otpMap.set(phoneNumber, { code: generatedCode, expiresAt: expiryTime });

    console.log(`[SMS Gateway Simulated] Sending OTP ${generatedCode} to user: ${phoneNumber}`);
    
    // In actual production, this integration triggers bulk SMS / WhatsApp Business APIs
    return {
      sessionToken: Buffer.from(phoneNumber).toString('base64'),
      message: 'OTP sent successfully. Valid for 5 minutes.',
    };
  }

  /**
   * 🔑 Verifies the OTP code submitted by the tablet/mobile app
   */
  async verifyOtp(phoneNumber: string, submittedCode: string): Promise<boolean> {
    const activeOtp = this.otpMap.get(phoneNumber);

    if (!activeOtp) {
      throw new HttpException('No active OTP request found for this number.', HttpStatus.NOT_FOUND);
    }

    if (Date.now() > activeOtp.expiresAt) {
      this.otpMap.delete(phoneNumber);
      throw new HttpException('OTP has expired. Please request a new code.', HttpStatus.GONE);
    }

    if (activeOtp.code !== submittedCode) {
      throw new HttpException('Incorrect OTP code verification failed.', HttpStatus.UNAUTHORIZED);
    }

    // Clear OTP code from memory after successful login
    this.otpMap.delete(phoneNumber);
    return true;
  }
}
