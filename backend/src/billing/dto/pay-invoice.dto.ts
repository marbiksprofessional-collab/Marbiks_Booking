import { IsEnum } from 'class-validator';
import { PaymentMethod } from '../invoice.entity';

export class PayInvoiceDto {
  @IsEnum(PaymentMethod)
  paymentMethod: PaymentMethod;
}
