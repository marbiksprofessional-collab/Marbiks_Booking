import { IsDateString } from 'class-validator';

export class RescheduleOwnAppointmentDto {
  @IsDateString()
  startTime: string;
}
