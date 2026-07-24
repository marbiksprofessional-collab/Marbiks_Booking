import { IsInt, IsNumberString, IsString, Min } from 'class-validator';

export class InvoiceItemInputDto {
  @IsString()
  description: string;

  @IsInt()
  @Min(1)
  quantity: number;

  @IsNumberString()
  unitPrice: string;
}
