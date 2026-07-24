import { Injectable } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';

export interface BranchRevenue {
  branchId: string;
  branchName: string;
  totalBilled: string;
  totalCollected: string;
  totalOutstanding: string;
  totalTax: string;
  invoiceCount: number;
}

export interface RevenueSummary {
  from: string;
  to: string;
  totalBilled: string;
  totalCollected: string;
  totalOutstanding: string;
  totalTax: string;
  /** Intra-state GST split of totalTax; halved for display only - no separate ledger. */
  cgst: string;
  sgst: string;
  branchCount: number;
  branches: BranchRevenue[];
}

export interface UnbilledAppointment {
  id: string;
  branchId: string;
  branchName: string;
  customerId: string;
  serviceName: string;
  startTime: Date;
}

export interface OverdueInvoice {
  id: string;
  invoiceNumber: string;
  branchId: string;
  branchName: string;
  total: string;
  createdAt: Date;
  daysOverdue: number;
}

export interface LeakageReport {
  generatedAt: string;
  unpaidDaysThreshold: number;
  unbilledCompleted: UnbilledAppointment[];
  overdueInvoices: OverdueInvoice[];
  overdueTotalAmount: string;
}

const DEFAULT_UNPAID_DAYS_THRESHOLD = 3;

@Injectable()
export class ReportsService {
  constructor(@InjectDataSource() private readonly dataSource: DataSource) {}

  async getRevenueSummary(from?: string, to?: string): Promise<RevenueSummary> {
    const fromDate = from ? new Date(`${from}T00:00:00.000Z`) : startOfMonth(new Date());
    const toDate = to ? new Date(`${to}T23:59:59.999Z`) : new Date();

    const rows = await this.dataSource.query(
      `SELECT b.id AS "branchId", b.name AS "branchName",
              COALESCE(SUM(i.total), 0)::numeric(12,2) AS "totalBilled",
              COALESCE(SUM(CASE WHEN i."paymentStatus" = 'PAID' THEN i.total ELSE 0 END), 0)::numeric(12,2) AS "totalCollected",
              COALESCE(SUM(CASE WHEN i."paymentStatus" != 'PAID' THEN i.total ELSE 0 END), 0)::numeric(12,2) AS "totalOutstanding",
              COALESCE(SUM(i."taxAmount"), 0)::numeric(12,2) AS "totalTax",
              COUNT(i.id)::int AS "invoiceCount"
       FROM branches b
       LEFT JOIN invoices i
         ON i."branchId" = b.id AND i."createdAt" BETWEEN $1 AND $2
       GROUP BY b.id, b.name
       ORDER BY b.name ASC`,
      [fromDate, toDate],
    );

    const branches: BranchRevenue[] = rows.map((row: any) => ({
      branchId: row.branchId,
      branchName: row.branchName,
      totalBilled: row.totalBilled,
      totalCollected: row.totalCollected,
      totalOutstanding: row.totalOutstanding,
      totalTax: row.totalTax,
      invoiceCount: row.invoiceCount,
    }));

    const totalBilled = sumField(branches, 'totalBilled');
    const totalCollected = sumField(branches, 'totalCollected');
    const totalOutstanding = sumField(branches, 'totalOutstanding');
    const totalTax = sumField(branches, 'totalTax');

    return {
      from: fromDate.toISOString(),
      to: toDate.toISOString(),
      totalBilled: totalBilled.toFixed(2),
      totalCollected: totalCollected.toFixed(2),
      totalOutstanding: totalOutstanding.toFixed(2),
      totalTax: totalTax.toFixed(2),
      cgst: (totalTax / 2).toFixed(2),
      sgst: (totalTax / 2).toFixed(2),
      branchCount: branches.length,
      branches,
    };
  }

  async getLeakageReport(unpaidDays?: number): Promise<LeakageReport> {
    const threshold = unpaidDays ?? DEFAULT_UNPAID_DAYS_THRESHOLD;

    const unbilledRows = await this.dataSource.query(
      `SELECT a.id, a."branchId", b.name AS "branchName", a."customerId",
              s.name AS "serviceName", a."startTime"
       FROM appointments a
       LEFT JOIN invoices i ON i."appointmentId" = a.id
       JOIN branches b ON b.id = a."branchId"
       JOIN service_items s ON s.id = a."serviceId"
       WHERE a.status = 'COMPLETED' AND i.id IS NULL
       ORDER BY a."startTime" DESC`,
    );

    const overdueRows = await this.dataSource.query(
      `SELECT i.id, i."invoiceNumber", i."branchId", b.name AS "branchName",
              i.total, i."createdAt",
              EXTRACT(DAY FROM (now() - i."createdAt"))::int AS "daysOverdue"
       FROM invoices i
       JOIN branches b ON b.id = i."branchId"
       WHERE i."paymentStatus" IN ('UNPAID', 'PARTIAL')
         AND i."createdAt" < now() - ($1 || ' days')::interval
       ORDER BY i."createdAt" ASC`,
      [threshold],
    );

    const overdueTotalAmount = overdueRows.reduce(
      (sum: number, row: any) => sum + Number(row.total),
      0,
    );

    return {
      generatedAt: new Date().toISOString(),
      unpaidDaysThreshold: threshold,
      unbilledCompleted: unbilledRows,
      overdueInvoices: overdueRows,
      overdueTotalAmount: overdueTotalAmount.toFixed(2),
    };
  }
}

function sumField(rows: BranchRevenue[], field: keyof BranchRevenue): number {
  return rows.reduce((sum, row) => sum + Number(row[field]), 0);
}

function startOfMonth(date: Date): Date {
  return new Date(Date.UTC(date.getUTCFullYear(), date.getUTCMonth(), 1));
}
