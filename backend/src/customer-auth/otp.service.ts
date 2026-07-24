import { BadRequestException, Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import * as bcrypt from 'bcrypt';
import { OtpCode } from './otp-code.entity';

const OTP_TTL_MINUTES = 5;
const SALT_ROUNDS = 10;

@Injectable()
export class OtpService {
  private readonly logger = new Logger(OtpService.name);

  constructor(
    @InjectRepository(OtpCode)
    private readonly otpRepository: Repository<OtpCode>,
  ) {}

  /**
   * Generates and "sends" an OTP for a phone number.
   *
   * There is no SMS gateway wired up yet, so in non-production environments the
   * code is logged to the server console and returned in the response so the
   * flow can be exercised end-to-end without a real SMS provider. Wire an
   * actual gateway (e.g. an SMS API) before relying on this in production, and
   * stop returning the code in the response at that point.
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

    this.logger.log(`OTP for ${phone}: ${code} (expires in ${OTP_TTL_MINUTES}m)`);

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
