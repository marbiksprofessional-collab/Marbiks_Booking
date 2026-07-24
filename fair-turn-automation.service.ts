import { Injectable, Logger, HttpException, HttpStatus } from '@nestjs/common';

@Injectable()
export class FairTurnAutomationService {
  private readonly logger = new Logger('FairTurnAutomationService');

    // Memory matrices tracking technician rotational profiles
      private branchTurnQueues = new Map<string, string[]>(); // branchId -> [staffIds in order]
        private staffPenaltyStatus = new Map<string, { isBlocked: boolean; reason: string; liftTime: number }>();

          /**
             * 🔄 1. ENQUEUE STAFF INTO ROUND-ROBIN MATRIX
                * Adds staff to the baseline rotation queue immediately upon morning attendance validation
                   */
                     initializeStaffTurn(branchId: string, staffId: string): void {
                         const queue = this.branchTurnQueues.get(branchId) || [];
                             if (!queue.includes(staffId)) {
                                   queue.push(staffId);
                                         this.branchTurnQueues.set(branchId, queue);
                                             }
                                               }

                                                 /**
                                                    * ⚖️ 2. AUTOMATED TURN ALLOCATION WITH PENALTY FOR SKIP/REJECTION LEAP
                                                       * Enforces strict round-robin mechanics. Technicians cannot cherry-pick high-value tickets.
                                                          */
                                                            allocateNextAvailableTechnician(branchId: string, serviceValue: number): any {
                                                                const queue = this.branchTurnQueues.get(branchId) || [];
                                                                    if (queue.length === 0) {
                                                                          throw new HttpException('No operational service providers available in active rotation queues.', HttpStatus.NOT_FOUND);
                                                                              }

                                                                                  // Filter out penalized staff who skipped small tasks
                                                                                      let targetStaffId = null;
                                                                                          const currentTime = Date.now();

                                                                                              for (let i = 0; i < queue.length; i++) {
                                                                                                    const staffId = queue[i];
                                                                                                          const penalty = this.staffPenaltyStatus.get(staffId);

                                                                                                                if (penalty && penalty.isBlocked) {
                                                                                                                        if (currentTime > penalty.liftTime) {
                                                                                                                                  this.staffPenaltyStatus.delete(staffId); // Penalty expired log
                                                                                                                                          } else {
                                                                                                                                                    continue; // Skip this technician, they are currently penalized
                                                                                                                                                            }
                                                                                                                                                                  }
                                                                                                                                                                        
                                                                                                                                                                              targetStaffId = staffId;
                                                                                                                                                                                    // Remove from front and push to the back of the rotation line
                                                                                                                                                                                          queue.splice(i, 1);
                                                                                                                                                                                                queue.push(targetStaffId);
                                                                                                                                                                                                      this.branchTurnQueues.set(branchId, queue);
                                                                                                                                                                                                            break;
                                                                                                                                                                                                                }

                                                                                                                                                                                                                    if (!targetStaffId) {
                                                                                                                                                                                                                          throw new HttpException('All available technicians are currently under penalty status blocks.', HttpStatus.FORBIDDEN);
                                                                                                                                                                                                                              }

                                                                                                                                                                                                                                  return { status: 'allocated', staffId: targetStaffId, ruleApplied: 'Strict Round-Robin' };
                                                                                                                                                                                                                                    }

                                                                                                                                                                                                                                      /**
                                                                                                                                                                                                                                         * 🚨 3. LOG SERVICE REJECTION / HIDDEN MISSED TURN PENALTY
                                                                                                                                                                                                                                            * Punishes staff who hide or refuse low-token services by locking them out of high-value tasks
                                                                                                                                                                                                                                               */
                                                                                                                                                                                                                                                 flagServiceRejection(branchId: string, staffId: string, reason: string): any {
                                                                                                                                                                                                                                                     const blockDurationMinutes = 120; // Blocked from active high-incentive streams for 2 straight hours
                                                                                                                                                                                                                                                         const liftTime = Date.now() + (blockDurationMinutes * 60 * 1000);

                                                                                                                                                                                                                                                             this.staffPenaltyStatus.set(staffId, { isBlocked: true, reason, liftTime });

                                                                                                                                                                                                                                                                 // Move penalized staff to the absolute bottom of the rotation chain
                                                                                                                                                                                                                                                                     const queue = this.branchTurnQueues.get(branchId) || [];
                                                                                                                                                                                                                                                                         const index = queue.indexOf(staffId);
                                                                                                                                                                                                                                                                             if (index > -1) {
                                                                                                                                                                                                                                                                                   queue.splice(index, 1);
                                                                                                                                                                                                                                                                                         queue.push(staffId); // Sent to the back of the line
                                                                                                                                                                                                                                                                                               this.branchTurnQueues.set(branchId, queue);
                                                                                                                                                                                                                                                                                                   }

                                                                                                                                                                                                                                                                                                       this.logger.error(`[ANTI-CHERRY-PICKING ALERT] Staff UUID: ${staffId} penalized for: ${reason}. Locked for 2 hours.`);
                                                                                                                                                                                                                                                                                                           return { status: 'penalties_applied', staffId, durationMinutes: blockDurationMinutes, position: 'moved_to_bottom' };
                                                                                                                                                                                                                                                                                                             }

                                                                                                                                                                                                                                                                                                               /**
                                                                                                                                                                                                                                                                                                                  * 📱 4. RESTRICTED ZONE HARDWARE PHONE TRACKER
                                                                                                                                                                                                                                                                                                                     * Triggered by IOT Beacons if a technician sneaks their phone into a restricted treatment zone
                                                                                                                                                                                                                                                                                                                        */
                                                                                                                                                                                                                                                                                                                          logRestrictedZoneDeviceViolation(staffId: string, zoneId: string): any {
                                                                                                                                                                                                                                                                                                                              const violationReport = {
                                                                                                                                                                                                                                                                                                                                    alertType: 'RESTRICTED_ZONE_PHONE_INFRACTION',
                                                                                                                                                                                                                                                                                                                                          staffId,
                                                                                                                                                                                                                                                                                                                                                zoneId,
                                                                                                                                                                                                                                                                                                                                                      timestamp: new Date().toISOString(),
                                                                                                                                                                                                                                                                                                                                                            actionRequired: 'IMMEDIATE_MANAGER_INTERVENTION'
                                                                                                                                                                                                                                                                                                                                                                };

                                                                                                                                                                                                                                                                                                                                                                    this.logger.error(`[SECURITY POLICY VIOLATION] ${JSON.stringify(violationReport)}`);
                                                                                                                                                                                                                                                                                                                                                                        return { status: 'security_violation_flagged', staffId, zoneId, dispatchAlert: true };
                                                                                                                                                                                                                                                                                                                                                                          }
                                                                                                                                                                                                                                                                                                                                                                          }
                                                                                                                                                                                                                                                                                                                                                                          