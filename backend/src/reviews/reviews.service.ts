import { BadRequestException, ConflictException, ForbiddenException, Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Review } from './review.entity';
import { CreateReviewDto } from './dto/create-review.dto';
import { AppointmentsService } from '../appointments/appointments.service';
import { AppointmentStatus } from '../appointments/appointment.entity';

@Injectable()
export class ReviewsService {
  constructor(
    @InjectRepository(Review)
    private readonly reviewsRepository: Repository<Review>,
    private readonly appointmentsService: AppointmentsService,
  ) {}

  async create(dto: CreateReviewDto, customerId: string): Promise<Review> {
    const appointment = await this.appointmentsService.findById(dto.appointmentId);

    if (appointment.customerId !== customerId) {
      throw new ForbiddenException('This appointment does not belong to you');
    }
    if (appointment.status !== AppointmentStatus.COMPLETED) {
      throw new BadRequestException('You can only review a completed appointment');
    }

    const existing = await this.reviewsRepository.findOne({
      where: { appointmentId: dto.appointmentId },
    });
    if (existing) {
      throw new ConflictException('This appointment has already been reviewed');
    }

    const review = this.reviewsRepository.create({
      customerId,
      appointmentId: dto.appointmentId,
      branchId: appointment.branchId,
      technicianId: appointment.technicianId,
      rating: dto.rating,
      comment: dto.comment ?? null,
    });

    return this.reviewsRepository.save(review);
  }

  async findForBranch(branchId: string): Promise<Review[]> {
    return this.reviewsRepository.find({ where: { branchId }, order: { createdAt: 'DESC' } });
  }

  async findForTechnician(technicianId: string): Promise<Review[]> {
    return this.reviewsRepository.find({ where: { technicianId }, order: { createdAt: 'DESC' } });
  }
}
