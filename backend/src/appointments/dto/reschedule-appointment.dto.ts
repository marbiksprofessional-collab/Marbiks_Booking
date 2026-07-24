import { IsDateString, IsOptional, IsString } from 'class-validator';

export class RescheduleAppointmentDto {
  @IsDateString()
  startTime: string;

  @IsOptional()
  @IsString()
  technicianId?: string;

  @IsOptional()
  @IsString()
  resourceId?: string;
}
