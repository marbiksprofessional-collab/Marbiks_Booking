import { Controller, Get, Query, UseGuards } from '@nestjs/common';
import { ReportsService } from './reports.service';
import { RevenueQueryDto } from './dto/revenue-query.dto';
import { LeakageQueryDto } from './dto/leakage-query.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { RolesGuard } from '../common/guards/roles.guard';
import { Roles } from '../common/decorators/roles.decorator';
import { Role } from '../common/enums/role.enum';

@Controller('reports')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(Role.SUPER_ADMIN, Role.DIRECTOR, Role.GENERAL_MANAGER)
export class ReportsController {
  constructor(private readonly reportsService: ReportsService) {}

  @Get('revenue')
  getRevenue(@Query() query: RevenueQueryDto) {
    return this.reportsService.getRevenueSummary(query.from, query.to);
  }

  @Get('leakage')
  getLeakage(@Query() query: LeakageQueryDto) {
    return this.reportsService.getLeakageReport(query.unpaidDays);
  }
}
