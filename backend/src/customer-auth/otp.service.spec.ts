import { BadRequestException } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import * as bcrypt from 'bcrypt';
import { OtpService } from './otp.service';
import { OtpCode } from './otp-code.entity';
import { Fast2SmsService } from './fast2sms.service';

describe('OtpService', () => {
  let service: OtpService;
  let repositoryMock: any;
  let smsServiceMock: { isConfigured: boolean; sendOtp: jest.Mock };

  beforeEach(async () => {
    repositoryMock = {
      create: jest.fn((data) => data),
      save: jest.fn((data) => Promise.resolve({ id: 'otp-1', ...data })),
      findOne: jest.fn(),
    };
    // Unconfigured by default (no FAST2SMS_API_KEY) - matches local dev / test env
    // where devCode is what tests exercise. Individual tests can flip isConfigured.
    smsServiceMock = { isConfigured: false, sendOtp: jest.fn().mockResolvedValue(undefined) };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        OtpService,
        { provide: getRepositoryToken(OtpCode), useValue: repositoryMock },
        { provide: Fast2SmsService, useValue: smsServiceMock },
      ],
    }).compile();

    service = module.get(OtpService);
    process.env.NODE_ENV = 'test';
  });

  it('generates and stores a hashed 6-digit OTP, returning the raw code outside production', async () => {
    const result = await service.requestOtp('9999999999');

    expect(result.devCode).toMatch(/^\d{6}$/);
    expect(repositoryMock.save).toHaveBeenCalled();
    const saved = repositoryMock.save.mock.calls[0][0];
    expect(saved.codeHash).not.toBe(result.devCode);
    expect(await bcrypt.compare(result.devCode!, saved.codeHash)).toBe(true);
  });

  it('does not return the code in production', async () => {
    process.env.NODE_ENV = 'production';
    const result = await service.requestOtp('9999999999');
    expect(result.devCode).toBeUndefined();
    process.env.NODE_ENV = 'test';
  });

  it('sends via the SMS gateway and never returns the code when one is configured', async () => {
    smsServiceMock.isConfigured = true;

    const result = await service.requestOtp('9999999999');

    expect(smsServiceMock.sendOtp).toHaveBeenCalledWith('9999999999', expect.stringMatching(/^\d{6}$/));
    expect(result.devCode).toBeUndefined();
  });

  it('propagates the gateway error instead of reporting success when the SMS send fails', async () => {
    smsServiceMock.isConfigured = true;
    smsServiceMock.sendOtp.mockRejectedValue(new Error('Fast2SMS down'));

    await expect(service.requestOtp('9999999999')).rejects.toThrow('Fast2SMS down');
  });

  it('verifies a correct, unexpired OTP and marks it consumed', async () => {
    const codeHash = await bcrypt.hash('123456', 10);
    repositoryMock.findOne.mockResolvedValue({
      id: 'otp-1',
      phone: '9999999999',
      codeHash,
      expiresAt: new Date(Date.now() + 60_000),
      consumed: false,
    });

    await service.verifyOtp('9999999999', '123456');

    expect(repositoryMock.save).toHaveBeenCalledWith(expect.objectContaining({ consumed: true }));
  });

  it('rejects an incorrect code', async () => {
    const codeHash = await bcrypt.hash('123456', 10);
    repositoryMock.findOne.mockResolvedValue({
      id: 'otp-1',
      phone: '9999999999',
      codeHash,
      expiresAt: new Date(Date.now() + 60_000),
      consumed: false,
    });

    await expect(service.verifyOtp('9999999999', '000000')).rejects.toBeInstanceOf(
      BadRequestException,
    );
  });

  it('rejects an expired code', async () => {
    const codeHash = await bcrypt.hash('123456', 10);
    repositoryMock.findOne.mockResolvedValue({
      id: 'otp-1',
      phone: '9999999999',
      codeHash,
      expiresAt: new Date(Date.now() - 1_000),
      consumed: false,
    });

    await expect(service.verifyOtp('9999999999', '123456')).rejects.toBeInstanceOf(
      BadRequestException,
    );
  });

  it('rejects verification when no OTP was requested', async () => {
    repositoryMock.findOne.mockResolvedValue(null);

    await expect(service.verifyOtp('9999999999', '123456')).rejects.toBeInstanceOf(
      BadRequestException,
    );
  });
});
