import { IsInt, IsString, Min } from 'class-validator';

export class TransferStockDto {
  @IsString()
  fromBranchId: string;

  @IsString()
  toBranchId: string;

  @IsString()
  productId: string;

  @IsInt()
  @Min(1)
  quantity: number;
}
