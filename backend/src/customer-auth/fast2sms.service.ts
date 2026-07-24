import { Injectable, InternalServerErrorException, Logger } from '@nestjs/common';

const FAST2SMS_OTP_URL = 'https://www.fast2sms.com/dev/bulkV2';

/**
 * Fast2SMS expects a plain 10-digit Indian mobile number for its OTP route
 * (no country code, no leading zero/plus). Customers may have registered
 * with "+91XXXXXXXXXX", "91XXXXXXXXXX", or a bare 10-digit number - this
 * normalizes all of those to the last 10 digits.
 */
export function normalizeIndianMobile(phone: string): string {
  return phone.replace(/\D/g, '').slice(-10);
}

@Injectable()
export class Fast2SmsService {
  private readonly logger = new Logger(Fast2SmsService.name);
  private readonly apiKey = process.env.FAST2SMS_API_KEY;

  /** True once a real API key is configured - callers use this to decide whether the devCode fallback still applies. */
  get isConfigured(): boolean {
    return !!this.apiKey;
  }

  /**
   * Sends an OTP via Fast2SMS's OTP route: https://docs.fast2sms.com/ (route=otp).
   * Throws if Fast2SMS itself is unreachable or reports failure, so callers don't
   * report success for an OTP that never actually went out.
   */
  async sendOtp(phone: string, code: string): Promise<void> {
    const number = normalizeIndianMobile(phone);
    const url = new URL(FAST2SMS_OTP_URL);
    url.searchParams.set('authorization', this.apiKey!);
    url.searchParams.set('route', 'otp');
    url.searchParams.set('variables_values', code);
    url.searchParams.set('numbers', number);

    let response: Response;
    try {
      response = await fetch(url.toString(), { method: 'GET' });
    } catch (error) {
      this.logger.error(`Fast2SMS request failed for ${phone}: ${(error as Error).message}`);
      throw new InternalServerErrorException('Could not send OTP SMS, please try again shortly');
    }

    const body: unknown = await response.json().catch(() => null);
    const ok = response.ok && !!(body as { return?: boolean } | null)?.return;

    if (!ok) {
      this.logger.error(`Fast2SMS rejected send for ${phone}: ${JSON.stringify(body)}`);
      throw new InternalServerErrorException('Could not send OTP SMS, please try again shortly');
    }
  }
}
