import { IsInt, IsNumberString, IsOptional, IsString, Min } from 'class-validator';

export class CreateServiceItemDto {
  @IsString()
  name: string;

  @IsOptional()
  @IsString()
  category?: string;

  @IsInt()
  @Min(1)
  durationMinutes: number;

  @IsNumberString()
  price: string;
}
