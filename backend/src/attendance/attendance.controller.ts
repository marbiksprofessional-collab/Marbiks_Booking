import { Body, Controller, Get, Post, Query, UseGuards } from '@nestjs/common';
import { AttendanceService } from './attendance.service';
import { ClockInDto } from './dto/clock-in.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';

interface RequestUser {
  id: string;
}

@Controller('attendance')
@UseGuards(JwtAuthGuard)
export class AttendanceController {
  constructor(private readonly attendanceService: AttendanceService) {}

  @Post('clock-in')
  clockIn(@CurrentUser() user: RequestUser, @Body() dto: ClockInDto) {
    return this.attendanceService.clockIn(user.id, dto.branchId);
  }

  @Post('clock-out')
  clockOut(@CurrentUser() user: RequestUser) {
    return this.attendanceService.clockOut(user.id);
  }

  @Get('me/status')
  getStatus(@CurrentUser() user: RequestUser) {
    return this.attendanceService.getCurrentStatus(user.id);
  }

  @Get('me')
  getForDate(@CurrentUser() user: RequestUser, @Query('date') date: string) {
    return this.attendanceService.getForUserAndDate(user.id, date);
  }
}
