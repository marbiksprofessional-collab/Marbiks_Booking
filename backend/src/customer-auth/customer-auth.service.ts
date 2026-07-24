import { Injectable } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { OtpService } from './otp.service';
import { CustomersService } from '../customers/customers.service';
import { Role } from '../common/enums/role.enum';
import { JwtPayload } from '../auth/jwt.strategy';

@Injectable()
export class CustomerAuthService {
  constructor(
    private readonly otpService: OtpService,
    private readonly customersService: CustomersService,
    private readonly jwtService: JwtService,
  ) {}

  requestOtp(phone: string) {
    return this.otpService.requestOtp(phone);
  }

  async verifyOtpAndLogin(
    phone: string,
    code: string,
    fullName?: string,
    email?: string,
  ) {
    await this.otpService.verifyOtp(phone, code);
    const customer = await this.customersService.findOrCreateByPhone(phone, fullName, email);

    const payload: JwtPayload = {
      sub: customer.id,
      phone: customer.phone,
      role: Role.CUSTOMER,
      branchId: null,
    };

    return {
      accessToken: this.jwtService.sign(payload),
      user: {
        id: customer.id,
        fullName: customer.fullName,
        phone: customer.phone,
        email: customer.email,
        role: Role.CUSTOMER,
        loyaltyPoints: customer.loyaltyPoints,
      },
    };
  }
}
