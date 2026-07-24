import { IsDateString, IsInt, IsNumberString, IsOptional, IsString, Min } from 'class-validator';

export class ReceiveStockDto {
  @IsString()
  branchId: string;

  @IsString()
  productId: string;

  @IsInt()
  @Min(1)
  quantity: number;

  @IsOptional()
  @IsNumberString()
  unitCost?: string;

  @IsOptional()
  @IsString()
  batchNumber?: string;

  @IsOptional()
  @IsDateString()
  expiryDate?: string;

  @IsOptional()
  @IsString()
  vendorId?: string;
}
