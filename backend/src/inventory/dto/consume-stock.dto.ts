import { IsInt, IsOptional, IsString, Min } from 'class-validator';

export class ConsumeStockDto {
  @IsString()
  branchId: string;

  @IsString()
  productId: string;

  @IsInt()
  @Min(1)
  quantity: number;

  @IsOptional()
  @IsString()
  note?: string;
}
