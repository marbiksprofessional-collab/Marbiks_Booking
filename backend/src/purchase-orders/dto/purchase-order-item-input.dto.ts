import { IsInt, IsNumberString, IsString, Min } from 'class-validator';

export class PurchaseOrderItemInputDto {
  @IsString()
  productId: string;

  @IsInt()
  @Min(1)
  quantity: number;

  @IsNumberString()
  unitCost: string;
}
