import { IsString } from 'class-validator';

export class ClockInDto {
  @IsString()
  branchId: string;
}
