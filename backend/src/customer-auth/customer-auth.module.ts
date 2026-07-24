import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { OtpCode } from './otp-code.entity';
import { OtpService } from './otp.service';
import { CustomerAuthService } from './customer-auth.service';
import { CustomerAuthController } from './customer-auth.controller';
import { CustomersModule } from '../customers/customers.module';
import { AuthModule } from '../auth/auth.module';

@Module({
  imports: [TypeOrmModule.forFeature([OtpCode]), CustomersModule, AuthModule],
  providers: [OtpService, CustomerAuthService],
  controllers: [CustomerAuthController],
})
export class CustomerAuthModule {}
