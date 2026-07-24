import { BadRequestException, ConflictException } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { AttendanceService } from './attendance.service';
import { AttendanceRecord } from './attendance.entity';

describe('AttendanceService', () => {
  let service: AttendanceService;
  let repositoryMock: any;

  beforeEach(async () => {
    repositoryMock = {
      create: jest.fn((data) => data),
      save: jest.fn((data) => ({ id: 'record-1', ...data })),
      findOne: jest.fn(),
      createQueryBuilder: jest.fn(),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AttendanceService,
        { provide: getRepositoryToken(AttendanceRecord), useValue: repositoryMock },
      ],
    }).compile();

    service = module.get(AttendanceService);
  });

  it('clocks in when there is no open record', async () => {
    repositoryMock.findOne.mockResolvedValue(null);

    const record = await service.clockIn('user-1', 'branch-1');

    expect(record.userId).toBe('user-1');
    expect(record.clockOutAt).toBeNull();
    expect(repositoryMock.save).toHaveBeenCalled();
  });

  it('rejects clocking in twice without clocking out', async () => {
    repositoryMock.findOne.mockResolvedValue({ id: 'existing', clockOutAt: null });

    await expect(service.clockIn('user-1', 'branch-1')).rejects.toBeInstanceOf(ConflictException);
  });

  it('clocks out an open record', async () => {
    repositoryMock.findOne.mockResolvedValue({
      id: 'record-1',
      userId: 'user-1',
      clockInAt: new Date('2026-08-01T04:00:00.000Z'),
      clockOutAt: null,
    });

    const record = await service.clockOut('user-1');

    expect(record.clockOutAt).not.toBeNull();
    expect(repositoryMock.save).toHaveBeenCalled();
  });

  it('rejects clocking out when there is no open record', async () => {
    repositoryMock.findOne.mockResolvedValue(null);

    await expect(service.clockOut('user-1')).rejects.toBeInstanceOf(BadRequestException);
  });
});
