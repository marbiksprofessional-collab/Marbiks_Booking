import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Invoice, PaymentMethod, PaymentStatus } from './invoice.entity';
import { InvoiceItem } from './invoice-item.entity';
import { CreateInvoiceDto } from './dto/create-invoice.dto';
import { AppointmentsService } from '../appointments/appointments.service';
import { ServicesService } from '../services/services.service';

const DEFAULT_TAX_RATE_PERCENT = 18;

@Injectable()
export class BillingService {
  constructor(
    @InjectRepository(Invoice)
    private readonly invoicesRepository: Repository<Invoice>,
    private readonly appointmentsService: AppointmentsService,
    private readonly servicesService: ServicesService,
  ) {}

  async create(dto: CreateInvoiceDto): Promise<Invoice> {
    const items: InvoiceItem[] = [];

    if (dto.items && dto.items.length > 0) {
      for (const item of dto.items) {
        const unitPrice = Number(item.unitPrice);
        const total = round2(unitPrice * item.quantity);
        items.push(
          this.buildItem(item.description, item.quantity, unitPrice, total),
        );
      }
    } else if (dto.appointmentId) {
      const appointment = await this.appointmentsService.findById(dto.appointmentId);
      const service = await this.servicesService.findById(appointment.serviceId);
      const unitPrice = Number(service.price);
      items.push(this.buildItem(service.name, 1, unitPrice, round2(unitPrice)));
    } else {
      throw new BadRequestException(
        'An invoice requires either explicit items or an appointmentId to bill from',
      );
    }

    const subtotal = round2(items.reduce((sum, item) => sum + Number(item.total), 0));
    const discountAmount = round2(dto.discountAmount ?? 0);
    const taxRate = dto.taxRatePercent ?? DEFAULT_TAX_RATE_PERCENT;
    const taxableAmount = Math.max(subtotal - discountAmount, 0);
    const taxAmount = round2((taxableAmount * taxRate) / 100);
    const total = round2(taxableAmount + taxAmount);

    const invoice = this.invoicesRepository.create({
      invoiceNumber: generateInvoiceNumber(),
      branchId: dto.branchId,
      customerId: dto.customerId,
      appointmentId: dto.appointmentId ?? null,
      items,
      subtotal: subtotal.toFixed(2),
      discountAmount: discountAmount.toFixed(2),
      taxAmount: taxAmount.toFixed(2),
      total: total.toFixed(2),
      paymentStatus: PaymentStatus.UNPAID,
    });

    return this.invoicesRepository.save(invoice);
  }

  private buildItem(
    description: string,
    quantity: number,
    unitPrice: number,
    total: number,
  ): InvoiceItem {
    const item = new InvoiceItem();
    item.description = description;
    item.quantity = quantity;
    item.unitPrice = unitPrice.toFixed(2);
    item.total = total.toFixed(2);
    return item;
  }

  async findById(id: string): Promise<Invoice> {
    const invoice = await this.invoicesRepository.findOne({ where: { id } });
    if (!invoice) {
      throw new NotFoundException(`Invoice ${id} not found`);
    }
    return invoice;
  }

  async findForBranch(branchId: string): Promise<Invoice[]> {
    return this.invoicesRepository.find({
      where: { branchId },
      order: { createdAt: 'DESC' },
    });
  }

  async markPaid(id: string, paymentMethod: PaymentMethod): Promise<Invoice> {
    const invoice = await this.findById(id);
    invoice.paymentStatus = PaymentStatus.PAID;
    invoice.paymentMethod = paymentMethod;
    return this.invoicesRepository.save(invoice);
  }
}

function round2(value: number): number {
  return Math.round(value * 100) / 100;
}

function generateInvoiceNumber(): string {
  const now = new Date();
  const datePart = now.toISOString().slice(0, 10).replace(/-/g, '');
  const randomPart = Math.floor(Math.random() * 1_000_000)
    .toString()
    .padStart(6, '0');
  return `INV-${datePart}-${randomPart}`;
}
