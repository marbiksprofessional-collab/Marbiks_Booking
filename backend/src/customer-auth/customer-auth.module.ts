import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { OtpCode } from './otp-code.entity';
import { OtpService } from './otp.service';
import { Fast2SmsService } from './fast2sms.service';
import { CustomerAuthService } from './customer-auth.service';
import { CustomerAuthController } from './customer-auth.controller';
import { CustomersModule } from '../customers/customers.module';
import { AuthModule } from '../auth/auth.module';

@Module({
  imports: [TypeOrmModule.forFeature([OtpCode]), CustomersModule, AuthModule],
  providers: [OtpService, Fast2SmsService, CustomerAuthService],
  controllers: [CustomerAuthController],
})
export class CustomerAuthModule {}
