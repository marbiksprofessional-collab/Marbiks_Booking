import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { CommissionsService } from './commissions.service';
import { Appointment, AppointmentStatus } from '../appointments/appointment.entity';
import { Invoice } from '../billing/invoice.entity';

describe('CommissionsService', () => {
  let service: CommissionsService;
  let appointmentsRepositoryMock: any;
  let invoicesRepositoryMock: any;

  beforeEach(async () => {
    appointmentsRepositoryMock = { find: jest.fn() };
    invoicesRepositoryMock = { findOne: jest.fn() };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        CommissionsService,
        { provide: getRepositoryToken(Appointment), useValue: appointmentsRepositoryMock },
        { provide: getRepositoryToken(Invoice), useValue: invoicesRepositoryMock },
      ],
    }).compile();

    service = module.get(CommissionsService);
  });

  it('computes commission for completed appointments with invoices in range', async () => {
    appointmentsRepositoryMock.find.mockResolvedValue([
      {
        id: 'appt-1',
        status: AppointmentStatus.COMPLETED,
        startTime: new Date('2026-08-01T05:00:00.000Z'),
        service: { name: 'Classic Facial', commissionPercent: '10.00' },
      },
      {
        // outside the requested range - should be excluded
        id: 'appt-2',
        status: AppointmentStatus.COMPLETED,
        startTime: new Date('2026-09-15T05:00:00.000Z'),
        service: { name: 'Haircut', commissionPercent: '10.00' },
      },
    ]);
    invoicesRepositoryMock.findOne.mockImplementation(({ where }: any) =>
      where.appointmentId === 'appt-1' ? Promise.resolve({ total: '1770.00' }) : Promise.resolve(null),
    );

    const summary = await service.getSummary('tech-1', '2026-08-01', '2026-08-01');

    expect(summary.lines).toHaveLength(1);
    expect(summary.lines[0].commissionAmount).toBe('177.00');
    expect(summary.totalCommission).toBe('177.00');
  });

  it('returns zero commission when there are no matching completed appointments', async () => {
    appointmentsRepositoryMock.find.mockResolvedValue([]);

    const summary = await service.getSummary('tech-1', '2026-08-01', '2026-08-01');

    expect(summary.lines).toHaveLength(0);
    expect(summary.totalCommission).toBe('0.00');
  });
});
