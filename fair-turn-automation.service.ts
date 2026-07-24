import { Injectable, Logger, HttpException, HttpStatus } from '@nestjs/common';

@Injectable()
export class FairTurnAutomationService {
  private readonly logger = new Logger('FairTurnAutomationService');

    // Admin Configurable Global Penalty Rate Framework
      private adminConfiguredMissedTurnPenaltyAmount = 500; // Default ₹500 penalty, changeable by admin
        
          private branchTurnQueues = new Map<string, string[]>(); // branchId -> [staffIds]
            private staffFinancialPenalties = new Map<string, { totalPenaltyDeducted: number; infractionsCount: number; logs: any[] }>();

              /**
                 * ⚙️ 1. ADMIN PENALTY CONFIGUTATOR
                    * Allows Super Admin or GM to dynamically adjust the penalty fine via dashboard room controllers
                       */
                         updateAdminPenaltyConfiguration(newAmount: number): any {
                             if (newAmount < 0) {
                                   throw new HttpException('Penalty deduction configuration amount cannot be negative.', HttpStatus.BAD_REQUEST);
                                       }
                                           this.adminConfiguredMissedTurnPenaltyAmount = newAmount;
                                               this.logger.log(`[Admin Config Updated] Missed turn penalty fine is now set to: ₹${newAmount}`);
                                                   return { status: 'success', currentPenaltyFineSet: this.adminConfiguredMissedTurnPenaltyAmount };
                                                     }

                                                       /**
                                                          * 🚨 2. HIDDEN TURN INTERCEPTOR WITH FINANCIAL PENALTY DEDUCTION
                                                             * Triggers flat monetary salary deduction if staff hides or fails to press "Accept/Done" inside 10 mins window
                                                                */
                                                                  logMissedTurnInfraction(branchId: string, staffId: string, activeAppointmentId: string): any {
                                                                      const currentStaffPenaltyRecord = this.staffFinancialPenalties.get(staffId) || {
                                                                            totalPenaltyDeducted: 0,
                                                                                  infractionsCount: 0,
                                                                                        logs: []
                                                                                            };

                                                                                                // Calculate updated penalty data matrix rules
                                                                                                    currentStaffPenaltyRecord.infractionsCount += 1;
                                                                                                        currentStaffPenaltyRecord.totalSalaryDeducted += this.adminConfiguredMissedTurnPenaltyAmount;
                                                                                                            currentStaffPenaltyRecord.logs.push({
                                                                                                                  timestamp: new Date().toISOString(),
                                                                                                                        appointmentId,
                                                                                                                              branchId,
                                                                                                                                    deductedAmount: this.adminConfiguredMissedTurnPenaltyAmount,
                                                                                                                                          reason: 'SOP Policy Infraction: Hidden Turn Timeout. Failed to execute Accept/Done within 10-minute constraint.'
                                                                                                                                              });

                                                                                                                                                  this.staffFinancialPenalties.set(staffId, currentStaffPenaltyRecord);

                                                                                                                                                      // Hard rotation update: Remove technician and push straight to the bottom of the line
                                                                                                                                                          const queue = this.branchTurnQueues.get(branchId) || [];
                                                                                                                                                              const index = queue.indexOf(staffId);
                                                                                                                                                                  if (index > -1) {
                                                                                                                                                                        queue.splice(index, 1);
                                                                                                                                                                              queue.push(staffId);
                                                                                                                                                                                    this.branchTurnQueues.set(branchId, queue);
                                                                                                                                                                                        }

                                                                                                                                                                                            this.logger.error(`[FINANCIAL PENALTY LOCKED] Technician UUID: ${staffId} penalized ₹${this.adminConfiguredMissedTurnPenaltyAmount} for skipping turn.`);
                                                                                                                                                                                                
                                                                                                                                                                                                    return {
                                                                                                                                                                                                          status: 'INFRACTION_PENALIZED',
                                                                                                                                                                                                                staffId,
                                                                                                                                                                                                                      deductedFine: this.adminConfiguredMissedTurnPenaltyAmount,
                                                                                                                                                                                                                            accumulatedPenaltyTotal: currentStaffPenaltyRecord.totalSalaryDeducted,
                                                                                                                                                                                                                                  queuePosition: 'demoted_to_bottom'
                                                                                                                                                                                                                                      };
                                                                                                                                                                                                                                        }

                                                                                                                                                                                                                                          /**
                                                                                                                                                                                                                                             * 📱 3. RESTRICTED ZONE HARDWARE PHONE TRACKER
                                                                                                                                                                                                                                                * Triggers immediate push alerts if a technician sneaks their phone into a restricted treatment zone
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
                                                                                                                                                                                                                                                                                                     