import { Injectable, HttpException, HttpStatus } from '@nestjs/common';
import { ErpService } from './erp-service';

@Injectable()
export class BookingEngine {
  constructor(private readonly erpService: ErpService) {}

  async validateAndRouteBooking(payload: {
    branchId: string;
    customerId: string;
    technicianId: string;
    resourceType: string;
    requestedStart: string;
    requestedEnd: string;
  }): Promise<any> {
    const bookingDate = payload.requestedStart.split('T')[0];
    const externalActiveBookings = await this.erpService.getBranchAppointments(payload.branchId, bookingDate);
    
    const reqStartObj = new Date(payload.requestedStart).getTime();
    const reqEndObj = new Date(payload.requestedEnd).getTime();

    if (externalActiveBookings && Array.isArray(externalActiveBookings.data)) {
      for (const currentBooking of externalActiveBookings.data) {
        const activeStart = new Date(currentBooking.start_time).getTime();
        const activeEnd = new Date(currentBooking.end_time).getTime();

        const isResourceConflict = currentBooking.resource_id === payload.technicianId || currentBooking.technician_id === payload.technicianId;
        const isTimeOverlapping = (reqStartObj < activeEnd && reqEndObj > activeStart);

        if (isResourceConflict && isTimeOverlapping) {
          throw new HttpException(
            { 
              status: 'conflict', 
              message: 'AI Conflict Detected: The requested technician or chair resource is already allocated for this time slot.'
            },
            HttpStatus.CONFLICT,
          );
        }
      }
    }

    return await this.erpService.createExternalBooking(payload);
  }
}
