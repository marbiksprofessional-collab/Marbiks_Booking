import { ConflictException } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { AppointmentsService } from './appointments.service';
import { Appointment, AppointmentStatus } from './appointment.entity';
import { ServicesService } from '../services/services.service';

describe('AppointmentsService', () => {
  let service: AppointmentsService;
  let queryBuilderMock: any;
  let repositoryMock: any;
  let servicesServiceMock: { findById: jest.Mock };

  const SERVICE = { id: 'service-1', durationMinutes: 30, price: '1000.00' };

  beforeEach(async () => {
    queryBuilderMock = {
      where: jest.fn().mockReturnThis(),
      andWhere: jest.fn().mockReturnThis(),
      orderBy: jest.fn().mockReturnThis(),
      getOne: jest.fn(),
      getMany: jest.fn(),
    };

    repositoryMock = {
      create: jest.fn((data) => data),
      save: jest.fn((data) => ({ id: 'appt-1', ...data })),
      findOne: jest.fn(),
      createQueryBuilder: jest.fn(() => queryBuilderMock),
    };

    servicesServiceMock = { findById: jest.fn().mockResolvedValue(SERVICE) };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AppointmentsService,
        { provide: getRepositoryToken(Appointment), useValue: repositoryMock },
        { provide: ServicesService, useValue: servicesServiceMock },
      ],
    }).compile();

    service = module.get(AppointmentsService);
  });

  it('creates an appointment when no conflict exists', async () => {
    queryBuilderMock.getOne.mockResolvedValue(null);

    const result = await service.create({
      branchId: 'branch-1',
      customerId: 'customer-1',
      serviceId: SERVICE.id,
      resourceId: 'chair-1',
      startTime: '2026-08-01T05:00:00.000Z',
    });

    expect(result.status).toBe(AppointmentStatus.CONFIRMED);
    expect(repositoryMock.save).toHaveBeenCalled();
  });

  it('rejects a booking that overlaps an existing one on the same resource', async () => {
    queryBuilderMock.getOne.mockResolvedValue({ id: 'existing-appt' });

    await expect(
      service.create({
        branchId: 'branch-1',
        customerId: 'customer-1',
        serviceId: SERVICE.id,
        resourceId: 'chair-1',
        startTime: '2026-08-01T05:00:00.000Z',
      }),
    ).rejects.toBeInstanceOf(ConflictException);

    expect(repositoryMock.save).not.toHaveBeenCalled();
  });

  it('skips conflict checking entirely when neither technician nor resource is specified', async () => {
    const result = await service.create({
      branchId: 'branch-1',
      customerId: 'customer-1',
      serviceId: SERVICE.id,
      startTime: '2026-08-01T05:00:00.000Z',
    });

    expect(queryBuilderMock.getOne).not.toHaveBeenCalled();
    expect(result.status).toBe(AppointmentStatus.CONFIRMED);
  });

  it('excludes the appointment being rescheduled from its own conflict check', async () => {
    repositoryMock.findOne.mockResolvedValue({
      id: 'appt-1',
      serviceId: SERVICE.id,
      technicianId: null,
      resourceId: 'chair-1',
    });
    queryBuilderMock.getOne.mockResolvedValue(null);

    await service.reschedule('appt-1', { startTime: '2026-08-01T06:00:00.000Z' });

    expect(queryBuilderMock.andWhere).toHaveBeenCalledWith(
      'a.id != :excludeAppointmentId',
      { excludeAppointmentId: 'appt-1' },
    );
  });
});
