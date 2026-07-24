import { Type } from 'class-transformer';
import { IsInt, IsOptional, Min } from 'class-validator';

export class LeakageQueryDto {
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  unpaidDays?: number;
}
