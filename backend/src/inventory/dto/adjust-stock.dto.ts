import { IsInt, IsString, NotEquals } from 'class-validator';

export class AdjustStockDto {
  @IsString()
  branchId: string;

  @IsString()
  productId: string;

  @IsInt()
  @NotEquals(0)
  quantityDelta: number;

  @IsString()
  reason: string;
}
