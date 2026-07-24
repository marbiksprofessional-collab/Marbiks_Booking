import { Injectable, Logger, HttpException, HttpStatus } from '@nestjs/common';

@Injectable()
export class AntiProxyService {
  private readonly logger = new Logger('AntiProxyService');
  
  // Storage track container config mapping for active technician processing cycles
  private staffOperationalStates = new Map<string, { activeAppointmentId: string; lastStateChange: string; isAvailable: boolean }>();

  /**
   * 🔒 1. SERVICE ALLOCATION CLOCK-LOCK PROTOCOL
   * Triggered immediately when front office locks a technician to a client transaction path
   */
  lockTechnicianToService(staffId: string, appointmentId: string): any {
    const timestamp = new Date().toISOString();
    
    this.staffOperationalStates.set(staffId, {
      activeAppointmentId: appointmentId,
      lastStateChange: timestamp,
      isAvailable: false // Locked, phone is now stored away safely in store room locker
    });

    this.logger.log(`[Clock-Lock Active] Technician UUID: ${staffId} locked to service loop. Device access suspended.`);
    return { status: 'technician_locked', staffId, appointmentId, timestamp };
  }

  /**
   * 🔓 2. STORE ROOM MATERIAL VERIFICATION AUDIT
   * Triggered by the Store Manager or Receptionist Tablet upon physical product return verification
   */
  releaseTechnicianFromService(staffId: string, actualGramsConsumed: number): any {
    const state = this.staffOperationalStates.get(staffId);
    if (!state) {
      throw new HttpException('No ongoing active allocation state found for this technician.', HttpStatus.NOT_FOUND);
    }

    const timestamp = new Date().toISOString();
    
    this.staffOperationalStates.set(staffId, {
      activeAppointmentId: null,
      lastStateChange: timestamp,
      isAvailable: true // Released, now visible on app and website grids for next service assignment
    });

    this.logger.log(`[Clock-Lock Released] Technician UUID: ${staffId} successfully passed material audit: ${actualGramsConsumed}g consumed.`);
    return { status: 'technician_available', staffId, materialAudit: 'passed', timestamp };
  }

  /**
   * 🚨 3. REAL-TIME UNPRODUCTIVE BREAK DETECTOR
   * Flags front office cheating loops if staff sits inside store room without active allocations
   */
  auditUnproductiveStoreRoomTime(staffId: string, minutesSpentInStoreRoom: number): any {
    const state = this.staffOperationalStates.get(staffId);
    const isCurrentlyFree = state ? state.isAvailable : true;

    // Rule validation loop: If staff is marked available but lingers in store room for over 20 mins
    if (isCurrentlyFree && minutesSpentInStoreRoom > 20) {
      const anomalyReport = {
        alert: 'UNPRODUCTIVE_STORE_ROOM_LINGERING',
        staffId,
        idleMinutes: minutesSpentInStoreRoom,
        severity: 'MEDIUM_RISK',
        description: 'Technician is technically marked Available but has lingered in the store room without an active client service for over 20 minutes.'
      };

      this.logger.error(`[SOP TIMEOUT INFRACTION] ${JSON.stringify(anomalyReport)}`);
      return { status: 'infraction_flagged', raiseAdminAlert: true, report: anomalyReport };
    }

    return { status: 'stable', raiseAdminAlert: false };
  }
}
