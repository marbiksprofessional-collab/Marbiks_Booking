import { Type } from 'class-transformer';
import { IsArray, IsOptional, ValidateNested } from 'class-validator';
import { ReceiveItemOverrideDto } from './receive-item-override.dto';

export class ReceivePurchaseOrderDto {
  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => ReceiveItemOverrideDto)
  items?: ReceiveItemOverrideDto[];
}
