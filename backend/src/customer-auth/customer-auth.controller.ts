import { Body, Controller, HttpCode, HttpStatus, Post } from '@nestjs/common';
import { CustomerAuthService } from './customer-auth.service';
import { RequestOtpDto } from './dto/request-otp.dto';
import { VerifyOtpDto } from './dto/verify-otp.dto';

@Controller('customer-auth')
export class CustomerAuthController {
  constructor(private readonly customerAuthService: CustomerAuthService) {}

  @Post('otp/request')
  @HttpCode(HttpStatus.OK)
  requestOtp(@Body() dto: RequestOtpDto) {
    return this.customerAuthService.requestOtp(dto.phone);
  }

  @Post('otp/verify')
  @HttpCode(HttpStatus.OK)
  verifyOtp(@Body() dto: VerifyOtpDto) {
    return this.customerAuthService.verifyOtpAndLogin(
      dto.phone,
      dto.code,
      dto.fullName,
      dto.email,
    );
  }
}
