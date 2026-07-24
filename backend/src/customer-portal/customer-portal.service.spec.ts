import { ForbiddenException } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import { CustomerPortalService } from './customer-portal.service';
import { AppointmentsService } from '../appointments/appointments.service';
import { BillingService } from '../billing/billing.service';
import { CustomersService } from '../customers/customers.service';

describe('CustomerPortalService', () => {
  let service: CustomerPortalService;
  let appointmentsServiceMock: any;
  let billingServiceMock: any;
  let customersServiceMock: any;

  beforeEach(async () => {
    appointmentsServiceMock = {
      findById: jest.fn(),
      create: jest.fn(),
      reschedule: jest.fn(),
      cancel: jest.fn(),
      findHistoryForCustomer: jest.fn(),
    };
    billingServiceMock = { findForCustomer: jest.fn(), findById: jest.fn() };
    customersServiceMock = { findById: jest.fn() };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        CustomerPortalService,
        { provide: AppointmentsService, useValue: appointmentsServiceMock },
        { provide: BillingService, useValue: billingServiceMock },
        { provide: CustomersService, useValue: customersServiceMock },
      ],
    }).compile();

    service = module.get(CustomerPortalService);
  });

  it('lets a customer reschedule their own appointment', async () => {
    appointmentsServiceMock.findById.mockResolvedValue({ id: 'appt-1', customerId: 'customer-1' });

    await service.rescheduleOwnAppointment('customer-1', 'appt-1', { startTime: '2026-08-01T05:00:00.000Z' });

    expect(appointmentsServiceMock.reschedule).toHaveBeenCalledWith('appt-1', {
      startTime: '2026-08-01T05:00:00.000Z',
    });
  });

  it("rejects rescheduling another customer's appointment", async () => {
    appointmentsServiceMock.findById.mockResolvedValue({ id: 'appt-1', customerId: 'someone-else' });

    await expect(
      service.rescheduleOwnAppointment('customer-1', 'appt-1', { startTime: '2026-08-01T05:00:00.000Z' }),
    ).rejects.toBeInstanceOf(ForbiddenException);
    expect(appointmentsServiceMock.reschedule).not.toHaveBeenCalled();
  });

  it("rejects cancelling another customer's appointment", async () => {
    appointmentsServiceMock.findById.mockResolvedValue({ id: 'appt-1', customerId: 'someone-else' });

    await expect(service.cancelOwnAppointment('customer-1', 'appt-1')).rejects.toBeInstanceOf(
      ForbiddenException,
    );
    expect(appointmentsServiceMock.cancel).not.toHaveBeenCalled();
  });

  it("rejects viewing another customer's invoice", async () => {
    billingServiceMock.findById.mockResolvedValue({ id: 'invoice-1', customerId: 'someone-else' });

    await expect(service.getMyInvoice('customer-1', 'invoice-1')).rejects.toBeInstanceOf(
      ForbiddenException,
    );
  });

  it('forces the authenticated customer as the booking customerId', async () => {
    appointmentsServiceMock.create.mockResolvedValue({ id: 'appt-1' });

    await service.bookAppointment('customer-1', {
      branchId: 'branch-1',
      serviceId: 'service-1',
      startTime: '2026-08-01T05:00:00.000Z',
    });

    expect(appointmentsServiceMock.create).toHaveBeenCalledWith(
      expect.objectContaining({ customerId: 'customer-1' }),
    );
  });
});
