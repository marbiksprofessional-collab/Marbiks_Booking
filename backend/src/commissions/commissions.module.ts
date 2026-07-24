import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Appointment } from '../appointments/appointment.entity';
import { Invoice } from '../billing/invoice.entity';
import { CommissionsService } from './commissions.service';
import { CommissionsController } from './commissions.controller';

@Module({
  imports: [TypeOrmModule.forFeature([Appointment, Invoice])],
  providers: [CommissionsService],
  controllers: [CommissionsController],
})
export class CommissionsModule {}
