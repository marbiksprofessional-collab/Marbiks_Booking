import { IsDateString, IsOptional, IsString } from 'class-validator';

export class BookOwnAppointmentDto {
  @IsString()
  branchId: string;

  @IsOptional()
  @IsString()
  technicianId?: string;

  @IsOptional()
  @IsString()
  resourceId?: string;

  @IsString()
  serviceId: string;

  @IsDateString()
  startTime: string;

  @IsOptional()
  @IsString()
  notes?: string;
}
