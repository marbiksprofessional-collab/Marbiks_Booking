import { Type } from 'class-transformer';
import {
  IsArray,
  IsNumber,
  IsOptional,
  IsString,
  Min,
  ValidateNested,
} from 'class-validator';
import { InvoiceItemInputDto } from './invoice-item-input.dto';

export class CreateInvoiceDto {
  @IsString()
  branchId: string;

  @IsString()
  customerId: string;

  @IsOptional()
  @IsString()
  appointmentId?: string;

  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => InvoiceItemInputDto)
  items?: InvoiceItemInputDto[];

  @IsOptional()
  @IsNumber()
  @Min(0)
  discountAmount?: number;

  @IsOptional()
  @IsNumber()
  @Min(0)
  taxRatePercent?: number;
}
