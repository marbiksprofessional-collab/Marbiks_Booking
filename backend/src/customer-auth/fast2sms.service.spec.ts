import { InternalServerErrorException } from '@nestjs/common';
import { Fast2SmsService, normalizeIndianMobile } from './fast2sms.service';

describe('normalizeIndianMobile', () => {
  it('strips a +91 country code down to the 10-digit number', () => {
    expect(normalizeIndianMobile('+919999999999')).toBe('9999999999');
  });

  it('strips a bare 91 country code down to the 10-digit number', () => {
    expect(normalizeIndianMobile('919999999999')).toBe('9999999999');
  });

  it('leaves an already-bare 10-digit number unchanged', () => {
    expect(normalizeIndianMobile('9999999999')).toBe('9999999999');
  });
});

describe('Fast2SmsService', () => {
  const originalFetch = global.fetch;
  const originalKey = process.env.FAST2SMS_API_KEY;

  afterEach(() => {
    global.fetch = originalFetch;
    process.env.FAST2SMS_API_KEY = originalKey;
  });

  it('is not configured when FAST2SMS_API_KEY is unset', () => {
    delete process.env.FAST2SMS_API_KEY;
    expect(new Fast2SmsService().isConfigured).toBe(false);
  });

  it('is configured once FAST2SMS_API_KEY is set', () => {
    process.env.FAST2SMS_API_KEY = 'test-key';
    expect(new Fast2SmsService().isConfigured).toBe(true);
  });

  it('resolves when Fast2SMS reports success', async () => {
    process.env.FAST2SMS_API_KEY = 'test-key';
    const fetchMock = jest.fn().mockResolvedValue({
      ok: true,
      json: () => Promise.resolve({ return: true, request_id: 'abc' }),
    });
    global.fetch = fetchMock as unknown as typeof fetch;

    const service = new Fast2SmsService();
    await expect(service.sendOtp('+919999999999', '123456')).resolves.toBeUndefined();

    const calledUrl = new URL(fetchMock.mock.calls[0][0] as string);
    expect(calledUrl.origin + calledUrl.pathname).toBe('https://www.fast2sms.com/dev/bulkV2');
    expect(calledUrl.searchParams.get('numbers')).toBe('9999999999');
    expect(calledUrl.searchParams.get('variables_values')).toBe('123456');
  });

  it('throws when Fast2SMS reports failure', async () => {
    process.env.FAST2SMS_API_KEY = 'test-key';
    global.fetch = jest.fn().mockResolvedValue({
      ok: true,
      json: () => Promise.resolve({ return: false, message: 'insufficient balance' }),
    }) as unknown as typeof fetch;

    const service = new Fast2SmsService();
    await expect(service.sendOtp('9999999999', '123456')).rejects.toBeInstanceOf(
      InternalServerErrorException,
    );
  });

  it('throws when the network request itself fails', async () => {
    process.env.FAST2SMS_API_KEY = 'test-key';
    global.fetch = jest.fn().mockRejectedValue(new Error('network down')) as unknown as typeof fetch;

    const service = new Fast2SmsService();
    await expect(service.sendOtp('9999999999', '123456')).rejects.toBeInstanceOf(
      InternalServerErrorException,
    );
  });
});
