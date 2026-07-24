import { Injectable, Logger } from '@nestjs/common';

@Injectable()
export class FraudControlService {
  private readonly logger = new Logger('FraudControlService');

    // Memory map storage containing raw hardware IoT metrics configurations
      private chairSensorStates = new Map<string, { isOccupied: boolean; lastScanTime: string }>(); // chairId -> status

        /**
           * 📡 1. HARDWARE IOT TRAFFIC RECEIVER
              * Receives real-time chair pressure/occupancy updates from branch physical hardware sensors
                 */
                   logChairSensorState(branchId: string, chairId: string, occupied: boolean): void {
                       this.chairSensorStates.set(chairId, {
                             isOccupied: occupied,
                                   lastScanTime: new Date().toISOString()
                                       });
                                         }

                                           /**
                                              * 🔍 2. AI ANTI-CHEATING RECONCILIATION ANOMALY ENGINE
                                                 * Compares ongoing backend active invoice bills against physical hardware sensor parameters
                                                    */
                                                      verifyWalkInTransparency(branchId: string, activeBillingAppointmentIds: string[]): any {
                                                          const fraudAlerts: any[] = [];
                                                              const currentTime = new Date().toISOString();

                                                                  // Loop logic auditing physical configurations against database parameters
                                                                      this.chairSensorStates.forEach((state, chairId) => {
                                                                            // Rule set validation: If chair sensor detects a client, but billing profile has 0 logs
                                                                                  const isChairPhysicallyBusy = state.isOccupied;
                                                                                        const isRegisteredInBillingSystem = activeBillingAppointmentIds.includes(chairId);

                                                                                              if (isChairPhysicallyBusy && !isRegisteredInBillingSystem) {
                                                                                                      const anomalyReport = {
                                                                                                                alertLevel: 'CRITICAL_RISK',
                                                                                                                          branchId,
                                                                                                                                    resourceId: chairId,
                                                                                                                                              timestamp: currentTime,
                                                                                                                                                        incidentDescription: 'Hardware conflict: Chair is physically occupied but front office executive recorded 0 billing entry parameters.',
                                                                                                                                                                  suspicionProfile: 'Potential unrecorded hidden cash Walk-In transaction execution bypass.'
                                                                                                                                                                          };
                                                                                                                                                                                  
                                                                                                                                                                                          fraudAlerts.push(anomalyReport);
                                                                                                                                                                                                  this.logger.error(`[FRAUD ANOMALY ALERT] ${JSON.stringify(anomalyReport)}`);
                                                                                                                                                                                                        }
                                                                                                                                                                                                            });

                                                                                                                                                                                                                return {
                                                                                                                                                                                                                      auditTimestamp: currentTime,
                                                                                                                                                                                                                            totalAuditedAssetsCount: this.chairSensorStates.size,
                                                                                                                                                                                                                                  cheatingRiskDetected: fraudAlerts.length > 0,
                                                                                                                                                                                                                                        activeAlerts: fraudAlerts
                                                                                                                                                                                                                                            };
                                                                                                                                                                                                                                              }

                                                                                                                                                                                                                                                /**
                                                                                                                                                                                                                                                   * 🧪 3. MATERIAL CONSUMPTION DISCREPANCY AUDITOR
                                                                                                                                                                                                                                                      * Flags discrepancies when technician product usage logs deviate from actual inventory checks
                                                                                                                                                                                                                                                         */
                                                                                                                                                                                                                                                           auditProductConsumptionVariance(expectedGrams: number, actualCheckedGrams: number, staffId: string): any {
                                                                                                                                                                                                                                                               const variance = Math.abs(expectedGrams - actualCheckedGrams);
                                                                                                                                                                                                                                                                   
                                                                                                                                                                                                                                                                       // Flag critical warning flags if raw deviation variance calculation skips over 10g thresholds
                                                                                                                                                                                                                                                                           if (variance > 10) {
                                                                                                                                                                                                                                                                                 return {
                                                                                                                                                                                                                                                                                         status: 'DISCREPANCY_DETECTED',
                                                                                                                                                                                                                                                                                                 staffId,
                                                                                                                                                                                                                                                                                                         varianceGrams: variance,
                                                                                                                                                                                                                                                                                                                 message: 'Alert: Heavy raw material volume variance mismatch detected. Audit transaction trails immediately.'
                                                                                                                                                                                                                                                                                                                       };
                                                                                                                                                                                                                                                                                                                           }

                                                                                                                                                                                                                                                                                                                               return { status: 'MATCHED_STABLE', varianceGrams: variance };
                                                                                                                                                                                                                                                                                                                                 }
                                                                                                                                                                                                                                                                                                                                 }
                                                                                                                                                                                                                                                                                                                                 