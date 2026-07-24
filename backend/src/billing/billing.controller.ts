import { Body, Controller, Get, Param, Patch, Post, Query, UseGuards } from '@nestjs/common';
import { BillingService } from './billing.service';
import { CreateInvoiceDto } from './dto/create-invoice.dto';
import { PayInvoiceDto } from './dto/pay-invoice.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';

@Controller('invoices')
@UseGuards(JwtAuthGuard)
export class BillingController {
  constructor(private readonly billingService: BillingService) {}

  @Post()
  create(@Body() dto: CreateInvoiceDto) {
    return this.billingService.create(dto);
  }

  @Get()
  findForBranch(@Query('branchId') branchId: string) {
    return this.billingService.findForBranch(branchId);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.billingService.findById(id);
  }

  @Patch(':id/pay')
  markPaid(@Param('id') id: string, @Body() dto: PayInvoiceDto) {
    return this.billingService.markPaid(id, dto.paymentMethod);
  }
}
