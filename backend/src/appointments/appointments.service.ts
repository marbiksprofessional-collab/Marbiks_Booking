import { ConflictException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Brackets, Repository } from 'typeorm';
import { Appointment, AppointmentStatus } from './appointment.entity';
import { CreateAppointmentDto } from './dto/create-appointment.dto';
import { RescheduleAppointmentDto } from './dto/reschedule-appointment.dto';
import { ServicesService } from '../services/services.service';

const ACTIVE_STATUSES_BLOCKING_CONFLICT = [
  AppointmentStatus.PENDING,
  AppointmentStatus.CONFIRMED,
  AppointmentStatus.IN_PROGRESS,
  AppointmentStatus.COMPLETED,
];

interface ConflictCheckParams {
  technicianId?: string | null;
  resourceId?: string | null;
  startTime: Date;
  endTime: Date;
  excludeAppointmentId?: string;
}

@Injectable()
export class AppointmentsService {
  constructor(
    @InjectRepository(Appointment)
    private readonly appointmentsRepository: Repository<Appointment>,
    private readonly servicesService: ServicesService,
  ) {}

  private async assertNoConflict(params: ConflictCheckParams): Promise<void> {
    const { technicianId, resourceId, startTime, endTime, excludeAppointmentId } = params;
    if (!technicianId && !resourceId) {
      return;
    }

    const qb = this.appointmentsRepository
      .createQueryBuilder('a')
      .where('a.status IN (:...statuses)', { statuses: ACTIVE_STATUSES_BLOCKING_CONFLICT })
      .andWhere('a.startTime < :endTime', { endTime })
      .andWhere('a.endTime > :startTime', { startTime })
      .andWhere(
        new Brackets((qb2) => {
          if (technicianId) {
            qb2.orWhere('a.technicianId = :technicianId', { technicianId });
          }
          if (resourceId) {
            qb2.orWhere('a.resourceId = :resourceId', { resourceId });
          }
        }),
      );

    if (excludeAppointmentId) {
      qb.andWhere('a.id != :excludeAppointmentId', { excludeAppointmentId });
    }

    const conflict = await qb.getOne();
    if (conflict) {
      throw new ConflictException(
        'The selected technician or resource is already booked for an overlapping time slot',
      );
    }
  }

  async create(dto: CreateAppointmentDto): Promise<Appointment> {
    const service = await this.servicesService.findById(dto.serviceId);
    const startTime = new Date(dto.startTime);
    const endTime = new Date(startTime.getTime() + service.durationMinutes * 60_000);

    await this.assertNoConflict({
      technicianId: dto.technicianId,
      resourceId: dto.resourceId,
      startTime,
      endTime,
    });

    const appointment = this.appointmentsRepository.create({
      branchId: dto.branchId,
      customerId: dto.customerId,
      technicianId: dto.technicianId ?? null,
      resourceId: dto.resourceId ?? null,
      serviceId: dto.serviceId,
      startTime,
      endTime,
      notes: dto.notes,
      status: AppointmentStatus.CONFIRMED,
    });

    return this.appointmentsRepository.save(appointment);
  }

  async reschedule(id: string, dto: RescheduleAppointmentDto): Promise<Appointment> {
    const appointment = await this.findById(id);
    const service = await this.servicesService.findById(appointment.serviceId);
    const startTime = new Date(dto.startTime);
    const endTime = new Date(startTime.getTime() + service.durationMinutes * 60_000);
    const technicianId = dto.technicianId ?? appointment.technicianId;
    const resourceId = dto.resourceId ?? appointment.resourceId;

    await this.assertNoConflict({
      technicianId,
      resourceId,
      startTime,
      endTime,
      excludeAppointmentId: id,
    });

    appointment.startTime = startTime;
    appointment.endTime = endTime;
    appointment.technicianId = technicianId;
    appointment.resourceId = resourceId;
    appointment.status = AppointmentStatus.CONFIRMED;

    return this.appointmentsRepository.save(appointment);
  }

  async cancel(id: string): Promise<Appointment> {
    const appointment = await this.findById(id);
    appointment.status = AppointmentStatus.CANCELLED;
    return this.appointmentsRepository.save(appointment);
  }

  async markNoShow(id: string): Promise<Appointment> {
    const appointment = await this.findById(id);
    appointment.status = AppointmentStatus.NO_SHOW;
    return this.appointmentsRepository.save(appointment);
  }

  async complete(id: string): Promise<Appointment> {
    const appointment = await this.findById(id);
    appointment.status = AppointmentStatus.COMPLETED;
    return this.appointmentsRepository.save(appointment);
  }

  async findById(id: string): Promise<Appointment> {
    const appointment = await this.appointmentsRepository.findOne({ where: { id } });
    if (!appointment) {
      throw new NotFoundException(`Appointment ${id} not found`);
    }
    return appointment;
  }

  async findForBranchAndDate(branchId: string, date: string): Promise<Appointment[]> {
    const dayStart = new Date(`${date}T00:00:00.000Z`);
    const dayEnd = new Date(`${date}T23:59:59.999Z`);
    return this.appointmentsRepository
      .createQueryBuilder('a')
      .where('a.branchId = :branchId', { branchId })
      .andWhere('a.startTime BETWEEN :dayStart AND :dayEnd', { dayStart, dayEnd })
      .orderBy('a.startTime', 'ASC')
      .getMany();
  }

  async findForTechnicianAndDate(technicianId: string, date: string): Promise<Appointment[]> {
    const dayStart = new Date(`${date}T00:00:00.000Z`);
    const dayEnd = new Date(`${date}T23:59:59.999Z`);
    return this.appointmentsRepository
      .createQueryBuilder('a')
      .where('a.technicianId = :technicianId', { technicianId })
      .andWhere('a.startTime BETWEEN :dayStart AND :dayEnd', { dayStart, dayEnd })
      .orderBy('a.startTime', 'ASC')
      .getMany();
  }

  async findHistoryForCustomer(customerId: string): Promise<Appointment[]> {
    return this.appointmentsRepository.find({
      where: { customerId },
      order: { startTime: 'DESC' },
    });
  }
}
