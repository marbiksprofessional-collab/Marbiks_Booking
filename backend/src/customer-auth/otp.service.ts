import { BadRequestException, Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import * as bcrypt from 'bcrypt';
import { OtpCode } from './otp-code.entity';
import { Fast2SmsService } from './fast2sms.service';

const OTP_TTL_MINUTES = 5;
const SALT_ROUNDS = 10;

@Injectable()
export class OtpService {
  private readonly logger = new Logger(OtpService.name);

  constructor(
    @InjectRepository(OtpCode)
    private readonly otpRepository: Repository<OtpCode>,
    private readonly smsService: Fast2SmsService,
  ) {}

  /**
   * Generates and sends an OTP for a phone number.
   *
   * If FAST2SMS_API_KEY is configured, the code is sent as a real SMS via
   * Fast2SMS and never included in the response. Otherwise (no gateway
   * configured, e.g. local dev) it falls back to logging the code server-side
   * and, outside production, returning it in the response so the flow can be
   * exercised end-to-end without a real SMS provider.
   */
  async requestOtp(phone: string): Promise<{ devCode?: string }> {
    const code = Math.floor(100000 + Math.random() * 900000).toString();
    const codeHash = await bcrypt.hash(code, SALT_ROUNDS);

    await this.otpRepository.save(
      this.otpRepository.create({
        phone,
        codeHash,
        expiresAt: new Date(Date.now() + OTP_TTL_MINUTES * 60_000),
        consumed: false,
      }),
    );

    if (this.smsService.isConfigured) {
      await this.smsService.sendOtp(phone, code);
      this.logger.log(`OTP sent via Fast2SMS to ${phone}`);
      return {};
    }

    this.logger.log(`OTP for ${phone}: ${code} (expires in ${OTP_TTL_MINUTES}m) - no SMS gateway configured`);

    const isProduction = process.env.NODE_ENV === 'production';
    return isProduction ? {} : { devCode: code };
  }

  async verifyOtp(phone: string, code: string): Promise<void> {
    const otp = await this.otpRepository.findOne({
      where: { phone, consumed: false },
      order: { createdAt: 'DESC' },
    });

    if (!otp) {
      throw new BadRequestException('No OTP was requested for this phone number');
    }
    if (otp.expiresAt.getTime() < Date.now()) {
      throw new BadRequestException('OTP has expired, please request a new one');
    }

    const matches = await bcrypt.compare(code, otp.codeHash);
    if (!matches) {
      throw new BadRequestException('Invalid OTP');
    }

    otp.consumed = true;
    await this.otpRepository.save(otp);
  }
}
