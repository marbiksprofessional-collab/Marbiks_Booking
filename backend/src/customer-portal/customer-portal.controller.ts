import { Body, Controller, Get, Param, Patch, Post, UseGuards } from '@nestjs/common';
import { CustomerPortalService } from './customer-portal.service';
import { BookOwnAppointmentDto } from './dto/book-own-appointment.dto';
import { RescheduleOwnAppointmentDto } from './dto/reschedule-own-appointment.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { RolesGuard } from '../common/guards/roles.guard';
import { Roles } from '../common/decorators/roles.decorator';
import { Role } from '../common/enums/role.enum';
import { CurrentUser } from '../common/decorators/current-user.decorator';

interface RequestUser {
  id: string;
}

/**
 * Self-service endpoints for the logged-in customer, mounted at /me rather
 * than nested under /customers/:id to avoid any ambiguity with the staff-
 * facing CustomersController's /customers/:id route.
 */
@Controller('me')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(Role.CUSTOMER)
export class CustomerPortalController {
  constructor(private readonly customerPortalService: CustomerPortalService) {}

  @Get()
  getProfile(@CurrentUser() user: RequestUser) {
    return this.customerPortalService.getProfile(user.id);
  }

  @Get('appointments')
  getMyAppointments(@CurrentUser() user: RequestUser) {
    return this.customerPortalService.getMyAppointments(user.id);
  }

  @Post('appointments')
  bookAppointment(@CurrentUser() user: RequestUser, @Body() dto: BookOwnAppointmentDto) {
    return this.customerPortalService.bookAppointment(user.id, dto);
  }

  @Patch('appointments/:id/reschedule')
  rescheduleAppointment(
    @CurrentUser() user: RequestUser,
    @Param('id') id: string,
    @Body() dto: RescheduleOwnAppointmentDto,
  ) {
    return this.customerPortalService.rescheduleOwnAppointment(user.id, id, dto);
  }

  @Patch('appointments/:id/cancel')
  cancelAppointment(@CurrentUser() user: RequestUser, @Param('id') id: string) {
    return this.customerPortalService.cancelOwnAppointment(user.id, id);
  }

  @Get('invoices')
  getMyInvoices(@CurrentUser() user: RequestUser) {
    return this.customerPortalService.getMyInvoices(user.id);
  }

  @Get('invoices/:id')
  getMyInvoice(@CurrentUser() user: RequestUser, @Param('id') id: string) {
    return this.customerPortalService.getMyInvoice(user.id, id);
  }
}
