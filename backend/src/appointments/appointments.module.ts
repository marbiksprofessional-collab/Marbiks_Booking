import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Appointment } from './appointment.entity';
import { Resource } from './resource.entity';
import { AppointmentsService } from './appointments.service';
import { ResourcesService } from './resources.service';
import { AppointmentsController, ResourcesController } from './appointments.controller';
import { ServicesModule } from '../services/services.module';

@Module({
  imports: [TypeOrmModule.forFeature([Appointment, Resource]), ServicesModule],
  providers: [AppointmentsService, ResourcesService],
  controllers: [AppointmentsController, ResourcesController],
  exports: [AppointmentsService],
})
export class AppointmentsModule {}
