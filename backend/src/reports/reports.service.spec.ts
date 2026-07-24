import { Test, TestingModule } from '@nestjs/testing';
import { getDataSourceToken } from '@nestjs/typeorm';
import { ReportsService } from './reports.service';

describe('ReportsService', () => {
  let service: ReportsService;
  let dataSourceMock: { query: jest.Mock };

  beforeEach(async () => {
    dataSourceMock = { query: jest.fn() };

    const module: TestingModule = await Test.createTestingModule({
      providers: [ReportsService, { provide: getDataSourceToken(), useValue: dataSourceMock }],
    }).compile();

    service = module.get(ReportsService);
  });

  it('aggregates real per-branch rows into grand totals and an honest 50/50 CGST/SGST split', async () => {
    dataSourceMock.query.mockResolvedValue([
      {
        branchId: 'branch-1',
        branchName: 'Flagship',
        totalBilled: '1770.00',
        totalCollected: '1770.00',
        totalOutstanding: '0.00',
        totalTax: '270.00',
        invoiceCount: 1,
      },
      {
        branchId: 'branch-2',
        branchName: 'Indiranagar',
        totalBilled: '1180.00',
        totalCollected: '0.00',
        totalOutstanding: '1180.00',
        totalTax: '180.00',
        invoiceCount: 1,
      },
    ]);

    const summary = await service.getRevenueSummary('2026-08-01', '2026-08-31');

    expect(summary.branchCount).toBe(2);
    expect(summary.totalBilled).toBe('2950.00');
    expect(summary.totalCollected).toBe('1770.00');
    expect(summary.totalOutstanding).toBe('1180.00');
    expect(summary.totalTax).toBe('450.00');
    expect(summary.cgst).toBe('225.00');
    expect(summary.sgst).toBe('225.00');
  });

  it('returns zeroed totals with no branches when there is no data', async () => {
    dataSourceMock.query.mockResolvedValue([]);

    const summary = await service.getRevenueSummary();

    expect(summary.branchCount).toBe(0);
    expect(summary.totalBilled).toBe('0.00');
    expect(summary.cgst).toBe('0.00');
  });

  it('sums the overdue invoice total from real leakage rows', async () => {
    dataSourceMock.query
      .mockResolvedValueOnce([{ id: 'appt-1', branchId: 'branch-1', branchName: 'Flagship', customerId: 'c1', serviceName: 'Facial', startTime: new Date() }])
      .mockResolvedValueOnce([
        { id: 'inv-1', invoiceNumber: 'INV-1', branchId: 'branch-1', branchName: 'Flagship', total: '1000.00', createdAt: new Date(), daysOverdue: 5 },
        { id: 'inv-2', invoiceNumber: 'INV-2', branchId: 'branch-2', branchName: 'Indiranagar', total: '500.50', createdAt: new Date(), daysOverdue: 4 },
      ]);

    const report = await service.getLeakageReport(3);

    expect(report.unpaidDaysThreshold).toBe(3);
    expect(report.unbilledCompleted).toHaveLength(1);
    expect(report.overdueInvoices).toHaveLength(2);
    expect(report.overdueTotalAmount).toBe('1500.50');
  });

  it('defaults the unpaid-days threshold to 3 when none is given', async () => {
    dataSourceMock.query.mockResolvedValue([]);

    const report = await service.getLeakageReport();

    expect(report.unpaidDaysThreshold).toBe(3);
  });
});
