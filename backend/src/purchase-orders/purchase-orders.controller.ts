import { Body, Controller, Get, Param, Patch, Post, Query, UseGuards } from '@nestjs/common';
import { PurchaseOrdersService } from './purchase-orders.service';
import { CreatePurchaseOrderDto } from './dto/create-purchase-order.dto';
import { ReceivePurchaseOrderDto } from './dto/receive-purchase-order.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { RolesGuard } from '../common/guards/roles.guard';
import { Roles } from '../common/decorators/roles.decorator';
import { Role } from '../common/enums/role.enum';
import { CurrentUser } from '../common/decorators/current-user.decorator';

interface RequestUser {
  id: string;
}

const PO_WRITE_ROLES = [Role.SUPER_ADMIN, Role.STORE_MANAGER, Role.BRANCH_MANAGER];

@Controller('purchase-orders')
@UseGuards(JwtAuthGuard)
export class PurchaseOrdersController {
  constructor(private readonly purchaseOrdersService: PurchaseOrdersService) {}

  @Post()
  @UseGuards(RolesGuard)
  @Roles(...PO_WRITE_ROLES)
  create(@Body() dto: CreatePurchaseOrderDto) {
    return this.purchaseOrdersService.create(dto);
  }

  @Get()
  findAll(@Query('branchId') branchId?: string) {
    return this.purchaseOrdersService.findAll(branchId);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.purchaseOrdersService.findById(id);
  }

  @Patch(':id/receive')
  @UseGuards(RolesGuard)
  @Roles(...PO_WRITE_ROLES)
  receive(
    @Param('id') id: string,
    @Body() dto: ReceivePurchaseOrderDto,
    @CurrentUser() user: RequestUser,
  ) {
    return this.purchaseOrdersService.receive(id, dto, user.id);
  }

  @Patch(':id/cancel')
  @UseGuards(RolesGuard)
  @Roles(...PO_WRITE_ROLES)
  cancel(@Param('id') id: string) {
    return this.purchaseOrdersService.cancel(id);
  }
}
