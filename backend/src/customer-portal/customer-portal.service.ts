import { ForbiddenException, Injectable } from '@nestjs/common';
import { AppointmentsService } from '../appointments/appointments.service';
import { BillingService } from '../billing/billing.service';
import { CustomersService } from '../customers/customers.service';
import { Appointment } from '../appointments/appointment.entity';
import { Invoice } from '../billing/invoice.entity';
import { Customer } from '../customers/customer.entity';
import { BookOwnAppointmentDto } from './dto/book-own-appointment.dto';
import { RescheduleOwnAppointmentDto } from './dto/reschedule-own-appointment.dto';

@Injectable()
export class CustomerPortalService {
  constructor(
    private readonly appointmentsService: AppointmentsService,
    private readonly billingService: BillingService,
    private readonly customersService: CustomersService,
  ) {}

  getProfile(customerId: string): Promise<Customer> {
    return this.customersService.findById(customerId);
  }

  getMyAppointments(customerId: string): Promise<Appointment[]> {
    return this.appointmentsService.findHistoryForCustomer(customerId);
  }

  bookAppointment(customerId: string, dto: BookOwnAppointmentDto): Promise<Appointment> {
    return this.appointmentsService.create({ ...dto, customerId });
  }

  private async assertOwnsAppointment(customerId: string, appointmentId: string): Promise<Appointment> {
    const appointment = await this.appointmentsService.findById(appointmentId);
    if (appointment.customerId !== customerId) {
      throw new ForbiddenException('This appointment does not belong to you');
    }
    return appointment;
  }

  async rescheduleOwnAppointment(
    customerId: string,
    appointmentId: string,
    dto: RescheduleOwnAppointmentDto,
  ): Promise<Appointment> {
    await this.assertOwnsAppointment(customerId, appointmentId);
    return this.appointmentsService.reschedule(appointmentId, { startTime: dto.startTime });
  }

  async cancelOwnAppointment(customerId: string, appointmentId: string): Promise<Appointment> {
    await this.assertOwnsAppointment(customerId, appointmentId);
    return this.appointmentsService.cancel(appointmentId);
  }

  getMyInvoices(customerId: string): Promise<Invoice[]> {
    return this.billingService.findForCustomer(customerId);
  }

  async getMyInvoice(customerId: string, invoiceId: string): Promise<Invoice> {
    const invoice = await this.billingService.findById(invoiceId);
    if (invoice.customerId !== customerId) {
      throw new ForbiddenException('This invoice does not belong to you');
    }
    return invoice;
  }
}
