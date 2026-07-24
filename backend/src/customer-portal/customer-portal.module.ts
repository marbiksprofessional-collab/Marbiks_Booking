import { Module } from '@nestjs/common';
import { CustomerPortalService } from './customer-portal.service';
import { CustomerPortalController } from './customer-portal.controller';
import { AppointmentsModule } from '../appointments/appointments.module';
import { BillingModule } from '../billing/billing.module';
import { CustomersModule } from '../customers/customers.module';

@Module({
  imports: [AppointmentsModule, BillingModule, CustomersModule],
  providers: [CustomerPortalService],
  controllers: [CustomerPortalController],
})
export class CustomerPortalModule {}
