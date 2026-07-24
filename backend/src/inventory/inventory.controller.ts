import { Body, Controller, Get, Post, Query, UseGuards } from '@nestjs/common';
import { InventoryService } from './inventory.service';
import { ReceiveStockDto } from './dto/receive-stock.dto';
import { ConsumeStockDto } from './dto/consume-stock.dto';
import { TransferStockDto } from './dto/transfer-stock.dto';
import { AdjustStockDto } from './dto/adjust-stock.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { RolesGuard } from '../common/guards/roles.guard';
import { Roles } from '../common/decorators/roles.decorator';
import { Role } from '../common/enums/role.enum';
import { CurrentUser } from '../common/decorators/current-user.decorator';

interface RequestUser {
  id: string;
}

const STOCK_WRITE_ROLES = [Role.SUPER_ADMIN, Role.STORE_MANAGER, Role.BRANCH_MANAGER];

@Controller('inventory')
@UseGuards(JwtAuthGuard)
export class InventoryController {
  constructor(private readonly inventoryService: InventoryService) {}

  @Post('receive')
  @UseGuards(RolesGuard)
  @Roles(...STOCK_WRITE_ROLES)
  receive(@Body() dto: ReceiveStockDto, @CurrentUser() user: RequestUser) {
    return this.inventoryService.receiveStock(dto, user.id);
  }

  @Post('consume')
  @UseGuards(RolesGuard)
  @Roles(...STOCK_WRITE_ROLES)
  consume(@Body() dto: ConsumeStockDto, @CurrentUser() user: RequestUser) {
    return this.inventoryService.consumeStock(dto, user.id);
  }

  @Post('transfer')
  @UseGuards(RolesGuard)
  @Roles(...STOCK_WRITE_ROLES)
  transfer(@Body() dto: TransferStockDto, @CurrentUser() user: RequestUser) {
    return this.inventoryService.transferStock(dto, user.id);
  }

  @Post('adjust')
  @UseGuards(RolesGuard)
  @Roles(...STOCK_WRITE_ROLES)
  adjust(@Body() dto: AdjustStockDto, @CurrentUser() user: RequestUser) {
    return this.inventoryService.adjustStock(dto, user.id);
  }

  @Get('stock')
  getStock(@Query('branchId') branchId: string) {
    return this.inventoryService.getStockForBranch(branchId);
  }

  @Get('low-stock')
  getLowStock(@Query('branchId') branchId: string) {
    return this.inventoryService.getLowStock(branchId);
  }

  @Get('expiring')
  getExpiring(@Query('branchId') branchId: string, @Query('withinDays') withinDays: string) {
    return this.inventoryService.getExpiringBatches(branchId, parseInt(withinDays, 10) || 30);
  }
}
