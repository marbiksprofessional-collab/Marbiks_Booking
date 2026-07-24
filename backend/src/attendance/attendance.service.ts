import { BadRequestException, ConflictException, Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { IsNull, Repository } from 'typeorm';
import { AttendanceRecord } from './attendance.entity';

@Injectable()
export class AttendanceService {
  constructor(
    @InjectRepository(AttendanceRecord)
    private readonly attendanceRepository: Repository<AttendanceRecord>,
  ) {}

  private findOpenRecord(userId: string): Promise<AttendanceRecord | null> {
    return this.attendanceRepository.findOne({
      where: { userId, clockOutAt: IsNull() },
      order: { clockInAt: 'DESC' },
    });
  }

  async clockIn(userId: string, branchId: string): Promise<AttendanceRecord> {
    const openRecord = await this.findOpenRecord(userId);
    if (openRecord) {
      throw new ConflictException('You are already clocked in - clock out first');
    }
    const record = this.attendanceRepository.create({
      userId,
      branchId,
      clockInAt: new Date(),
      clockOutAt: null,
    });
    return this.attendanceRepository.save(record);
  }

  async clockOut(userId: string): Promise<AttendanceRecord> {
    const openRecord = await this.findOpenRecord(userId);
    if (!openRecord) {
      throw new BadRequestException('You are not currently clocked in');
    }
    openRecord.clockOutAt = new Date();
    return this.attendanceRepository.save(openRecord);
  }

  async getCurrentStatus(userId: string): Promise<AttendanceRecord | null> {
    return this.findOpenRecord(userId);
  }

  async getForUserAndDate(userId: string, date: string): Promise<AttendanceRecord[]> {
    const dayStart = new Date(`${date}T00:00:00.000Z`);
    const dayEnd = new Date(`${date}T23:59:59.999Z`);
    return this.attendanceRepository
      .createQueryBuilder('a')
      .where('a.userId = :userId', { userId })
      .andWhere('a.clockInAt BETWEEN :dayStart AND :dayEnd', { dayStart, dayEnd })
      .orderBy('a.clockInAt', 'ASC')
      .getMany();
  }
}
