import { Body, Controller, Get, Param, Patch, Post, Query, UseGuards } from '@nestjs/common';
import { AppointmentsService } from './appointments.service';
import { CreateAppointmentDto } from './dto/create-appointment.dto';
import { RescheduleAppointmentDto } from './dto/reschedule-appointment.dto';
import { ResourcesService } from './resources.service';
import { CreateResourceDto } from './dto/create-resource.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';

@Controller('appointments')
@UseGuards(JwtAuthGuard)
export class AppointmentsController {
  constructor(private readonly appointmentsService: AppointmentsService) {}

  @Post()
  create(@Body() dto: CreateAppointmentDto) {
    return this.appointmentsService.create(dto);
  }

  @Get()
  findForBranchAndDate(@Query('branchId') branchId: string, @Query('date') date: string) {
    return this.appointmentsService.findForBranchAndDate(branchId, date);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.appointmentsService.findById(id);
  }

  @Patch(':id/reschedule')
  reschedule(@Param('id') id: string, @Body() dto: RescheduleAppointmentDto) {
    return this.appointmentsService.reschedule(id, dto);
  }

  @Patch(':id/cancel')
  cancel(@Param('id') id: string) {
    return this.appointmentsService.cancel(id);
  }

  @Patch(':id/no-show')
  markNoShow(@Param('id') id: string) {
    return this.appointmentsService.markNoShow(id);
  }

  @Patch(':id/complete')
  complete(@Param('id') id: string) {
    return this.appointmentsService.complete(id);
  }
}

@Controller('resources')
@UseGuards(JwtAuthGuard)
export class ResourcesController {
  constructor(private readonly resourcesService: ResourcesService) {}

  @Post()
  create(@Body() dto: CreateResourceDto) {
    return this.resourcesService.create(dto);
  }

  @Get()
  findAllForBranch(@Query('branchId') branchId: string) {
    return this.resourcesService.findAllForBranch(branchId);
  }
}
