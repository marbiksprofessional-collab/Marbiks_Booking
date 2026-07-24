import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Appointment, AppointmentStatus } from '../appointments/appointment.entity';
import { Invoice } from '../billing/invoice.entity';

export interface CommissionLine {
  appointmentId: string;
  serviceName: string;
  invoiceTotal: string;
  commissionPercent: string;
  commissionAmount: string;
}

export interface CommissionSummary {
  technicianId: string;
  from: string;
  to: string;
  totalCommission: string;
  lines: CommissionLine[];
}

@Injectable()
export class CommissionsService {
  constructor(
    @InjectRepository(Appointment)
    private readonly appointmentsRepository: Repository<Appointment>,
    @InjectRepository(Invoice)
    private readonly invoicesRepository: Repository<Invoice>,
  ) {}

  async getSummary(technicianId: string, from: string, to: string): Promise<CommissionSummary> {
    const fromDate = new Date(`${from}T00:00:00.000Z`);
    const toDate = new Date(`${to}T23:59:59.999Z`);

    const appointments = await this.appointmentsRepository.find({
      where: {
        technicianId,
        status: AppointmentStatus.COMPLETED,
      },
      relations: ['service'],
    });

    const relevant = appointments.filter(
      (appointment) => appointment.startTime >= fromDate && appointment.startTime <= toDate,
    );

    const lines: CommissionLine[] = [];
    let totalCommission = 0;

    for (const appointment of relevant) {
      const invoice = await this.invoicesRepository.findOne({
        where: { appointmentId: appointment.id },
      });
      if (!invoice) continue;

      const commissionPercent = Number(appointment.service.commissionPercent);
      const invoiceTotal = Number(invoice.total);
      const commissionAmount = round2((invoiceTotal * commissionPercent) / 100);
      totalCommission += commissionAmount;

      lines.push({
        appointmentId: appointment.id,
        serviceName: appointment.service.name,
        invoiceTotal: invoiceTotal.toFixed(2),
        commissionPercent: commissionPercent.toFixed(2),
        commissionAmount: commissionAmount.toFixed(2),
      });
    }

    return {
      technicianId,
      from,
      to,
      totalCommission: round2(totalCommission).toFixed(2),
      lines,
    };
  }
}

function round2(value: number): number {
  return Math.round(value * 100) / 100;
}
