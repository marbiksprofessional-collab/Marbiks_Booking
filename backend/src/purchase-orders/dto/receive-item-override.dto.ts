import { IsDateString, IsOptional, IsString } from 'class-validator';

export class ReceiveItemOverrideDto {
  @IsString()
  productId: string;

  @IsOptional()
  @IsString()
  batchNumber?: string;

  @IsOptional()
  @IsDateString()
  expiryDate?: string;
}
