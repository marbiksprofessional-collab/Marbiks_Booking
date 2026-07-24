import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { BillingService } from './billing.service';
import { Invoice, PaymentStatus } from './invoice.entity';
import { AppointmentsService } from '../appointments/appointments.service';
import { ServicesService } from '../services/services.service';

describe('BillingService', () => {
  let service: BillingService;
  let repositoryMock: any;
  let appointmentsServiceMock: { findById: jest.Mock };
  let servicesServiceMock: { findById: jest.Mock };

  beforeEach(async () => {
    repositoryMock = {
      create: jest.fn((data) => data),
      save: jest.fn((data) => ({ id: 'invoice-1', ...data })),
      findOne: jest.fn(),
    };
    appointmentsServiceMock = { findById: jest.fn() };
    servicesServiceMock = { findById: jest.fn() };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        BillingService,
        { provide: getRepositoryToken(Invoice), useValue: repositoryMock },
        { provide: AppointmentsService, useValue: appointmentsServiceMock },
        { provide: ServicesService, useValue: servicesServiceMock },
      ],
    }).compile();

    service = module.get(BillingService);
  });

  it('computes totals with the default 18% tax rate from explicit line items', async () => {
    const invoice = await service.create({
      branchId: 'branch-1',
      customerId: 'customer-1',
      items: [{ description: 'Hair Spa', quantity: 2, unitPrice: '500.00' }],
    });

    expect(invoice.subtotal).toBe('1000.00');
    expect(invoice.taxAmount).toBe('180.00');
    expect(invoice.total).toBe('1180.00');
    expect(invoice.paymentStatus).toBe(PaymentStatus.UNPAID);
  });

  it('applies a discount before computing tax', async () => {
    const invoice = await service.create({
      branchId: 'branch-1',
      customerId: 'customer-1',
      items: [{ description: 'Facial', quantity: 1, unitPrice: '1000.00' }],
      discountAmount: 100,
    });

    // taxable = 1000 - 100 = 900; tax = 162; total = 1062
    expect(invoice.subtotal).toBe('1000.00');
    expect(invoice.discountAmount).toBe('100.00');
    expect(invoice.taxAmount).toBe('162.00');
    expect(invoice.total).toBe('1062.00');
  });

  it('builds a line item from the linked appointment service when no items are given', async () => {
    appointmentsServiceMock.findById.mockResolvedValue({ id: 'appt-1', serviceId: 'service-1' });
    servicesServiceMock.findById.mockResolvedValue({ name: 'Manicure', price: '600.00' });

    const invoice = await service.create({
      branchId: 'branch-1',
      customerId: 'customer-1',
      appointmentId: 'appt-1',
    });

    expect(invoice.items[0].description).toBe('Manicure');
    expect(invoice.subtotal).toBe('600.00');
  });

  it('rejects an invoice with neither items nor an appointmentId', async () => {
    await expect(
      service.create({ branchId: 'branch-1', customerId: 'customer-1' }),
    ).rejects.toThrow();
  });
});
